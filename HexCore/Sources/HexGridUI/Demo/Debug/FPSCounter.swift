import QuartzCore
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@Observable
final class FPSCounter: NSObject {
    private(set) var fps: Double = 0

    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0

    #if canImport(UIKit)
    func start() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(recordFrame))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }
    #elseif canImport(AppKit)
    @MainActor
    func start(attachingTo view: NSView) {
        guard displayLink == nil else { return }
        let link = view.displayLink(target: self, selector: #selector(recordFrame))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }
    #endif

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

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
}

#if canImport(AppKit)
private final class FPSHostView: NSView {
    var counter: FPSCounter?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard window != nil else { return }
        counter?.start(attachingTo: self)
    }
}

private struct DisplayLinkAttachingView: NSViewRepresentable {
    let counter: FPSCounter

    func makeNSView(context: Context) -> FPSHostView {
        let view = FPSHostView()
        view.counter = counter
        return view
    }

    func updateNSView(_ nsView: FPSHostView, context: Context) {}
}
#endif

struct FPSDisplay: View {
    @State private var counter = FPSCounter()

    var body: some View {
        Text("FPS: \(counter.fps, specifier: "%.1f")")
            .monospaced()
            #if canImport(UIKit)
            .task { counter.start() }
            .onDisappear { counter.stop() }
            #elseif canImport(AppKit)
            .background(DisplayLinkAttachingView(counter: counter).frame(width: 0, height: 0))
            .onDisappear { counter.stop() }
            #endif
    }
}
