//
//  FrameSize.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/5/26.
//

import Foundation

public struct FrameSize: Codable, Sendable {
    let width: Int
    let height: Int

    public static let combatFrameSize = FrameSize(width: 240, height: 160)
}
