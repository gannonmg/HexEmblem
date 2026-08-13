//
//  CombatDemo.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/12/26.
//

import CCEvaluator
import CombatModels
import GameModels
import SpriteKit
import SwiftUI

struct CombatDemoHost: View {
    let good: CharacterUnit = .gwendolyn()
    let evil: CharacterUnit = .badGuy()
    var initiator: CharacterUnit { goodTurn ? good : evil }
    var responder: CharacterUnit { goodTurn ? evil : good }
    var range: Int { initiator.weapon.range.lowerBound }

    @State var currentScript: CombatPlaybackAdapter.Script?
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
        .sheet(item: $currentScript) { script in
            CombatDemo(
                script: script
            )
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
        guard currentScript == nil else { return }
        do {
            // Build the combat summary
            let summary = try getCombatSummary()

            // Build the animation script from the combat data
            self.currentScript = try buildPlaybackScript(with: summary)

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

        summary.debugPrint()
        return summary
    }

    private func buildPlaybackScript(with summary: CombatSummary) throws -> CombatPlaybackAdapter.Script {
        let playbackConfig = try CombatPlaybackAdapter.Config(
            initiator: .init(
                animationID: initiator.animationID,
                healthStatus: initiator.healthStatus,
                weaponSlot: initiator.weapon.animationSlot(atRange: range),
                weaponIsMagical: initiator.weapon.hasMagicalDamage
            ),
            responder: .init(
                animationID: responder.animationID,
                healthStatus: responder.healthStatus,
                weaponSlot: responder.weapon.animationSlot(atRange: range),
                weaponIsMagical: responder.weapon.hasMagicalDamage
            ),
            range: range
        )

        let script = try CombatPlaybackAdapter(config: playbackConfig)
            .adapt(summary)
        return script
    }
}

struct CombatDemo: View {
    @Environment(\.dismiss) private var dismiss

    @State private var initiatorHealthStatus: UnitHealthStatus
    @State private var responderHealthStatus: UnitHealthStatus
    @State private var combatScene: CombatScene?
    private let frameSize: CGSize = .combatFrame * 2.5

    // MARK: Init
    let script: CombatPlaybackAdapter.Script

    init(script: CombatPlaybackAdapter.Script) {
        self.script = script
        self.initiatorHealthStatus = script.startingHealth.for(.initiator)
        self.responderHealthStatus = script.startingHealth.for(.responder)
    }

    var body: some View {
        Group {
            if let combatScene {
                SpriteView(
                    scene: combatScene,
                    debugOptions: [.showsFPS, .showsNodeCount]
                )
                .id(ObjectIdentifier(combatScene))
            } else {
                Color.black
            }
        }
        .frame(size: frameSize)
        .border(.blue.opacity(0.5), width: 3)
        .overlay(alignment: .top) {
            HStack {
                HealthBarView(title: "Init", health: initiatorHealthStatus)
                HealthBarView(title: "Resp", health: responderHealthStatus)
            }
            .padding(.top)
        }
        .task {
            await playCombatScript(script)
            dismiss()
        }
    }

    private func playCombatScript(_ script: CombatPlaybackAdapter.Script) async {
        let scene = CombatScene(
            size: frameSize,
            script: script,
            onDamage: onDamage(to:amount:)
        )
        scene.scaleMode = .aspectFit
        combatScene = scene
        await scene.beginPlayback()
    }

    private func onDamage(to role: CombatRole, amount: Int) async {
        print("Applying \(amount) damage to \(role)")
        await GBAHealthDrainer.drainHealth(amount: amount) {
            switch role {
            case .initiator: initiatorHealthStatus.reduceByOne()
            case .responder: responderHealthStatus.reduceByOne()
            }
        }
    }
}

extension CGSize {
    static let combatFrame = CGSize(width: 240, height: 160)

    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
}

extension View {
    public func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        self.frame(width: size.width, height: size.height, alignment: alignment)
    }
}
