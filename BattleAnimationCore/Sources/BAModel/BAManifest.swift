//
//  BAManifest.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/5/26.
//

import Foundation

/// The manifest of what is in a processed animation's Resource folder.
/// Created during animation import.
/// Referenced during asset retrieval.
public struct BAManifest: Codable, Sendable {
    public let id: String
    public let spriteSet: BASpriteSet
    public let variant: BAVariant
    public let sourceScript: String
    public let renderSize: FrameSize
    public let frameAssets: [Frame.Asset]
    public let timelines: [Timeline]
    public let paletteTable: [RGBA]
    public let warnings: [String]

    // MARK: - Init
    public init(
        id: String,
        spriteSet: BASpriteSet,
        variant: BAVariant,
        sourceScript: String,
        renderSize: FrameSize,
        frameAssets: [Frame.Asset],
        timelines: [Timeline],
        paletteTable: [RGBA],
        warnings: [String]
    ) {
        self.id = id
        self.spriteSet = spriteSet
        self.variant = variant
        self.sourceScript = sourceScript
        self.renderSize = renderSize
        self.frameAssets = frameAssets
        self.timelines = timelines
        self.paletteTable = paletteTable
        self.warnings = warnings
    }
}

public enum AnimationLayer<T: Codable & Sendable>: Codable, Sendable {
    case single(T)
    case dual(foreground: T, background: T)
}

// MARK: - BAManifest.Frame
extension BAManifest {
    public enum Frame {
        public typealias PathStorage = AnimationLayer<String>

        public struct Asset: Codable, Sendable {

            public let sourceFile: String
            public let layerType: AnimationLayer<String>
            public let paletteLayers: AnimationLayer<String>

            public init(
                sourceFile: String,
                layerType: AnimationLayer<String>,
                paletteLayers: AnimationLayer<String>
            ) {
                self.sourceFile = sourceFile
                self.layerType = layerType
                self.paletteLayers = paletteLayers
            }
        }

        public struct Event: Codable, Sendable {
            public let sourceFile: String
            public let duration: TimeInterval

            public init(sourceFile: String, duration: TimeInterval) {
                self.sourceFile = sourceFile
                self.duration = duration
            }
        }
    }
}

extension BAManifest.Frame.PathStorage {
    public var paths: [String] {
        switch self {
        case .single(let path): [path]
        case .dual(let foreground, let background): [foreground, background]
        }
    }
}

// MARK: - BAManifest.Timeline
extension BAManifest {
    public struct Timeline: Codable, Sendable {
        public let modeID: BAModeID
        public let title: String?
        public let events: [Event]

        public enum Event: Codable, Sendable {
            case frame(Frame.Event)
            case command(BAScript.Command)
        }

        public init(
            modeID: BAModeID,
            title: String?,
            events: [Event]
        ) {
            self.modeID = modeID
            self.title = title
            self.events = events
        }
    }
}
