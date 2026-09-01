//
//  HexGeometry+Constants.swift
//  HexCore
//
//  Created by Matt Gannon on 9/1/26.
//

import Foundation

extension HexGeometry { public enum Constants {} }

extension HexGeometry.Constants {
    // Small computation save. Otherwise, allCases must build its array with each call.
    // Measurable if small impact when displaying ~1000+ hexes.
    public static let directions = AxialDirection.allCases
    /// 2
    public static let circumradius: CGFloat = 2
    /// sqrt(3)
    public static let inradius: CGFloat = sqrt(3)

    // Calculated
    public static let fractionalPointySize = CGSize(width: inradius, height: circumradius)
    public static let fractionalFlatSize = CGSize(width: circumradius, height: inradius)

    public static let pointyHexSizeRatio: CGFloat = {
        let size = fractionalPointySize
        return size.width / size.height
    }()

    public static let flatHexSizeRatio: CGFloat = {
        let size = fractionalFlatSize
        return size.width / size.height
    }()

    // Generic access
    public static func fractionalSize(for orientation: HexOrientation) -> CGSize {
        switch orientation {
        case .pointyTop: fractionalPointySize
        case .flatTop: fractionalFlatSize
        }
    }

    public static func fractionalSizeRatio(for orientation: HexOrientation) -> CGFloat {
        switch orientation {
        case .pointyTop: pointyHexSizeRatio
        case .flatTop: flatHexSizeRatio
        }
    }
}
