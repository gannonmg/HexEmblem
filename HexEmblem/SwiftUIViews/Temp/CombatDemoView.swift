//
//  CombatDemoView.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/10/26.
//

import GameModels
import SpriteKit
import SwiftUI

// at 300x400 points
struct CombatDemoView: View {

    private static let sceneSize = CGSize(width: 960, height: 640)

    @State private var model = CombatEncounterModel.demo(range: 1)
    @State private var combatScene: CombatScene?
    @State private var seed: Int = 0

    var body: some View {
        Group {
            if let combatScene {
                SpriteView(scene: combatScene, debugOptions: [.showsFPS, .showsNodeCount])
                    .id(ObjectIdentifier(combatScene))
            } else {
                Color.black
            }
        }
        .overlay(alignment: .top) {
            HStack(spacing: 48) {
                HealthBarView(title: "Left", health: model.leftHealth)
                HealthBarView(title: "Right", health: model.rightHealth)
            }
            .padding()
        }
        .overlay(alignment: .bottom) {
            Button("Start Combat") {
                startCombat()
            }
            .disabled(!model.canStartCombat)
            .padding()
        }
        .overlay(alignment: .topLeading) {
            PlaybackDebugPanel()
                .padding()
        }
    }

    private func startCombat() {
        do {
            let script = try model.startEncounter(encounterSeed: seed)
            seed += 1
            let scene = CombatScene(script: script, size: Self.sceneSize) { role, remaining in
                await model.drainHealth(of: role, to: remaining)
            }
            scene.scaleMode = .aspectFit
            combatScene = scene
        } catch {
            print("Failed to start combat: \(error)")
        }
    }
}

extension CombatEncounterModel {
    static func demo(
        leftUnit: CharacterUnit = .gwendolyn(),
        rightUnit: CharacterUnit = .badGuy(),
        range: Int
    ) -> CombatEncounterModel {
        CombatEncounterModel(leftUnit: leftUnit, rightUnit: rightUnit, range: range)
    }
}

#Preview {
    ContentView()
}
