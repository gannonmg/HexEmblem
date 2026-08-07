//
//  InteractiveScene.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/6/26.
//

import Foundation
import SpriteKit

class InteractiveScene: SKScene, Interactable {
    func interactionBegan(at location: CGPoint) {}
    func interactionEnded(at location: CGPoint) {}
}

#if os(OSX)
// Mouse-based event handling
extension InteractiveScene {
    open override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        interactionBegan(at: location)
    }

    open override func mouseDragged(with event: NSEvent) {}
    open override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        interactionEnded(at: location)
    }
}
#endif

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension InteractiveScene {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        interactionBegan(at: location)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        interactionEnded(at: location)
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
}
#endif
