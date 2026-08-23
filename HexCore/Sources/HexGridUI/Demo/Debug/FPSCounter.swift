//
//  FPSCounter.swift
//  HexCore
//
//  Created by Matt Gannon on 8/23/26.
//

import SwiftUI
import QuartzCore

@Observable
final class FPSCounter: NSObject {
    private(set) var fps: Double = 0

    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0

    override init() {
        super.init()
        start()
    }

    private func start() {
        let link = CADisplayLink(target: self, selector: #selector(recordFrame))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    @objc private func recordFrame(_ link: CADisplayLink) {
        guard lastTimestamp != 0 else {
            lastTimestamp = link.timestamp
            return
        }

        frameCount += 1
        let elapsed = link.timestamp - lastTimestamp
        guard elapsed >= 1.0 else { return }

        fps = Double(frameCount) / elapsed
        frameCount = 0
        lastTimestamp = link.timestamp
    }

    deinit {
        displayLink?.invalidate()
    }
}

struct FPSDisplay: View {
    @State private var counter = FPSCounter()

    var body: some View {
        Text("FPS: \(counter.fps, specifier: "%.1f")")
            .monospaced()
    }
}
