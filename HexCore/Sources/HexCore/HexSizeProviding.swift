//
//  HexSizeProviding.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import CoreGraphics
import Foundation

public protocol HexSizeProviding: HexShapeProviding {
    var radius: CGFloat { get }
    var orientation: HexOrientation { get }
}

extension HexSizeProviding {
    /// Returns aspect ratio of the frame around the hex, accounting for orientation.
    public var aspectRatio: CGFloat { width / height }

    /// Returns the width of the hex, accounting for orientation.
    public var width: CGFloat { Self.width(radius: radius, orientation: orientation) }

    /// Returns the height of the hex, accounting for orientation.
    public var height: CGFloat { Self.height(radius: radius, orientation: orientation) }

    public var innerRadius: CGFloat {
        Self.innerRadiusRatio * radius
    }

    // MARK: - Static helpers
    public static func width(radius: CGFloat, orientation: HexOrientation) -> CGFloat {
        switch orientation {
        case .pointyTop: edgeToEdgeRatio * radius
        case .flatTop: pointToPointRatio * radius
        }
    }

    public static func height(radius: CGFloat, orientation: HexOrientation) -> CGFloat {
        switch orientation {
        case .pointyTop: pointToPointRatio * radius
        case .flatTop: edgeToEdgeRatio * radius
        }
    }

}
