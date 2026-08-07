//
//  Interactable.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/6/26.
//

import Foundation
import SpriteKit

/// A protocol that allows clicks or touches to be passed through from the coresponding OS event.
protocol Interactable {
    func interactionBegan(at location: CGPoint)
    func interactionEnded(at location: CGPoint)
}
