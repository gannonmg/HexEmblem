//
//  CombatPlanBuilder.swift
//  CombatCore
//
//  Created by Matt Gannon on 8/4/26.
//

import Foundation

public struct CombatPlanBuilder {

    let initiator: CombatPlanParticipant
    let responder: CombatPlanParticipant
    let responderCanStrike: Bool

    // Build events that we will reuse
    let initiatorEvent = CombatPlan.Event(striker: .initiator)
    let responderEvent = CombatPlan.Event(striker: .responder)

    private var followUpRole: CombatRole? {
        FollowUpEvaluator.getFollowUpRole(
            initiatorSpeed: initiator.speed,
            responderSpeed: responder.speed
        )
    }

    public init(
        initiator: CombatPlanParticipant,
        responder: CombatPlanParticipant,
        responderCanStrike: Bool
    ) {
        self.initiator = initiator
        self.responder = responder
        self.responderCanStrike = responderCanStrike
    }

    /// Builds a timeline preview of the Combat's Strikes based on factors such as speed, weapon range, and applicable skills.
    /// These strikes are not guarenteed to be calculated. A Combatant may die before all Strikes are evaluated.
    ///
    /// - Returns: An ordered array of character IDs representing who makes which Strike.
    public func buildCombatPlan() -> CombatPlan {
        if responderCanStrike {
            return buildBidirectionalCombatPlan()
        } else {
            return buildUnidirectionalCombatPlan()
        }
    }

    private func buildUnidirectionalCombatPlan() -> CombatPlan {
        var events: [CombatPlan.Event] = []
        events.append(initiatorEvent)

        if followUpRole == .initiator {
            events.append(initiatorEvent)
        }

        return CombatPlan(events: events)
    }

    private func buildBidirectionalCombatPlan() -> CombatPlan {
        var events: [CombatPlan.Event] = []

        // Begin by deciding order based on priority, and append in the correct order.
        if responder.hasPriority && !initiator.hasPriority {
            events.append(contentsOf: [responderEvent, initiatorEvent])
        } else {
            events.append(contentsOf: [initiatorEvent, responderEvent])
        }

        // This will append the corresponding event if followUpID is not nil.
        if let followUpRole {
            events.append(.init(striker: followUpRole))
        }

        return CombatPlan(events: events)
    }
}
