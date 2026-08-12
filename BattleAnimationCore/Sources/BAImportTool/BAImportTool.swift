//
//  BAImportTool.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/3/26.
//
//  Notice: This code was generated using AI Tools such as Claude or Codex.
//

import ArgumentParser
import BAModel
import Foundation
import ImportTooling
import ScriptParser

private struct ImportPlan: Sendable {
    let animationID: String
    let spriteSet: BASpriteSet
    let variant: BAVariant
    let sourceFolder: URL
    let scriptURL: URL
    let outputFolder: URL
}

private struct ImportOutcome: Sendable {
    let plan: ImportPlan
    let result: Result<BAManifest, Error>
}

enum BAImportToolError: Error {
    case noParseableScriptFound(URL)
    case hadImportFailures(amount: Int)
    case noSourceFolders(path: String)
}

@main
struct BAImportTool: AsyncParsableCommand {

    @Option(name: .long, help: "Import at most this many animations (for local testing).")
    var limit: Int?

    func run() async throws {
        setvbuf(stdout, nil, _IOLBF, 0)   // line-buffer so piped output streams live
        try await BAImportTool.execute(limit: limit)
    }

    private static func execute(limit: Int?) async throws {
        // Log our start time for tracking how long the process takes
        let started = Date.now

        // The tool should be run from the package root.
        let packageRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

        let sourceRoot = packageRoot
            .appendingPathComponent("../../HexEmblem-Sources/CombatAnimations")
            .standardizedFileURL

        let scratchRoot = packageRoot
            .appendingPathComponent("../../HexEmblem-Sources/ProcessedScratch")
            .standardizedFileURL

        let outputRoot = packageRoot
            .appendingPathComponent("Sources/BAPlayback/Resources")

        // Recursively find folders that contain parseable FE animation scripts.
        let sourceFolders = try animationSourceFolders(in: sourceRoot)

        guard !sourceFolders.isEmpty else {
            throw BAImportToolError.noSourceFolders(path: sourceRoot.path)
        }

        let selectedFolders = limit.map { Array(sourceFolders.prefix($0)) } ?? sourceFolders

        // Serial planning of import work
        let plans: [ImportPlan] = try selectedFolders.map { sourceFolder in
            let identity = sourceIdentity(for: sourceFolder, sourceRoot: sourceRoot)
            return ImportPlan(
                animationID: identity.animationID,
                spriteSet: identity.spriteSet,
                variant: identity.variant,
                sourceFolder: sourceFolder,
                scriptURL: try findParseableScript(in: sourceFolder),
                outputFolder: scratchRoot.appendingPathComponent(identity.animationID)
            )
        }

        let outcomes = await processImportPlans(plans)

        // Split the outcomes based on success / failure
        let (manifests, failures): ([BAManifest], [(id: String, error: Error)]) = outcomes
            .reduce((manifests: [], errors: [])) { partialResult, outcome in
                var copy = partialResult
                switch outcome.result {
                case .success(let manifest):
                    copy.manifests.append(manifest)
                case .failure(let error):
                    copy.errors.append((id: outcome.plan.animationID,
                                        error: error))
                }
                return copy
            }

        // Build a catalog of successful imports
        let catalog = buildCatalog(from: manifests)

        try writePack(
            manifests: manifests,
            catalog: catalog,
            processedRoot: scratchRoot,
            packageRoot: packageRoot
        )

        try FileManager.default.removeItem(at: scratchRoot)

        // Write the catalog to the root of the output folder
        let catalogData = try JSONEncoder.prettyStable.encode(catalog)
        try catalogData.write(to: outputRoot.appendingPathComponent("catalog.json"))

        // Print report of successful results
        let elapsed = String(format: "%.1fs", Date().timeIntervalSince(started))
        print("""
        Imported \(manifests.count)/\(plans.count) animations in \(elapsed)
        Catalog: \(catalog.animations.count) entries → catalog.json
        """)

        // Print information about any failures
        guard !failures.isEmpty else { return }

        print("\nFailed (\(failures.count)):")
        for failure in failures {
            print("  \(failure.id) — \(failure.error.localizedDescription)")
        }

        throw BAImportToolError.hadImportFailures(amount: failures.count)
    }

    private static func log(_ outcome: ImportOutcome, completed: Int, total: Int) {
        let counter = "[\(completed)/\(total)]"

        switch outcome.result {
        case .success(let manifest):
            let slot = outcome.plan.variant.slot.map { "\($0)" } ?? "unslotted"
            print("\(counter) ✓ \(manifest.id)  [\(slot)]  \(manifest.frameAssets.count) frames, \(manifest.timelines.count) modes")

            for warning in manifest.warnings {
                print("        ⚠︎ \(warning)")
            }

        case .failure(let error):
            print("\(counter) ✗ \(outcome.plan.animationID) - error \(error.localizedDescription)")
        }
    }

    private static func processImportPlans(_ plans: [ImportPlan]) async -> [ImportOutcome] {
        // Determine how many workers we have for the import process
        let workers = max(1, ProcessInfo.processInfo.activeProcessorCount)
        print("Found \(plans.count) animations — importing with \(workers) workers\n")

        return await withTaskGroup(of: ImportOutcome.self) { group in
            var collectedOutcomes: [ImportOutcome] = []
            var next = 0

            // Helper func for adding the task to the group
            func addTask(for plan: ImportPlan) {
                group.addTask {
                    do {
                        return try importAnimation(with: plan)
                    } catch {
                        return ImportOutcome(plan: plan, result: .failure(error))
                    }
                }
            }

            // Create an original pool of tasks, limited by the number of workers or the number of plans
            while next < min(workers, plans.count) {
                addTask(for: plans[next])
                next += 1
            }

            // Wait for tasks in the group to finish, save their outcomes,
            //     and begin a new task on the recently freed worker
            while let outcome = await group.next() {
                collectedOutcomes.append(outcome)
                log(outcome, completed: collectedOutcomes.count, total: plans.count)

                if next < plans.count {
                    addTask(for: plans[next])
                    next += 1
                }
            }

            return collectedOutcomes
        }
    }

    private static func importAnimation(with plan: ImportPlan) throws -> ImportOutcome {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: plan.outputFolder.path) {
            try fileManager.removeItem(at: plan.outputFolder)
        }
        try fileManager.createDirectory(
            at: plan.outputFolder,
            withIntermediateDirectories: true
        )

        let manifest = try BAImporter().importAnimation(
            animationID: plan.animationID,
            spriteSet: plan.spriteSet,
            variant: plan.variant,
            sourceFolder: plan.sourceFolder,
            scriptURL: plan.scriptURL,
            outputFolder: plan.outputFolder
        )

        let manifestData = try JSONEncoder.prettyStable.encode(manifest)
        try manifestData.write(to: plan.outputFolder.appendingPathComponent("manifest.json"))

        return ImportOutcome(plan: plan, result: .success(manifest))
    }

    private static func buildCatalog(from manifests: [BAManifest]) -> BACatalog {
        return BACatalog(
            animations: manifests
                .map { manifest in
                    BACatalog.Entry(
                        id: manifest.id,
                        spriteSet: manifest.spriteSet,
                        variant: manifest.variant,
                        modes: manifest.timelines.map(\.modeID),
                        frameCount: manifest.frameAssets.count,
                        renderSize: manifest.renderSize
                    )
                }
                .sorted { $0.id < $1.id }
        )
    }

    private static func animationSourceFolders(in sourceRoot: URL) throws -> [URL] {
        // A source folder must contain both PNG frames and a parseable script.
        try recursiveSubdirectories(of: sourceRoot)
            .filter { sourceFolder in
                guard try containsPNG(in: sourceFolder) else { return false }
                return (try? findParseableScript(in: sourceFolder)) != nil
            }
            .sorted { $0.path < $1.path }
    }

    private static func recursiveSubdirectories(of root: URL) throws -> [URL] {
        let fileManager = FileManager.default

        guard let enumerator = fileManager.enumerator(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var directories: [URL] = []

        // Walk every nested folder under SourceAnimations.
        for case let url as URL in enumerator {
            let values = try url.resourceValues(forKeys: [.isDirectoryKey])

            if values.isDirectory == true {
                directories.append(url)
            }
        }

        return directories
    }

    private static func containsPNG(in folder: URL) throws -> Bool {
        let files = try FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        // Frame source folders should contain PNG files directly.
        return files.contains { $0.pathExtension.lowercased() == "png" }
    }

    private static func findParseableScript(in sourceFolder: URL) throws -> URL {
        let files = try FileManager.default.contentsOfDirectory(
            at: sourceFolder,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        let candidates = files
            .filter { $0.pathExtension.lowercased() == "txt" }
            .filter { !isIgnoredTextFile($0) }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        // Prefer the first text file that actually parses into FE modes.
        for candidate in candidates {
            let text = try String(contentsOf: candidate, encoding: .utf8)
            let script = BAScriptParser.parse(text)

            if !script.modes.isEmpty {
                return candidate
            }
        }

        throw BAImportToolError.noParseableScriptFound(sourceFolder)
    }

    private static func isIgnoredTextFile(_ url: URL) -> Bool {
        let name = url.lastPathComponent.lowercased()
        let stem = url.deletingPathExtension().lastPathComponent.lowercased()

        // These text files are documentation, not animation scripts.
        return name == "readme.txt"
        || name == "credits.txt"
        || stem.contains("without_comment")
    }

    private struct SourceIdentity {
        let spriteSet: BASpriteSet
        let variant: BAVariant
        let subPathComponents: [String]

        var animationID: String {
            let suffix = subPathComponents
                .map { BASpriteSet.slug($0) }
                .joined(separator: "-")
            return suffix.isEmpty
            ? "\(spriteSet.id)_\(variant.idComponent)"
            : "\(spriteSet.id)_\(variant.idComponent)-\(suffix)"
        }
    }

    private static func sourceIdentity(for sourceFolder: URL, sourceRoot: URL) -> SourceIdentity {
        let relativePath = sourceFolder.path
            .replacingOccurrences(of: sourceRoot.path + "/", with: "")

        let components = relativePath.split(separator: "/").map(String.init)

        let spriteSet = BASpriteSet(folderName: components.first ?? relativePath)
        let variant = BAVariant(folderName: components.count > 1 ? components[1] : "")
        let subPathComponents = components.count > 2 ? Array(components[2...]) : []

        return SourceIdentity(spriteSet: spriteSet, variant: variant, subPathComponents: subPathComponents)
    }
}

// MARK: - Convert to single package export
extension BAImportTool {
    private static func writePack(
        manifests: [BAManifest],
        catalog: BACatalog,
        processedRoot: URL,
        packageRoot: URL
    ) throws {
        var payload = Data()
        var frames: [String: BAPack.Index.Slice] = [:]

        for manifest in manifests {
            let folder = processedRoot.appendingPathComponent(manifest.id)
            for path in manifest.allFrameAssetPaths.sorted() {
                let bytes = try Data(contentsOf: folder.appendingPathComponent(path))
                frames["\(manifest.id)/\(path)"] = .init(
                    offset: UInt64(payload.count),
                    length: UInt64(bytes.count)
                )
                payload.append(bytes)
            }
        }

        let index = BAPack.Index(
            catalog: catalog,
            manifests: Dictionary(uniqueKeysWithValues: manifests.map { ($0.id, $0) }),
            frames: frames
        )
        let indexData = try JSONEncoder().encode(index)

        var file = BAPack.magic
        withUnsafeBytes(of: UInt64(indexData.count).littleEndian) { file.append(contentsOf: $0) }
        file.append(indexData)
        file.append(payload)

        try file.write(
            to: packageRoot
                .appendingPathComponent("Sources/BAPlayback/Resources")
                .appendingPathComponent(BAPack.fileName),
            options: .atomic
        )
    }
}

extension BAManifest {
    var allFrameAssetPaths: [String] {
        Array(Set(frameAssets.flatMap { $0.layerType.paths + $0.paletteLayers.paths }))
    }
}
