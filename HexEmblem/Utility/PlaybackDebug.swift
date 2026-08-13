//
//  PlaybackDebug.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/11/26.
//

import Observation
import SpriteKit

/// Temporary playback inspector. A singleton on purpose — nothing has to be threaded through
/// a scene or node init, so this file plus its three call sites delete cleanly.
@Observable
final class PlaybackDebug {

    static let shared = PlaybackDebug()

    var speed: Double = 1

    private(set) var layers: [String: LayerReport] = [:]

    func record(_ report: LayerReport, for nodeName: String) {
        layers[nodeName] = report
    }

    struct LayerReport {
        let frameIndex: Int
        let isDoubleLayered: Bool
        let frontZ: CGFloat
        let backZ: CGFloat

        var summary: String {
            let layering = isDoubleLayered ? "front+back" : "front only"
            let back = String(format: "%.2f", backZ)
            let front = String(format: "%.2f", frontZ)

            return "f\(frameIndex)  \(layering)  z \(back) → \(front)"
        }
    }
}

extension SKNode {
    /// `zPosition` is relative to the parent, so a node's real sort key is the sum up the tree.
    var accumulatedZPosition: CGFloat {
        sequence(first: self, next: { $0.parent })
            .reduce(0) { $0 + $1.zPosition }
    }
}
