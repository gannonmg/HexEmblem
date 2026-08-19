//
//  BattleMap.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/18/26.
//

import Foundation
import SpriteKit

enum BattleMapLayout {
    static let scale: CGFloat = 0.2
}

final class BattleMapScene: SKScene {

    let mapNode = BattleMapNode()

    // MARK: - Init
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func addMapNode() {
        addChild(mapNode)
        mapNode.xScale = 0.2
        mapNode.yScale = 0.2
    }
}

final class BattleMapNode: SKNode {

    // MARK: - Init
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
