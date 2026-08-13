//
//  BAPlaybackEvent+ArrayExtension.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/12/26.
//

import BAPlayback

extension [BAPlaybackEvent] {
    var frames: [BAPlaybackFrame] {
        compactMap {
            guard case .frame(let frame) = $0 else { return nil }
            return frame
        }
    }

    /// Index of the beat where damage lands.
    ///
    /// Animators signal the hit one of two ways and never both: an impact opcode, or `C05`
    /// releasing the weapon's effect. The split is close to even across FE-Repo, so the
    /// `castSpell` fallback is load-bearing, not an edge case. Where impact markers do appear
    /// they often come in pairs bracketing a hit-flash — the first is the real hit.
    public var firstDamageBeatIndex: Int? {
        firstIndex(of: .impact) ?? firstIndex(of: .castSpell)
    }

    /// Index of the `C01` barrier the attacker blocks on while the defender's HP drains.
    ///
    /// Frames keep playing between the hit and this barrier — 96% of scripted attack timelines
    /// have at least one — so the pose held during the drain is the one *after* the hit, not the
    /// one that lands it.
    public var hpDepletionHoldIndex: Int? {
        guard let firstDamageBeatIndex else { return nil }
        return indices.first { firstDamageBeatIndex < $0 && self[$0] == .marker(.waitForHPDepletion) }
    }

    /// Splits an attacker's stream at the barrier where it waits for the defender's HP to drain,
    /// falling back to the damage beat for the ~1% of scripts with no barrier. Streams with
    /// neither — idles, dodges — come back whole, with an empty follow-through.
    func splitAtHPDepletionHold() -> (windUp: [BAPlaybackEvent], followThrough: [BAPlaybackEvent]) {
        let holdIndex = hpDepletionHoldIndex ?? firstDamageBeatIndex
        guard let holdIndex else { return (self, []) }
        return (Array(self[...holdIndex]), Array(self[(holdIndex + 1)...]))
    }

    // MARK: Helper
    private func firstIndex(of wantedMarker: BAPlaybackEvent.Marker) -> Int? {
        firstIndex {
            guard case .marker(let marker) = $0 else { return false }
            return wantedMarker == marker
        }
    }
}
