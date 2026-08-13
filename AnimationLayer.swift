//
//  AnimationLayer.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/11/26.
//

import Foundation

public enum AnimationLayer<T> {
    case single(T)
    case dual(foreground: T, background: T)
}

extension AnimationLayer: Codable where T: Codable {}
extension AnimationLayer: Sendable where T: Sendable {}
