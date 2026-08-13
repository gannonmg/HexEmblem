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
