//
//  Hexagon.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import HexCore
import SwiftUI

public struct Hexagon: Shape, HexShapeProviding {
    /// A percent represented by a float `0...1` to aide in interpolating the rotation angle for animation
    /// `0` represents no rotation and a flat top hex
    /// `1` represents 30º rotation and a pointy top hex
    private var hexRotationPercent: CGFloat
    public var animatableData: CGFloat {
        get { hexRotationPercent }
        set { hexRotationPercent = newValue }
    }

    public init(orientation: HexOrientation) {
        self.hexRotationPercent = switch orientation {
        case .flatTop: 0
        case .pointyTop: 1
        }
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let width = min(rect.width, rect.height * interpolatedAspectRatio)
        let radius = width / interpolatedRadiusRatio

        let corners = HexGridGeometry.fractionalCornerOffsets(for: .pointyTop)
            .map { $0 * radius }

        path.move(to: corners[0])
        corners[1..<6].forEach { point in
            path.addLine(to: point)
        }
        path.closeSubpath()

        return path
    }

    private var interpolatedAspectRatio: CGFloat {
        let pointy = Self.aspectRatio(for: .pointyTop)
        let flat = Self.aspectRatio(for: .flatTop)
        return flat + (pointy - flat) * hexRotationPercent
    }

    /// Pointy top inscribes edge-to-edge across the width; flat top inscribes point-to-point.
    private var interpolatedRadiusRatio: CGFloat {
        Self.pointToPointRatio + (Self.edgeToEdgeRatio - Self.pointToPointRatio) * hexRotationPercent
    }

    /// Corners sit halfway between adjacent neighbor headings, so the drawn shape comes from
    /// the same direction table that finds neighbors. Flat and pointy headings differ by
    /// exactly 30°, which is what `hexRotationPercent` interpolates between.
    private func cornerAngle(facing direction: AxialDirection) -> Angle {
        let flat = direction.angle(for: .flatTop).radians
        let pointy = direction.angle(for: .pointyTop).radians
        return .radians(flat + (pointy - flat) * hexRotationPercent + .pi / 6)
    }
}
