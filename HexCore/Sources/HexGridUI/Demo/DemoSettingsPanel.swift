//
//  DemoSettingsPanel.swift
//  HexCore
//
//  Created by Matt Gannon on 8/23/26.
//

import SwiftUI

// MARK: - Access
extension View {
    func settingsPanel(vm: Binding<PannableHexDemoViewModel>) -> some View {
        self.modifier(DemoSettingsPanel(viewModel: vm))
    }
}

// MARK: - View
private struct DemoSettingsPanel: ViewModifier {

    @State private var isExpanded: Bool = true

    @Binding var viewModel: PannableHexDemoViewModel

    init(viewModel: Binding<PannableHexDemoViewModel>) {
        self._viewModel = viewModel
    }

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
                FPSDisplay()

                DisclosureGroup("Settings", isExpanded: $isExpanded) {
                    VStack(alignment: .leading) {
                        Toggle("Pointy Top", isOn: $viewModel.isPointyTop)
                        Toggle("Show Grid", isOn: $viewModel.showGrid)
                        Toggle("Show Coordinates", isOn: $viewModel.showCoordinates)
                        hexRadiusSlider
                        MapShapePanel(viewModel: $viewModel)
                    }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.black.opacity(0.3))
            }
            .padding()
            .containerRelativeFrame([.horizontal]) { w, _ in w / 3 }
        }
    }

    @ViewBuilder
    private var hexRadiusSlider: some View {
        HStack {
            Text("Hex Radius: \(Int(viewModel.hexRadius))")
            Slider(value: $viewModel.hexRadius, in: 20...150, step: 5)
        }
    }
}


