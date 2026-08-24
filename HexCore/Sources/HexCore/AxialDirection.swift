//
//  AxialDirection.swift
//  HexCore
//
//  Created by Matt Gannon on 8/23/26.
//

import Foundation

public enum AxialDirection: CaseIterable {
    case qPlusRMinus    // ( 1, -1)
    case qPlus          // ( 1,  0)
    case rPlus          // ( 0,  1)
    case qMinusRPlus    // (-1,  1)
    case qMinus         // (-1,  0)
    case rMinus         // ( 0, -1)

    public var offsetCoordinate: AxialCoordinate {
        switch self {
        case .qPlusRMinus: AxialCoordinate(q: 1, r: -1)
        case .qPlus: AxialCoordinate(q: 1, r: 0)
        case .rPlus: AxialCoordinate(q: 0, r: 1)
        case .qMinusRPlus: AxialCoordinate(q: -1, r: 1)
        case .qMinus: AxialCoordinate(q: -1, r: 0)
        case .rMinus: AxialCoordinate(q: 0, r: -1)
        }
    }
}
