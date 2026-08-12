//
//  CombatResolver.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/2/26.
//

import CombatModels
import Foundation
import GameModels
import GameplayKit

/*
 Terminology:
 - Combat: An encounter between two characters. Made up of 1+ Strikes.
 - Strike: Any individual attack made within a combat.

 - Initiator: The character who initiated the Combat
 - Responder: The character who is being targeted by the Initiator

 - Striker: Any character in the combat who makes a strike
 - Receiver: Any character in the combat who is hit by a strike
 */

public final class CombatPlanResolver {

    public enum Error: LocalizedError {
        case untrackedHealth(role: CombatRole)
    }

    // MARK: - Parameters
    private let initiator: Combatant
    private let responder: Combatant
    private var healthPool: CombatHealthTracker
    private let randomSource: GKMersenneTwisterRandomSource

    // MARK: - Init
    public init(
        initiator: Combatant,
        responder: Combatant,
        seed: Int
    ) {
        self.initiator = initiator
        self.responder = responder

        self.healthPool = CombatHealthTracker(
            initiatorHealth: initiator.initialHealthStatus.currentHealth,
            responderHealth: responder.initialHealthStatus.currentHealth
        )

        self.randomSource = GKMersenneTwisterRandomSource(seed: UInt64(seed))
    }

    public func resolveCombatPlan(_ plan: CombatPlan) throws(CombatPlanResolver.Error) -> CombatSummary {
        var resolvedEvents: [CombatSummary.Event] = []

        for planEvent in plan.events {
            let result = try buildStrikeResult(
                strikerRole: planEvent.striker,
                receiverRole: planEvent.receiver
            )

            let remainingHealth = try healthPool.apply(
                damage: result.totalDamage,
                to: planEvent.receiver
            )

            resolvedEvents.append(.strike(
                CombatStrike(
                    strikerRole: planEvent.striker,
                    receiverRole: planEvent.receiver,
                    result: result,
                    receiverRemainingHealth: remainingHealth)
            ))

            guard 0 < remainingHealth else {
                resolvedEvents.append(.defeat(planEvent.receiver))
                return CombatSummary(events: resolvedEvents)
            }
        }

        return CombatSummary(events: resolvedEvents)
    }

    private func buildStrikeResult(
        strikerRole: CombatRole,
        receiverRole: CombatRole
    ) throws(CombatPlanResolver.Error) -> StrikeResult {

        let striker = combatant(for: strikerRole)
        let receiver = combatant(for: receiverRole)

        // Check if the individual strike lands on the defender
        let strikeLands = HitCalculator.determineHit(
            accuracy: striker.effectiveStats[.dexterity],
            evasion: receiver.effectiveStats[.dexterity],
            toHitBonus: striker.toHitBonus,
            evasionBonus: receiver.evasionBonus,
            seed: randomSource.nextInt()
        )

        guard strikeLands else { return .miss }

        // If the attack hits, get an array of all the damage the weapon inflicts
        let damageInstances = striker.weaponDamage.map { damage in
            let damagePower = striker.effectiveStats[damage.baseStat] + damage.power
            let defense = receiver.defenseValue(for: damage.damageClass)
            let resistance = receiver.resistances[damage.damageType, default: 0]

            let damageAmount = DamageCalculator.calculateDamage(
                attackPower: damagePower,
                defense: defense,
                resistance: resistance
            )

            return DamageInstance(amount: damageAmount, type: damage.damageType)
        }

        let isCritical: Bool = CritCalculator.determineCrit(
            striker: striker,
            receiver: receiver,
            seed: randomSource.nextInt()
        )

        let strikeResult: StrikeResult = if isCritical {
            .critical(damageInstances: damageInstances)
        } else {
            .hit(damageInstances: damageInstances)
        }

        return strikeResult
    }

    // MARK: - Helpers
    private func combatant(for side: CombatRole) -> Combatant {
        switch side {
        case .initiator: initiator
        case .responder: responder
        }
    }
}

private struct CombatHealthTracker {
    private var healthPool: [CombatRole: Int]

    init(
        initiatorHealth: Int,
        responderHealth: Int
    ) {
        self.healthPool = [
            .initiator: initiatorHealth,
            .responder: responderHealth
        ]
    }

    func getHealth(for role: CombatRole) throws(CombatPlanResolver.Error) -> Int {
        guard let health = healthPool[role] else { throw .untrackedHealth(role: role) }
        return max(0, health)
    }

    @discardableResult
    mutating func apply(damage: Int, to combatantRole: CombatRole) throws(CombatPlanResolver.Error) -> Int {
        let health = try getHealth(for: combatantRole)
        healthPool[combatantRole] = health - damage
        return try getHealth(for: combatantRole)
    }
}
