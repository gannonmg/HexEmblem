//
//  CombatViewScene.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/18/26.
//

import BAPlayback
import CombatAnimationAdapter
import CCEvaluator
import CombatModels
import GameDebug
import GameModels
import SpriteKit
import SwiftUI

public struct CombatViewScene: View {

    // MARK: Init
    @State private var status: Status

    public init(config: Config) {
        self.status = .loading(config)
    }

    // MARK: Body
    public var body: some View {
        Group {
            switch status {
            case .loading(let config):
                ProgressView()
                    .onAppear {
                        do {
                            let script = try self.buildPlaybackScript(with: config)
                            self.status = .loaded(script)
                        } catch {
                            self.status = .error(error)
                        }
                    }
            case .loaded(let script):
                CombatView(script: script)
            case .error(let error):
                Text(error.localizedDescription)
            }
        }
    }

    private func buildPlaybackScript(with config: Config) throws -> CombatPlaybackAdapter.Script {
        let catalog = try BAProcessedAnimationStore.catalog()
        let playbackConfig: CombatPlaybackAdapter.Config = .init(
            initiator: config.initiator,
            responder: config.responder,
            range: config.range,
            catalog: catalog
        )

        let script = try CombatPlaybackAdapter(config: playbackConfig)
            .adapt(config.combatSummary)
        return script
    }
}

extension CombatViewScene {
    enum Status {
        case loading(Config)
        case loaded(CombatPlaybackAdapter.Script)
        case error(Error)
    }
}

extension CombatViewScene {
    public struct Config: Identifiable {
        public let id = UUID()
        public let initiator: CombatPlaybackAdapter.Config.Unit
        public let responder: CombatPlaybackAdapter.Config.Unit
        public let combatSummary: CombatSummary
        public let range: Int

        public init(
            initiator: CharacterUnit,
            responder: CharacterUnit,
            combatSummary: CombatSummary,
            range: Int
        ) {
            self.initiator = .init(characterUnit: initiator, range: range)
            self.responder = .init(characterUnit: responder, range: range)
            self.combatSummary = combatSummary
            self.range = range
        }
    }
}
