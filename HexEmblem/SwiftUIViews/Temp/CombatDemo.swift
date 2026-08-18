//
//  CombatDemo.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/12/26.
//

import CombatAnimationAdapter
import CCEvaluator
import CombatModels
import GameDebug
import GameModels
import SwiftUI

struct CombatDemoHost: View {
    let good: CharacterUnit = .gwendolyn()
    let evil: CharacterUnit = .assassin() // .badGuy()
    var initiator: CharacterUnit { goodTurn ? good : evil }
    var responder: CharacterUnit { goodTurn ? evil : good }
    var range: Int { initiator.weapon.range.lowerBound }

    @State var combatConfig: CombatViewScene.Config?
    @State private var round: Int = 0
    @State private var goodTurn: Bool = true

    var body: some View {
        HStack {
            HealthBarView(title: "Good", health: good.healthStatus)
            if good.isAlive && evil.isAlive {
                Button("Start Round", action: executeRound)
            } else {
                Button("Reset", action: reset)
            }
            HealthBarView(title: "Evil", health: evil.healthStatus)
        }
        .sheet(item: $combatConfig) { config in
            CombatViewScene(config: config)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            PlaybackDebugPanel()
                .padding()
        }
    }

    private func reset() {
        good.fullyRestoreHealth()
        evil.fullyRestoreHealth()
    }

    private func executeRound() {
        guard combatConfig == nil else { return }
        do {
            // Build the combat summary
            let summary = try getCombatSummary()

            self.combatConfig = .init(
                initiator: initiator,
                responder: responder,
                combatSummary: summary,
                range: range
            )

            // Immediately apply the damage to the actual units
            // (eventually allows for skipping of combat animations)
            // Should be moved out to battle manager
            applyCombatDamage(from: summary)

            // Prepare for the next round
            goodTurn.toggle()
            round += 1
        } catch {
            print("Failed to execute combat rounds \(error)")
        }
    }

    private func applyCombatDamage(from summary: CombatSummary) {
        for event in summary.events {
            switch event {
            case .strike(let strike):
                switch strike.receiverRole {
                case .initiator: initiator.takeDamage(strike.totalDamage)
                case .responder: responder.takeDamage(strike.totalDamage)
                }
            default:
                return
            }
        }
    }

    private func getCombatSummary() throws -> CombatSummary {
        let config = CombatConfig(
            initiator: initiator.buildCombatant(),
            responder: responder.buildCombatant(),
            range: range,
            seed: round
        )

        let summary = try CombatEvaluator(config: config)
            .getCombatSummary()
        return summary
    }
}

extension View {
    public func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        self.frame(width: size.width, height: size.height, alignment: alignment)
    }
}
