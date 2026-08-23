//
//  VelocitySampler.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import CoreGraphics
import Foundation

struct VelocitySampler {
    private struct Sample {
        let time: Date
        let translation: CGSize
    }

    private var samples: [Sample] = []
    private let window: TimeInterval = 0.1

    mutating func record(_ translation: CGSize, at time: Date) {
        samples.append(Sample(time: time, translation: translation))
        samples.removeAll { time.timeIntervalSince($0.time) > window }
    }

    mutating func reset() {
        samples.removeAll()
    }

    /// Points per second averaged over the trailing window. `DragGesture.Value.velocity` reports
    /// the last frame's delta, which reads as garbage — often zero — when the pointer hesitates
    /// before release. Averaging matches what UIKit does and kills the phantom flick.
    var velocity: CGSize {
        guard let first = samples.first, let last = samples.last else { return .zero }
        let elapsed = last.time.timeIntervalSince(first.time)
        guard elapsed > 0 else { return .zero }
        return CGSize(
            width: (last.translation.width - first.translation.width) / elapsed,
            height: (last.translation.height - first.translation.height) / elapsed
        )
    }
}
