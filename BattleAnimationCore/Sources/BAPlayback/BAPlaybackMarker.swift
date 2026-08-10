//
//  BAPlaybackMarker.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/7/26.
//

import BAModel
import Foundation

public enum BAPlaybackEvent: Equatable, Sendable {
    case frame(BAPlaybackFrame)
    case marker(BAPlaybackEvent.Marker)
}

extension [BAPlaybackEvent] {
    /// Index of the beat where damage lands.
    ///
    /// Animators signal the hit one of two ways and never both: an impact opcode, or `C05`
    /// releasing the weapon's effect. The split is close to even across FE-Repo, so the
    /// `castSpell` fallback is load-bearing, not an edge case. Where impact markers do appear
    /// they often come in pairs bracketing a hit-flash — the first is the real hit.
    public var firstDamageBeatIndex: Int? {
        firstIndex(of: .impact) ?? firstIndex(of: .castSpell)
    }

    private func firstIndex(of wantedMarker: BAPlaybackEvent.Marker) -> Int? {
        firstIndex {
            guard case .marker(let marker) = $0 else { return false }
            return wantedMarker == marker
        }
    }
}

// MARK: BAPlaybackEvent.Marker
extension BAPlaybackEvent {
    public enum Marker: Equatable, Sendable {
        case impact
        case castSpell
        case armHPDepletion
        case waitForHPDepletion
        case beginOpponentTurn
        case startAttack
        case startDodge
        case endDodge
        case playSound   // SFE-glossed codes → drives audio engine
        case screenEffect // vibration/flash/particle-glossed codes → drives visual layer
        case unrecognized(String) // no reliable gloss (C17, C53–55, C64, C71, C72, CC0, CDC, etc.)}
    }
}

extension BAPlaybackEvent.Marker {
    public init(code: String) {
        self = Self.byOpcode[code] ?? .unrecognized(code)
    }

    /// Opcode → meaning, per the FEBuilderGBA `battleanime_85command_FE8` tables.
    ///
    /// The animator comments carried on `BAScript.Command` are never consulted — they are
    /// wrong often enough to be worse than useless (`C01` is commented "NOP" in every one of
    /// its 64,791 occurrences and actually means wait-for-HP-deplete).
    private static let byOpcode: [String: BAPlaybackEvent.Marker] = {
        var table: [String: BAPlaybackEvent.Marker] = [:]

        func map(_ kind: BAPlaybackEvent.Marker, _ codes: String...) {
            for code in codes {
                table[code] = kind
            }
        }

        // Structural — these drive timing and must be right.
        map(.impact, "C08", "C09", "C0A", "C0B", "C0C", "C1A")
        map(.castSpell, "C05")
        map(.armHPDepletion, "C04")
        map(.waitForHPDepletion, "C01")
        map(.beginOpponentTurn, "C06")
        map(.endDodge, "C0D")
        map(.startDodge, "C02", "C0E", "C18")
        map(.startAttack, "C03", "C07")

        // Screen effects — vibration, flash, and scripted particle/prop animations.
        map(
            .screenEffect,
            "C14", "C15", "C26", "C27", "C2C", "C2E", "C2F", "C30",
            "C31", "C32", "C39", "C3D", "C47", "C4E", "C50", "C51"
        )

        // SFE-glossed codes — playable sounds.
        map(
            .playSound,
            "C19", "C1B", "C1C", "C1D", "C1E", "C1F", "C20", "C21", "C22", "C23",
            "C24", "C25", "C28", "C2B", "C33", "C34", "C35", "C36", "C37", "C38",
            "C3A", "C3B", "C3C", "C3E", "C3F", "C42", "C43", "C44", "C45", "C46",
            "C49", "C4A", "C4B", "C4C", "C4D", "C4F", "C56", "C57", "C58", "C59",
            "C5A", "C5B", "C5C", "C5D", "C5E", "C5F", "C60", "C61", "C62", "C63",
            "C65", "C66", "C67", "C68", "C6A", "C6B", "C6C", "C6D", "C6F", "C73",
            "C74", "C75", "C76", "C77", "C78", "C79", "C7A", "C7B"
        )

        return table
    }()
}
