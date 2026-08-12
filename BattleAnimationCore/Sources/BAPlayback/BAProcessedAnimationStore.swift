//
//  BAProcessedAnimationStore.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/3/26.
//

// BAPlayback's public API is expressed in BAModel types (BAModeID, BACatalog, BAWeaponSlot),
// so consumers get them without a second import or a second linked product.
@_exported import BAModel
import Foundation

public enum BAProcessedAnimationStoreError: Error, Sendable {
    case catalogNotFound
    case catalogUnreadable(String)
    case animationNotFound(String)
    case manifestNotFound(String)
    case noTimelineForMode(BAModeID)
    case frameAssetNotFound(paths: [String])
}

public enum BAProcessedAnimationStore {

    private struct LoadedPack: Sendable {
        let data: Data
        let index: BAPack.Index
        let payloadStart: Int
    }

    private static let pack: Result<LoadedPack, BAProcessedAnimationStoreError> = {
        guard let url = Bundle.module.url(
            forResource: (BAPack.fileName as NSString).deletingPathExtension,
            withExtension: (BAPack.fileName as NSString).pathExtension
        ) else {
            return .failure(.catalogNotFound)
        }

        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            let headerEnd = BAPack.magic.count + MemoryLayout<UInt64>.size
            guard data.count > headerEnd, data.prefix(BAPack.magic.count) == BAPack.magic else {
                return .failure(.catalogUnreadable("bad pack header"))
            }

            let lengthBytes = data[BAPack.magic.count..<headerEnd]
            let indexLength = Int(UInt64(littleEndian: lengthBytes.withUnsafeBytes { $0.loadUnaligned(as: UInt64.self) }))
            let indexEnd = headerEnd + indexLength
            let index = try JSONDecoder().decode(BAPack.Index.self, from: Data(data[headerEnd..<indexEnd]))

            return .success(LoadedPack(data: data, index: index, payloadStart: indexEnd))
        } catch {
            return .failure(.catalogUnreadable("\(error)"))
        }
    }()

    private static let loadedCatalog: Result<BACatalog, BAProcessedAnimationStoreError> = pack.map(\.index.catalog)

    static func loadManifest(id: String) throws -> BAManifest {
        guard let manifest = try pack.get().index.manifests[id] else {
            throw BAProcessedAnimationStoreError.manifestNotFound(id)
        }
        return manifest
    }

    private static func imageData(path: String, animationID: String) -> Data? {
        guard let loaded = try? pack.get(),
              let slice = loaded.index.frames["\(animationID)/\(path)"]
        else {
            return nil
        }

        let start = loaded.payloadStart + Int(slice.offset)
        return Data(loaded.data[start..<(start + Int(slice.length))])
    }

    // MARK: - Catalog
    public static func catalog() throws(BAProcessedAnimationStoreError) -> BACatalog {
        try loadedCatalog.get()
    }

    public static func entry(
        animationID: String
    ) throws(BAProcessedAnimationStoreError) -> BACatalog.Entry {
        guard let entry = try catalog().animations.first(where: { $0.id == animationID }) else {
            throw .animationNotFound(animationID)
        }

        return entry
    }

    // MARK: - Playback
    public static func playableEvents(
        animationID: String,
        mode: BAModeID
    ) throws -> [BAPlaybackEvent] {
        let entry = try entry(animationID: animationID)
        return try playableEvents(entry: entry, mode: mode)
    }

    public static func playableEvents(
        entry: BACatalog.Entry,
        mode: BAModeID
    ) throws -> [BAPlaybackEvent] {
        // The catalog knows which modes exist, so fallback resolves before we touch the disk.
        let resolvedMode = try resolveMode(mode, in: entry)
        let manifest = try loadManifest(id: entry.id)

        guard let timeline = manifest.timelines.first(where: { $0.modeID == resolvedMode }) else {
            throw BAProcessedAnimationStoreError.noTimelineForMode(resolvedMode)
        }

        // Build a lookup from original source PNG name to processed frame asset.
        let assetsBySourceFile = Dictionary(
            uniqueKeysWithValues: manifest.frameAssets.map { ($0.sourceFile, $0) }
        )

        return try timeline.events.compactMap { event in
            switch event {
            case .frame(let frameEvent):
                guard let asset = assetsBySourceFile[frameEvent.sourceFile] else { return nil }
                let layerData = try playbackLayerData(from: asset.layerType, animationID: entry.id)
                return .frame(
                    BAPlaybackFrame(duration: frameEvent.duration, layerData: layerData)
                )

            case .command(let command):
                return .marker(BAPlaybackEvent.Marker(code: command.code))
            }
        }
    }

    /// Walks the requested mode's fallback chain until it finds one the animation actually has.
    static func resolveMode(
        _ requested: BAModeID,
        in entry: BACatalog.Entry
    ) throws(BAProcessedAnimationStoreError) -> BAModeID {
        for candidate in [requested] + requested.fallbacks where entry.contains(candidate) {
            return candidate
        }

        throw .noTimelineForMode(requested)
    }

    // MARK: - Frame assets
    private static func playbackLayerData(
        from assetPaths: BAManifest.Frame.PathStorage,
        animationID: String
    ) throws(BAProcessedAnimationStoreError) -> BAPlaybackFrame.LayerData {
        switch assetPaths {
        case .single(let path):
            guard let pathData = imageData(path: path, animationID: animationID) else {
                throw .frameAssetNotFound(paths: assetPaths.paths)
            }
            return .single(pathData)

        case .dual(let fgPath, let bgPath):
            guard let fgPathData = imageData(path: fgPath, animationID: animationID),
                  let bgPathData = imageData(path: bgPath, animationID: animationID)
            else {
                throw .frameAssetNotFound(paths: assetPaths.paths)
            }
            return .double(foreground: fgPathData, background: bgPathData)
        }
    }
}
