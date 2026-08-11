//
//  CombatPlaybackScriptBuilder.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/9/26.
//

import BAPlayback
import CombatModels
import GameModels

final class CombatPlaybackScriptBuilder {

    private let config: Config
    private let initiatorEntry: BACatalog.Entry
    private let responderEntry: BACatalog.Entry

    /// One manifest decode per (entry, mode) instead of one per strike.
    private var eventCache: [String: [BAPlaybackEvent]] = [:]

    // MARK: - Init
    /// A combatant doesn't change weapons mid-exchange, so both entries resolve once.
    init(config: Config) throws {
        self.config = config
        self.initiatorEntry = try BattleAnimationResolver.entry(request: config.entryRequest(for: .initiator))
        self.responderEntry = try BattleAnimationResolver.entry(request: config.entryRequest(for: .responder))
    }

    // MARK: - Build
    func buildScript(from summary: CombatSummary) throws -> CombatPlaybackScript {
        var beats: [CombatPlaybackScript.Beat] = []
        var defeated: CombatRole?

        for event in summary.events {
            switch event {
            case .strike(let strike):
                beats.append(try beat(for: strike))
            case .defeat(let role):
                defeated = role
            }
        }
        let idleMode = BattleAnimationResolver.idleMode(at: config.range)

        let initiatorSide = CombatPlaybackScript.Side(
            role: .initiator,
            startingHealth: config.initiator.initialHealth,
            idleEvents: try playbackEvents(for: .initiator, mode: idleMode)
        )

        let responderSide = CombatPlaybackScript.Side(
            role: .responder,
            startingHealth: config.responder.initialHealth,
            idleEvents: try playbackEvents(for: .responder, mode: idleMode)
        )

        return CombatPlaybackScript(
            initiator: initiatorSide,
            responder: responderSide,
            beats: beats,
            defeated: defeated
        )
    }

    // MARK: - Helpers
    private func beat(for strike: CombatStrike) throws -> CombatPlaybackScript.Beat {
        let attackerMode = BattleAnimationResolver.attackerMode(for: strike.result, at: config.range)
        let defenderMode = BattleAnimationResolver.defenderMode(for: strike.result, at: config.range)

        let attackerEvents = try playbackEvents(for: strike.strikerRole, mode: attackerMode)
        let defenderEvents = try playbackEvents(for: strike.receiverRole, mode: defenderMode)

        return CombatPlaybackScript.Beat(
            attacker: strike.strikerRole,
            attackerEvents: attackerEvents,
            defenderEvents: defenderEvents,
            damage: strike.totalDamage,
            defenderRemainingHealth: strike.receiverRemainingHealth
        )
    }

    private func playbackEvents(for role: CombatRole, mode: BAModeID) throws -> [BAPlaybackEvent] {
        let entry = catalogEntry(for: role)
        let key = "\(entry.id)#\(mode)"

        // Check if we've already generated this entry
        if let cached = eventCache[key] { return cached }

        // Otherwise, process it fresh and add it to our cache
        let resolved = try BAProcessedAnimationStore.playableEvents(entry: entry, mode: mode)
        eventCache[key] = resolved
        return resolved
    }

    private func catalogEntry(for role: CombatRole) -> BACatalog.Entry {
        switch role {
        case .initiator: initiatorEntry
        case .responder: responderEntry
        }
    }
}
