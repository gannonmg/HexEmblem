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

        let corners = cornerAngles().map { center.offset(distance: radius, angle: $0) }

        path.move(to: corners[0])
        corners[1..<6].forEach { point in
            path.addLine(to: point)
        }
        path.closeSubpath()

        return path
    }

    private var interpolatedAspectRatio: CGFloat {
        let pointy = HexGridGeometry.Constants.pointyHexSizeRatio
        let flat = HexGridGeometry.Constants.flatHexSizeRatio
        return interpolatedValue(pointy: pointy, flat: flat)
    }

    private var interpolatedRadiusRatio: CGFloat {
        let pointy = HexGridGeometry.Constants.inradius // pointy top width is edge to edge
        let flat = HexGridGeometry.Constants.circumradius // flat top width is point to point
        return interpolatedValue(pointy: pointy, flat: flat)
    }

    // Store computed & ordered corners for path calculations
    private static let pointyAngles = HexGridGeometry.Constants.directions.map { $0.angle(for: .pointyTop) }
    private static let flatAngles = HexGridGeometry.Constants.directions.map { $0.angle(for: .flatTop) }
    private static let anglePairs = zip(pointyAngles, flatAngles)

    /// Corners sit halfway between adjacent neighbor headings, so the drawn shape comes from
    /// the same direction table that finds neighbors. Flat and pointy headings differ by
    /// exactly 30°, which is what `hexRotationPercent` interpolates between.
    private func cornerAngles() -> [Angle] {
        Self.anglePairs.map { .radians(interpolatedValue(pointy: $0.radians, flat: $1.radians) + .pi / 6) }
    }

    private func interpolatedValue(pointy: CGFloat, flat: CGFloat) -> CGFloat {
        flat + (pointy - flat) * hexRotationPercent
    }
}

extension AxialDirection {
    /// Heading toward this neighbor, straight from the pixel math.
    func angle(for orientation: HexOrientation) -> Angle {
        let point = HexScreenMath.hexToCartesianPoint(
            axialCoordinate: offsetCoordinate,
            orientation: orientation
        )
        return Angle(radians: atan2(point.y, point.x))
    }
}

extension CGPoint {
    /// The point `distance` away at `angle`, measured from the +x axis.
    func offset(distance: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: x + distance * cos(angle.radians),
            y: y + distance * sin(angle.radians)
        )
    }
}
