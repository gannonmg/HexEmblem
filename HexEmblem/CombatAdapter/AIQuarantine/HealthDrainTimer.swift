//
//  HealthDrainTimer.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/11/26.
//

protocol HealthDrainTimer {
    static func drainHealth(
        amount damage: Int,
        reduceHealthAction: () -> Void
    ) async
}

/// Classic, stepped drain feeling timer. Good for full screen animations.
enum GBAHealthDrainer: HealthDrainTimer {
    private static let frameDuration: Duration = .seconds(1) / 59.7275
    private static let framesPerHealthPoint = 2
    private static let minimumDrainFrames = 30

    /// `Duration` for draining a single point of damage
    private static let damageDuration: Duration = playbackDuration(frames: framesPerHealthPoint)

    /// The GBA engine drains one HP every 2 frames at ~59.73 fps, and holds the barrier for at
    /// least 30 frames however small the hit — FE8 `EfxHpBar_DeclineToDeath`.
    static func drainHealth(
        amount damage: Int,
        reduceHealthAction: () -> Void
    ) async {
        guard 0 < damage else { return }

        for _ in 0..<damage {
            let sleepDuration = damageDuration / PlaybackDebug.shared.speed
            try? await Task.sleep(for: sleepDuration)
            reduceHealthAction()
        }

        let holdFrames = remainingDrainFrames(damage: damage)
        let holdTime = playbackDuration(frames: holdFrames) / PlaybackDebug.shared.speed
        try? await Task.sleep(for: holdTime)
    }

    private static func playbackDuration(frames: Int) -> Duration {
        return frameDuration * frames
    }

    private static func remainingDrainFrames(damage: Int) -> Int {
        let holdFrames = minimumDrainFrames - damage * Int(framesPerHealthPoint)
        return max(0, holdFrames)
    }
}

/// Steady drain across the time of the attack.
///
/// Smoother feel. Good option for animating a quick Combat on the map if animations are disabled.
enum ModernHealthDrainer: HealthDrainTimer {
    /// Scaled by the debug speed so slow-motion slows the bar too.
    private static var drainTickDuration: Duration {
        .milliseconds(40) / Double(PlaybackDebug.shared.speed)
    }

    static func drainHealth(
        amount damage: Int,
        reduceHealthAction: () -> Void
    ) async {
        guard 0 < damage else { return }
        for _ in 0..<damage {
            reduceHealthAction()
            try? await Task.sleep(for: Self.drainTickDuration)
        }
    }
}
