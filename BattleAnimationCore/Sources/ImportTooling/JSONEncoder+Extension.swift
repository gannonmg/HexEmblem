//
//  JSONEncoder+Extension.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/3/26.
//

import Foundation

extension JSONEncoder {
    public static var prettyStable: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}
