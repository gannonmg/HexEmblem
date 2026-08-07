//
//  CombatEvaluator.swift
//  CombatCore
//
//  Created by Matt Gannon on 8/4/26.
//

import CombatCore
import Foundation
import GameModels

public struct CombatEvaluator {
    private let planner: CombatPlanBuilder
    private let resolver: CombatPlanResolver

    init(
        initiator: Combatant,
        responder: Combatant,
        range: Int,
        seed: Int
    ) {
        let responderCanStrike = responder.weaponRange.contains(range)
        self.planner = CombatPlanBuilder(
            initiator: initiator,
            responder: responder,
            responderCanStrike: responderCanStrike
        )

        self.resolver = CombatPlanResolver(
            initiator: initiator,
            responder: responder,
            seed: seed
        )
    }

    public static func create(
        initiator: CharacterUnit,
        responder: CharacterUnit,
        range: Int,
        seed: Int
    ) -> CombatEvaluator {
        self.init(initiator: initiator, responder: responder, range: range, seed: seed)
    }

    public func getCombatSummary() -> CombatSummary {
        let combatPlan = planner.buildCombatPlan()
        return resolver.resolveCombatPlan(combatPlan)
    }
}
