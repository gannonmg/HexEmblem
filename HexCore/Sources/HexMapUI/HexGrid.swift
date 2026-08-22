//
//  HexGrid.swift
//  HexCore
//
//  Created by Matt Gannon on 8/21/26.
//

import HexCore
import SwiftUI

/// Handles clipping the content to hexagons as well as enforcing that each element has an axialCoordinate
struct HexGrid<Data, ID, Content>: View
where Data: RandomAccessCollection,
      Data.Element: AxialCoordinateProviding,
      ID: Hashable,
      Content: View
{
    let data: Data
    let id: KeyPath<Data.Element, ID>
    let hexOrientation: HexOrientation
    let content: (Data.Element) -> Content

    init(
        data: Data,
        id: KeyPath<Data.Element, ID>,
        hexOrientation: HexOrientation = .pointyTop,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = id
        self.hexOrientation = hexOrientation
        self.content = content
    }

    var body: some View {
        HexLayout(hexOrientation: hexOrientation) {
            ForEach(data, id: id) { element in
                content(element)
                    .clipShape(Hexagon(orientation: hexOrientation))
                    .layoutValue(
                        key: AxialCoordinateLayoutValueKey.self,
                        value: element.axialCoordinate
                    )
            }
        }
    }
}

extension HexGrid where ID == Data.Element.ID, Data.Element: Identifiable {
    init(
        data: Data,
        hexOrientation: HexOrientation = .pointyTop,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(data: data, id: \.id, hexOrientation: hexOrientation, content: content)
    }
}
