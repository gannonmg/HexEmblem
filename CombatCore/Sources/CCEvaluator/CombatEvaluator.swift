//
//  CombatEvaluator.swift
//  CombatCore
//
//  Created by Matt Gannon on 8/4/26.
//

import CombatCore
import CombatModels
import Foundation
import GameModels

public struct CombatEvaluator {
    private let planner: CombatPlanBuilder
    private let resolver: CombatPlanResolver

    public init(config: CombatConfig) {
        self.init(
            initiator: config.initiator,
            responder: config.responder,
            range: config.range,
            seed: config.seed
        )
    }

    private init(
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

    public func getCombatSummary() -> CombatSummary {
        let combatPlan = planner.buildCombatPlan()
        return resolver.resolveCombatPlan(combatPlan)
    }
}
