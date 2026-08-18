//
//  GBAHealthDrainer.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/12/26.
//

import GameDebug

public enum GBAClock {
    public static let frameDuration: Duration = .seconds(1) / 59.7275

    public static func playbackDuration(ticks: Int) -> Duration {
        return frameDuration * ticks / PlaybackDebug.shared.speed
    }
}

/// Classic, stepped drain feeling timer. Good for full screen animations.
public enum GBAHealthDrainer: HealthDrainTimer {

    private static let ticksPerHealthPoint = 2
    private static let minimumDrainTicks = 30

    /// `Duration` for draining a single point of damage
    private static let damageDuration: Duration = GBAClock.playbackDuration(ticks: ticksPerHealthPoint)

    /// The GBA engine drains one HP every 2 frames at ~59.73 fps, and holds the barrier for at
    /// least 30 frames however small the hit — FE8 `EfxHpBar_DeclineToDeath`.
    public static func drainHealth(
        amount damage: Int,
        reduceHealthAction: @MainActor () -> Void
    ) async {
        guard 0 < damage else { return }

        for _ in 0..<damage {
            let sleepDuration = damageDuration / PlaybackDebug.shared.speed
            try? await Task.sleep(for: sleepDuration)
            await reduceHealthAction()
        }

        let holdTicks = remainingDrainTicks(damage: damage)
        let holdTime = GBAClock.playbackDuration(ticks: holdTicks) / PlaybackDebug.shared.speed
        try? await Task.sleep(for: holdTime)
    }

    private static func remainingDrainTicks(damage: Int) -> Int {
        let holdFrames = minimumDrainTicks - damage * Int(ticksPerHealthPoint)
        return max(0, holdFrames)
    }
}
