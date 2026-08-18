//
//  HealthDrainTimer.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/11/26.
//

import GameDebug

protocol HealthDrainTimer {
    static func drainHealth(
        amount damage: Int,
        reduceHealthAction: @MainActor () -> Void
    ) async
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
        reduceHealthAction: @MainActor () -> Void
    ) async {
        guard 0 < damage else { return }
        for _ in 0..<damage {
            await reduceHealthAction()
            try? await Task.sleep(for: Self.drainTickDuration)
        }
    }
}
