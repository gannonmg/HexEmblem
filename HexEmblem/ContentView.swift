//
//  ContentView.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/6/26.
//

import SpriteKit
import SwiftUI

// at 300x400 points
struct ContentView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.scaleMode = .resizeFill

        return scene
    }

    var body: some View {
        SpriteView(
            scene: scene,
            debugOptions: [.showsFPS, .showsNodeCount]
        )
    }
}

#Preview {
    ContentView()
}
