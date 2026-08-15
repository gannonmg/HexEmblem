//
//  CombatPlaybackAdapter.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/11/26.
//

import BAPlayback
import CombatModels
import Foundation
import GameModels

// What this CombatPlaybackAdapter (CPA) needs:
//      - CombatSummary
//      - Playback frames per event in summary
//
// The surface of this package will accept a playback summary, speak with the BACore, and return a display SpriteKit CombatScene


// MARK: - CombatPlaybackAdapter
public final class CombatPlaybackAdapter {

    private var eventCache: [String: [BAPlaybackEvent]] = [:]

    // MARK: Parameters
    private let config: Config
    private let initiatorEntry: BACatalog.Entry
    private let responderEntry: BACatalog.Entry

    public init(config: Config) throws {
        self.config = config

        let initiatorRequest = config.entryRequest(for: .initiator)
        self.initiatorEntry = try AnimationLookup.entry(request: initiatorRequest)

        let responderRequest = config.entryRequest(for: .responder)
        self.responderEntry = try AnimationLookup.entry(request: responderRequest)
    }

    // MARK: Public access surface
    public func adapt(_ summary: CombatSummary) throws -> Script {
        var beats: [Script.Beat] = []
        var defeatedRole: CombatRole?

        for event in summary.events {
            switch event {
            case .strike(let strike):
                let beat = try beat(for: strike)
                beats.append(beat)
            case .defeat(let role):
                defeatedRole = role
            }
        }


        return Script(
            startingHealth: startingHealth(),
            idleEvents: try idleEvents(),
            beats: beats,
            defeated: defeatedRole
        )
    }

    private func startingHealth() -> CombatantDatum<UnitHealthStatus> {
        return CombatantDatum<UnitHealthStatus> { role in
            switch role {
            case .initiator: config.initiator.healthStatus
            case .responder: config.responder.healthStatus
            }
        }
    }

    private func idleEvents() throws -> CombatantDatum<[BAPlaybackEvent]> {
        let idleMode = AnimationLookup.idleMode(at: config.range)
        return try .init { role in
            try playbackEvents(for: role, mode: idleMode)
        }
    }

    // MARK: Helpers
    private func beat(for strike: CombatStrike) throws -> Script.Beat {
        let strikerMode = AnimationLookup.strikerMode(
            strike: strike.result, range: config.range
        )
        let receiverMode = AnimationLookup.receiverMode(
            strike: strike.result, range: config.range
        )

        let strikerEvents = try playbackEvents(
            for: strike.strikerRole, mode: strikerMode
        )
        let receiverEvents = try playbackEvents(
            for: strike.receiverRole, mode: receiverMode
        )

        return Script.Beat(
            strikerRole: strike.strikerRole,
            strikerEvents: strikerEvents,
            receiverEvents: receiverEvents,
            damage: strike.totalDamage,
            receiverRemainingHealth: strike.receiverRemainingHealth
        )
    }

    private func playbackEvents(
        for role: CombatRole,
        mode: BAModeID
    ) throws -> [BAPlaybackEvent] {
        // Decide which combatant we are searching for
        let entry = switch role {
        case .initiator: initiatorEntry
        case .responder: responderEntry
        }

        // Create the appropriate cache key, and check the cache
        let key = "\(entry.id)#\(mode.rawValue)"
        if let cached = eventCache[key] { return cached }

        // If we did not have it in the cache,
        //      load them and add them to the cache
        let events = try BAProcessedAnimationStore
            .playableEvents(entry: entry, mode: mode)
        eventCache[key] = events
        return events
    }
}

extension CombatPlaybackAdapter {
    /// Configuration for building a `CombatPlaybackAdapter.Script` via a `BACatalog`
    ///
    /// - Parameters:
    ///     - initiator: The attacking unit (left side)
    ///     - responder: The defending unit (right side)
    ///     - range: The distance between the two units
    public struct Config {
        public let initiator: Unit
        public let responder: Unit
        public let range: Int
        public let catalog: BACatalog

        public init(initiator: Unit, responder: Unit, range: Int, catalog: BACatalog) {
            self.initiator = initiator
            self.responder = responder
            self.range = range
            self.catalog = catalog // try BAProcessedAnimationStore.catalog()
        }
    }

    public struct Script: Identifiable {
        public let id = UUID()
        public let startingHealth: CombatantDatum<UnitHealthStatus>
        let idleEvents: CombatantDatum<[BAPlaybackEvent]>
        let beats: [Beat]
        let defeated: CombatRole?
    }
}

extension CombatPlaybackAdapter.Config {
    public struct Unit {
        let animationID: AnimationID
        let healthStatus: UnitHealthStatus
        let weaponSlot: BAWeaponSlot
        let weaponIsMagical: Bool

        public init(characterUnit: CharacterUnit, range: Int) {
            self.animationID = characterUnit.animationID
            self.healthStatus = characterUnit.healthStatus
            self.weaponSlot = characterUnit.weapon.animationSlot(atRange: range)
            self.weaponIsMagical = characterUnit.weapon.hasMagicalDamage
        }
    }
}

extension CombatPlaybackAdapter.Config {
    func entryRequest(
        for combatRole: CombatRole,
    ) -> AnimationLookup.EntryRequest {
        let unit = switch combatRole {
        case .initiator: initiator
        case .responder: responder
        }

        return AnimationLookup.EntryRequest(
            animationID: unit.animationID,
            weaponSlot: unit.weaponSlot,
            weaponIsMagical: unit.weaponIsMagical,
            range: range,
            catalog: catalog
        )
    }
}

extension CombatPlaybackAdapter.Script {
    /// A beat represents one phase of a strike
    ///
    /// ie 1 each: the first part of a swing, the delay as the receiver's
    /// health drains, finish the swing, etc
    struct Beat {
        let strikerRole: CombatRole
        let strikerEvents: [BAPlaybackEvent]
        let receiverEvents: [BAPlaybackEvent]
        let damage: Int
        let receiverRemainingHealth: Int
    }
}
