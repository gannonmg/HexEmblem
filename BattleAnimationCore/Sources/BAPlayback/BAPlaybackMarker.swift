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

// MARK: BAPlaybackEvent.Marker
extension BAPlaybackEvent {
    public enum Marker: Equatable, Sendable {
        case waitForHPDepletion      // C01
        case waitForDodgeStart       // C02
        case waitForForwardDodge     // C18
        case waitForAttackStart      // C03
        case armHPDepletion          // C04  — barrier, and what releases the opponent's dodge
        case castSpell               // C05  — barrier
        case unmodelledBarrier(String) // C13, C2D, C39, C52
        case beginDodgeFrames        // C0E  — signal, not a barrier
        case startAttackEffects      // C07  — signal, not a barrier
        case beginOpponentRound      // C06  — signal: releases the opponent's next round
        case endDodge                // C0D
        case impact                  // C1A, C08–C0C
        case playSound
        case screenEffect
        case unrecognized(String)
    }
}

extension BAPlaybackEvent.Marker {
    /// The ten opcodes `animedrv.c` rewinds the script cursor on. A cursor that reaches one
    /// of these re-executes it every frame until something clears its release flag.
    public var isBarrier: Bool {
        switch self {
        case .waitForHPDepletion,
                .waitForDodgeStart,
                .waitForForwardDodge,
                .waitForAttackStart,
                .armHPDepletion,
                .castSpell,
                .unmodelledBarrier:
            return true
        default:
            return false
        }
    }
}

extension BAPlaybackEvent.Marker {
    public init(code: String) {
        self = Self.byOpcode[code] ?? .unrecognized(code)
    }

    /// Opcode → meaning, per the FEBuilderGBA `battleanime_85command_FE8` tables, with the
    /// barrier/signal split taken from the FE8 decompilation: `animedrv.c` rewinds the script
    /// cursor on exactly ten opcodes, and `banim-main.c` holds each one until a flag the other
    /// combatant sets clears it.
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

        // Barriers — the cursor spins here until its release flag is set.
        map(.waitForHPDepletion, "C01")
        map(.waitForDodgeStart, "C02")
        map(.waitForAttackStart, "C03")
        map(.armHPDepletion, "C04")
        map(.castSpell, "C05")
        map(.waitForForwardDodge, "C18")

        // Barriers with no modelled release condition. Absent from FE-Repo except C2D (12)
        // and C52 (1), but an interpreter that walks past them isn't following the script.
        for code in ["C13", "C2D", "C39", "C52"] {
            table[code] = .unmodelledBarrier(code)
        }

        // Signals — queued for the outer layer, never block the cursor.
        map(.impact, "C08", "C09", "C0A", "C0B", "C0C", "C1A")
        map(.beginOpponentRound, "C06")
        map(.startAttackEffects, "C07")
        map(.beginDodgeFrames, "C0E")
        map(.endDodge, "C0D")

        // Screen effects — vibration, flash, and scripted particle/prop animations.
        map(
            .screenEffect,
            "C14", "C15", "C26", "C27", "C2C", "C2E", "C2F", "C30",
            "C31", "C32", "C3D", "C47", "C4E", "C50", "C51"
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
