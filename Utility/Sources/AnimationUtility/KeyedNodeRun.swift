//
//  KeyedNodeRun.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/12/26.
//

import SpriteKit

/// Pairs one SKAction key with async/await. `run` awaits the action's completion;
/// `cancel` resumes that await if something else preempts the key, instead of leaking it.
@MainActor
public final class KeyedNodeRun {
    private weak var node: SKNode?
    private let key: String
    private var continuation: CheckedContinuation<Void, Never>?

    public init(node: SKNode, key: String) {
        self.node = node
        self.key = key
    }

    public func run(_ action: SKAction) async {
        cancel()
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            let wrapped = SKAction.sequence([action, .run { [weak self] in self?.resume() }])
            node?.run(wrapped, withKey: key)
        }
    }

    public func nonBlockingRun(_ action: SKAction) {
        cancel()
        node?.run(action, withKey: key)
    }

    public func cancel() {
        node?.removeAction(forKey: key)
        resume()
    }

    private func resume() {
        continuation?.resume()
        continuation = nil
    }
}
