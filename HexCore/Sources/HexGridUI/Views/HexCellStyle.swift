//
//  HexCellStyle.swift
//  HexCore
//
//  Created by Matt Gannon on 8/23/26.
//

import SwiftUI

// Temporary thin layer to supply to Canvas before introducing more complex tiles
public struct HexCellStyle {
    public var fill: GraphicsContext.Shading
    public var label: Text?
    public var labelShading: GraphicsContext.Shading

    public init(
        fill: GraphicsContext.Shading,
        label: Text? = nil,
        labelShading: GraphicsContext.Shading = .color(.white)
    ) {
        self.fill = fill
        self.label = label
        self.labelShading = labelShading
    }
}
