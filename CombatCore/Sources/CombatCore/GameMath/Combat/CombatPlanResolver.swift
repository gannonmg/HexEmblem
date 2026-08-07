//
//  CombatResolver.swift
//  hex-emblem-swift-poc
//
//  Created by Matt Gannon on 8/2/26.
//

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

    private let initiator: Combatant
    private let responder: Combatant
    private var healthPool: [CharacterID: Int]
    private let randomSource: GKMersenneTwisterRandomSource

    // MARK: - Init
    public init(
        initiator: Combatant,
        responder: Combatant,
        seed: Int
    ) {
        self.initiator = initiator
        self.responder = responder

        self.healthPool = [
            initiator.characterID: initiator.initialHealth,
            responder.characterID: responder.initialHealth
        ]

        self.randomSource = GKMersenneTwisterRandomSource(seed: UInt64(seed))
    }

    public func resolveCombatPlan(_ plan: CombatPlan) -> CombatSummary {
        var strikes: [CombatStrike] = []

        for event in plan.events {
            let striker = combatant(for: event.striker)
            let receiver = combatant(for: event.receiver)

            let strike = buildStrike(striker: striker, receiver: receiver)
            strikes.append(strike)
            applyDamage(strike.totalDamage, to: receiver)

            guard isAlive(receiver) else {
                return CombatSummary(
                    strikes: strikes,
                    defeatedCharacterID: receiver.characterID
                )
            }
        }

        return CombatSummary(strikes: strikes)
    }

    private func buildStrike(
        striker: Combatant,
        receiver: Combatant
    ) -> CombatStrike {

        // Check if the individual strike lands on the defender
        let strikeLands = HitCalculator.determineHit(
            accuracy: striker.effectiveStats[.dexterity],
            evasion: receiver.effectiveStats[.dexterity],
            toHitBonus: striker.toHitBonus,
            evasionBonus: receiver.evasionBonus,
            seed: randomSource.nextInt()
        )

        guard strikeLands else {
            return CombatStrike(
                strikerID: striker.characterID,
                receiverID: receiver.characterID,
                result: .miss
            )
        }

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

        let strike = CombatStrike(
            strikerID: striker.characterID,
            receiverID: receiver.characterID,
            result: strikeResult
        )

        return strike
    }

    // MARK: - Helpers
    private func combatant(for side: CombatRole) -> Combatant {
        switch side {
        case .initiator: initiator
        case .responder: responder
        }
    }

    private func applyDamage(_ damage: Int, to combatant: Combatant) {
        healthPool[combatant.characterID, default: 0] -= damage
    }

    private func isAlive(_ combatant: Combatant) -> Bool {
        0 < healthPool[combatant.characterID, default: 0]
    }
}
