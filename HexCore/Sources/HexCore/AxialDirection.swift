//
//  AxialDirection.swift
//  HexCore
//
//  Created by Matt Gannon on 8/23/26.
//

import Foundation

public enum AxialDirection: CaseIterable, Hashable, Sendable {
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

extension AxialDirection {
    /// True when a cell always sorts before its neighbor in this direction under the
    /// `(r, q)` ordering used for edge dedupe. Derived from the offset, not hardcoded.
    public var ownsSharedEdge: Bool {
        let offset = offsetCoordinate
        return (0, 0) < (offset.r, offset.q)
    }
}
