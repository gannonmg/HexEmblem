//
//  BAProcessedAnimationStore.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/3/26.
//

// BAPlayback's public API is expressed in BAModel types (BAModeID, BACatalog, BAWeaponID),
// so consumers get them without a second import or a second linked product.
@_exported import BAModel
import Foundation

public enum BAProcessedAnimationStoreError: Error, Sendable {
    case catalogNotFound
    case catalogUnreadable(String)
    case animationNotFound(String)
    case manifestNotFound(String)
    case noTimelineForMode(BAModeID.Kind)
    case frameAssetNotFound(paths: [String])
}

public enum BAProcessedAnimationStore {

    private static let resourceFolder = "ProcessedAnimations"

    // MARK: - Catalog

    /// The generated index of every processed animation.
    ///
    /// `static let` gives lazy, thread-safe, one-time loading. The failure is captured in a
    /// `Result` rather than thrown so the property itself stays non-throwing and `Sendable`.
    private static let loadedCatalog: Result<BACatalog, BAProcessedAnimationStoreError> = {
        guard let catalogURL = Bundle.module.url(
            forResource: "catalog",
            withExtension: "json",
            subdirectory: resourceFolder
        ) else {
            return .failure(.catalogNotFound)
        }

        do {
            let data = try Data(contentsOf: catalogURL)
            return .success(try JSONDecoder().decode(BACatalog.self, from: data))
        } catch {
            return .failure(.catalogUnreadable("\(error)"))
        }
    }()

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
        mode: BAModeID.Kind
    ) throws -> [BAPlaybackEvent] {
        try playableEvents(entry: try entry(animationID: animationID), mode: mode)
    }

    public static func playableEvents(
        entry: BACatalog.Entry,
        mode: BAModeID.Kind
    ) throws -> [BAPlaybackEvent] {
        // The catalog knows which modes exist, so fallback resolves before we touch the disk.
        let resolvedMode = try resolveMode(mode, in: entry)
        let manifest = try loadManifest(id: entry.id)

        guard let timeline = manifest.timelines.first(where: { $0.modeID.kind == resolvedMode }) else {
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
                let layerURLs = try playbackLayerURLs(from: asset.layerType, animationID: entry.id)
                return .frame(
                    BAPlaybackFrame(duration: frameEvent.duration, layerURLs: layerURLs)
                )

            case .command(let command):
                return .marker(BAPlaybackEvent.Marker(command: command))
            }
        }
    }

//    public static func playableFrames(
//        animationID: String,
//        mode: BAModeID.Kind
//    ) throws -> [BAPlaybackFrame] {
//        try playableFrames(entry: try entry(animationID: animationID), mode: mode)
//    }
//
//    public static func playableFrames(
//        entry: BACatalog.Entry,
//        mode: BAModeID.Kind
//    ) throws -> [BAPlaybackFrame] {
//        try playableEvents(entry: entry, mode: mode).compactMap {
//            guard case .frame(let frame) = $0 else { return nil }
//            return frame
//        }
//    }

    /// Walks the requested mode's fallback chain until it finds one the animation actually has.
    static func resolveMode(
        _ requested: BAModeID.Kind,
        in entry: BACatalog.Entry
    ) throws(BAProcessedAnimationStoreError) -> BAModeID.Kind {
        for candidate in [requested] + requested.fallbacks where entry.contains(candidate) {
            return candidate
        }

        throw .noTimelineForMode(requested)
    }

    // MARK: - Manifest

    static func loadManifest(id: String) throws -> BAManifest {
        // Processed animations are bundled as copied package resources.
        guard let manifestURL = Bundle.module.url(
            forResource: "manifest",
            withExtension: "json",
            subdirectory: "\(resourceFolder)/\(id)"
        ) else {
            throw BAProcessedAnimationStoreError.manifestNotFound(id)
        }

        let data = try Data(contentsOf: manifestURL)
        return try JSONDecoder().decode(BAManifest.self, from: data)
    }

    // MARK: - Frame assets

    private static func playbackLayerURLs(
        from assetPaths: BAManifest.Frame.LayerType,
        animationID: String
    ) throws(BAProcessedAnimationStoreError) -> BAPlaybackFrame.LayerURLs {
        switch assetPaths {
        case .main(let path):
            guard let pathURL = imageURL(path: path, animationID: animationID) else {
                throw .frameAssetNotFound(paths: assetPaths.paths)
            }
            return .single(pathURL)

        case .piercing(let fgPath, let bgPath):
            guard let fgPathURL = imageURL(path: fgPath, animationID: animationID),
                  let bgPathURL = imageURL(path: bgPath, animationID: animationID)
            else {
                throw .frameAssetNotFound(paths: assetPaths.paths)
            }
            return .double(foreground: fgPathURL, background: bgPathURL)
        }
    }

    private static func imageURL(path: String, animationID: String) -> URL? {
        Bundle.module.url(
            forResource: (path as NSString).deletingPathExtension,
            withExtension: (path as NSString).pathExtension,
            subdirectory: "\(resourceFolder)/\(animationID)"
        )
    }
}
