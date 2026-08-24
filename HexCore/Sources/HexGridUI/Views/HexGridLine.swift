//
//  HexGridLine.swift
//  HexCore
//
//  Created by Matt Gannon on 8/23/26.
//

import SwiftUI

public struct HexGridLine {
    public var shading: GraphicsContext.Shading
    public var width: CGFloat

    public init(
        shading: GraphicsContext.Shading = .color(.black.opacity(0.25)),
        width: CGFloat = 3
    ) {
        self.shading = shading
        self.width = width
    }
}
