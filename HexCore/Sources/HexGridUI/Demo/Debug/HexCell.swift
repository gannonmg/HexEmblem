//
//  HexCell.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import HECommon
import HexCore
import SwiftUI

public struct ColoredHexCell: Identifiable, AxialCoordinateProviding {
    public var id: Int { axialCoordinate.hashValue }
    public let axialCoordinate: AxialCoordinate
    public let color: Color

    init(axialCoordinate: AxialCoordinate, span: Int) {
        self.axialCoordinate = axialCoordinate
        self.color = Self.polarColor(for: axialCoordinate, span: span)
    }

    /// Maps the signed cube coordinates straight onto RGB. Because `q + r + s == 0` for every
    /// hex, the three channels always sum to 1.5 — so the disk reads as a six-way hue wheel,
    /// one primary or secondary per hex direction, neutral gray at the origin.
    private static func color(for coordinate: AxialCoordinate, span: Int) -> Color {
        guard span > 0 else { return .gray }

        func normalized(_ value: Int) -> CGFloat {
            (CGFloat(value) + CGFloat(span)/2) / span
        }

        return Color(
            red: normalized(coordinate.q) * 0.7,
            green: normalized(coordinate.r) * 0.7,
            blue: normalized(coordinate.s) * 0.7
        )
    }

    private static func polarColor(for coordinate: AxialCoordinate, span: Int) -> Color {
        guard span > 0 else { return .gray }
        let origin = AxialCoordinate(q: 0, r: 0)
        let ring = CGFloat(coordinate.distance(from: origin))

        // Screen-space angle, so the hue wheel lines up with what you actually see.
        let x = sqrt(3) * (CGFloat(coordinate.q) + CGFloat(coordinate.r) / 2)
        let y = 3 * CGFloat(coordinate.r) / 2
        let turns = atan2(y, x) / (2 * .pi)

        return Color(
            hue: (turns + 1).truncatingRemainder(dividingBy: 1),
            saturation: ring / CGFloat(span) / 2,
            brightness: 0.775
        )
    }
}
