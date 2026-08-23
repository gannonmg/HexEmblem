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
    let axialCoordinate: AxialCoordinate
    let color: Color

    init(axialCoordinate: AxialCoordinate, gridDiameter: Int) {
        self.axialCoordinate = axialCoordinate
        let diameter = CGFloat(gridDiameter)
        self.color = Color(
            red: axialCoordinate.q / diameter,
            green: axialCoordinate.r / diameter,
            blue: axialCoordinate.s / diameter
        )
    }
}

enum HexFactory {
    static func hexDisk(radius: Int) -> [HexCell] {
        let diameter = radius * 2 + 1 // double radius, and add the center cell
        let cells: [HexCell] = AxialCoordinate
            .disk(center: AxialCoordinate(q: 0, r: 0), radius: radius)
            .sorted { ($0.r, $0.q) < ($1.r, $1.q) }
            .map { HexCell(axialCoordinate: $0, gridDiameter: diameter) }
        return cells
    }

    static func hexGrid(col: Int, row: Int, orientation: HexOrientation) -> [HexCell] {
        let cells: [HexCell] = AxialCoordinate
            .rectangle(columns: col, rows: row, orientation: orientation)
            .sorted { ($0.r, $0.q) < ($1.r, $1.q) }
            .map { HexCell(axialCoordinate: $0, gridDiameter: max(col, row)) }
        return cells
    }
}

public struct ContentView: View {
    @State var orientation: HexOrientation = .pointyTop
    @State var radius: Int = 6
    private var cells: [HexCell] {
        HexFactory.hexGrid(col: radius * 2, row: radius, orientation: orientation)
    }

    public init() {}

    public var body: some View {
        VStack {
            HexGrid(data: cells, hexOrientation: orientation) {
                $0.color
            }
                .border(.black)
                .frame(maxHeight: .infinity)
            Toggle("Pointy", isOn: isPointyTop)
            Stepper("Radius", value: $radius)
        }
        .padding()
        .animation(.default, value: orientation)
        .animation(.default, value: radius)
    }

    private var isPointyTop: Binding<Bool> {
        Binding<Bool>(
            get: { self.orientation == .pointyTop },
            set: { self.orientation = $0 ? .pointyTop : .flatTop }
        )
    }
}

struct HexStyle: ShapeStyle {

}

#Preview {
    ContentView()
}
