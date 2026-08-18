//
//  CombatView.swift
//  CombatAnimationAdapter
//
//  Created by Matt Gannon on 8/18/26.
//

import CombatModels
import GameModels
import HECommon
import SpriteKit
import SwiftUI
import SwiftUIUtility

struct CombatView: View {

    private enum Layout {
        static let frameSize: CGSize = .combatFrame * 2.5
    }

    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @State private var initiatorHealthStatus: UnitHealthStatus
    @State private var responderHealthStatus: UnitHealthStatus
    @State private var combatScene: CombatScene?

    // MARK: - Init
    let script: CombatPlaybackAdapter.Script

    init(script: CombatPlaybackAdapter.Script) {
        self.script = script
        self.initiatorHealthStatus = script.startingHealth.for(.initiator)
        self.responderHealthStatus = script.startingHealth.for(.responder)
    }

    // MARK: - Body
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
        .frame(size: Layout.frameSize)
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

    // MARK: - Funcs
    private func playCombatScript(_ script: CombatPlaybackAdapter.Script) async {
        let scene = CombatScene(
            size: Layout.frameSize,
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
