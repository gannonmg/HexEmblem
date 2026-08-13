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
    var body: some View {
        Color.gray.frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                CombatDemoHost()
            }
    }
}

#Preview {
    ContentView()
}
