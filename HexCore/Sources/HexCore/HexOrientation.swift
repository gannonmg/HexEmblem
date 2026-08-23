//
//  HexOrientation.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import Foundation

public enum HexOrientation: Sendable {
    case pointyTop, flatTop

    public init(isPointy: Bool) {
        self = isPointy ? .pointyTop : .flatTop
    }
}
