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
public struct BAManifest: Codable {
    public let id: String
    public let sourceScript: String
    public let renderSize: FrameSize
    public let frameAssets: [Frame.Asset]
    public let timelines: [Timeline]
    public let preservedPalette: [RGBA]
    public let warnings: [String]

    // MARK: - Init
    public init(id: String, sourceScript: String, renderSize: FrameSize, frameAssets: [Frame.Asset], timelines: [Timeline], preservedPalette: [RGBA], warnings: [String]) {
        self.id = id
        self.sourceScript = sourceScript
        self.renderSize = renderSize
        self.frameAssets = frameAssets
        self.timelines = timelines
        self.preservedPalette = preservedPalette
        self.warnings = warnings
    }
}

// MARK: - BAManifest.Frame
extension BAManifest {
    public enum Frame {
        public struct Asset: Codable {
            public let sourceFile: String
            public let layerType: LayerType

            public init(sourceFile: String, layerType: LayerType) {
                self.sourceFile = sourceFile
                self.layerType = layerType
            }
        }

        public enum LayerType: Codable {
            case main(path: String)
            case piercing(foreground: String, background: String)

            public var paths: [String] {
                switch self {
                case .main(let path): [path]
                case .piercing(let foreground, let background): [foreground, background]
                }
            }
        }

        public struct Event: Codable {
            public let sourceFile: String
            public let duration: TimeInterval

            public init(sourceFile: String, duration: TimeInterval) {
                self.sourceFile = sourceFile
                self.duration = duration
            }
        }
    }
}

// MARK: - BAManifest.Timeline
extension BAManifest {
    public struct Timeline: Codable {
        public let modeID: BAModeID
        public let rawModeNumber: Int
        public let title: String?
        public let events: [Event]

        public enum Event: Codable {
            case frame(Frame.Event)
            case command(BAScript.Command)
        }

        public init(modeID: BAModeID, rawModeNumber: Int, title: String?, events: [Event]) {
            self.modeID = modeID
            self.rawModeNumber = rawModeNumber
            self.title = title
            self.events = events
        }
    }
}
