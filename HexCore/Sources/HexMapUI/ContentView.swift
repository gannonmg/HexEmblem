//
//  ContentView.swift
//  HexCore
//
//  Created by Matt Gannon on 8/21/26.
//

import HexCore
import SwiftUI

/*
 import SwiftUI
 import WeightedMapUI

 @main
 struct WeightedMapGUIApp: App {
 var body: some Scene {
 WindowGroup {
 ContentView()
 }
 }
 }
 */

struct HexCell: Identifiable, AxialCoordinateProviding {
    var id: Int { axialCoordinate.hashValue }
    var axialCoordinate: AxialCoordinate
    let color: Color
}

let cells: [HexCell] = [
    .init(axialCoordinate: .init(q: 0, r: 0), color: .purple),
    .init(axialCoordinate: .init(q: 0, r: 1), color: .red),
    .init(axialCoordinate: .init(q: 0, r: 2), color: .blue),
    .init(axialCoordinate: .init(q: 1, r: 0), color: .gray),
    .init(axialCoordinate: .init(q: 1, r: 1), color: .pink)
]

public struct ContentView: View {
    @State var orientation: HexOrientation = .pointyTop

    public init() {}

    public var body: some View {
        VStack {
            HexGrid(data: cells, hexOrientation: orientation) { $0.color }
            Toggle("Pointy", isOn: isPointyTop)
        }
        .padding()
        .animation(.default, value: orientation)
    }

    private var isPointyTop: Binding<Bool> {
        Binding<Bool>(
            get: { self.orientation == .pointyTop },
            set: { self.orientation = $0 ? .pointyTop : .flatTop }
        )
    }
}

#Preview {
    ContentView()
}
