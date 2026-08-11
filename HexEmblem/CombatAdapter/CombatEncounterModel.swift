//
//  CombatEncounterModel.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/10/26.
//

import BAPlayback
import CCEvaluator
import CombatModels
import GameModels
import Observation
import SwiftUI

/// Stands in for the battle map: it owns the units that will fight and the health SwiftUI
/// draws for them.
///
/// `CharacterUnit` is a reference type, so `@Observable` can't see its health change. The
/// values here are what the UI reads, and `syncHealth()` is the one place they get pulled
/// back off the units.
@MainActor
@Observable
final class CombatEncounterModel {

    let leftUnit: CharacterUnit
    let rightUnit: CharacterUnit
    private let healthDrainTimer: any HealthDrainTimer.Type

    private(set) var leftHealth: UnitHealthStatus
    private(set) var rightHealth: UnitHealthStatus

    let range: Int

    init(
        leftUnit: CharacterUnit,
        rightUnit: CharacterUnit,
        healthDrainer: any HealthDrainTimer.Type = GBAHealthDrainer.self,
        range: Int
    ) {
        self.leftUnit = leftUnit
        self.rightUnit = rightUnit
        self.leftHealth = leftUnit.healthStatus
        self.rightHealth = rightUnit.healthStatus

        self.healthDrainTimer = healthDrainer
        self.range = range
    }

    var canStartCombat: Bool {
        leftHealth.isAlive && rightHealth.isAlive
    }
}

extension CombatEncounterModel {
    /// Resolves one exchange, commits its damage, and returns the script that replays it.
    /// Damage lands immediately because the exchange is already decided — the scene is only
    /// a replay of a result the model already holds.
    func startEncounter(encounterSeed: Int) throws -> CombatPlaybackScript {
        let initiator = leftUnit
        let responder = rightUnit

        let combatConfig = CombatConfig(
            initiator: initiator.buildCombatant(),
            responder: responder.buildCombatant(),
            range: range,
            seed: encounterSeed
        )

        let summary = try CombatEvaluator(config: combatConfig).getCombatSummary()

        let builderConfig = CombatPlaybackScriptBuilder.Config(
            initiator: .init(
                unit: initiator,
                startingHealth: combatConfig.initiator.initialHealth,
                atRange: range
            ),
            responder: .init(
                unit: responder,
                startingHealth: combatConfig.responder.initialHealth,
                atRange: range
            ),
            range: range,
            catalog: try BAProcessedAnimationStore.catalog()
        )

        let script = try CombatPlaybackScriptBuilder(config: builderConfig)
            .buildScript(from: summary)

        commit(summary, initiator: initiator, responder: responder)

        return script
    }

    private func commit(
        _ summary: CombatSummary,
        initiator: CharacterUnit,
        responder: CharacterUnit
    ) {
        for case .strike(let strike) in summary.events {
            switch strike.receiverRole {
            case .initiator: initiator.takeDamage(strike.totalDamage)
            case .responder: responder.takeDamage(strike.totalDamage)
            }
        }
    }
}

// MARK: - Live Health Updates
extension CombatEncounterModel {
    func drainHealth(of role: CombatRole, to remainingHealth: Int) async {
        let damage = displayedHealth(for: role).currentHealth - remainingHealth
        await healthDrainTimer.drainHealth(amount: damage) {
            reduceDisplayedHealth(for: role)
        }
    }

    /// The only place role maps to side. Left always initiates today; alternating changes
    /// these two switches and nothing else.
    private func displayedHealth(for role: CombatRole) -> UnitHealthStatus {
        switch role {
        case .initiator: leftHealth
        case .responder: rightHealth
        }
    }

    private func reduceDisplayedHealth(for role: CombatRole) {
        switch role {
        case .initiator: leftHealth = leftHealth.reducedByOne
        case .responder: rightHealth = rightHealth.reducedByOne
        }
    }
}

extension UnitHealthStatus {
    var isAlive: Bool { 0 < currentHealth }

    var fraction: Double {
        0 < maxHealth ? Double(currentHealth) / Double(maxHealth) : 0
    }

    var reducedByOne: UnitHealthStatus {
        UnitHealthStatus(
            currentHealth: Swift.max(currentHealth - 1, 0),
            maxHealth: maxHealth
        )
    }
}
