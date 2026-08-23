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
    @State private var diskRadiusFloat: CGFloat

    init(viewModel: Binding<PannableHexDemoViewModel>) {
        self._viewModel = viewModel
        self.diskRadiusFloat = CGFloat(viewModel.diskRadius.wrappedValue)
    }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                GeometryReader { proxy in
                    DisclosureGroup("Settings", isExpanded: $isExpanded) {
                        VStack(alignment: .leading) {
                            Toggle("Pointy Top", isOn: $viewModel.isPointyTop)
                                .fixedSize()
                            Toggle("Show Coordinates", isOn: $viewModel.showCoordinates)
                                .fixedSize()
                            diskRadiusSlider
                            hexRadiusSlider
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.black.opacity(0.3))
                    }
                    .padding()
                    .frame(width: proxy.size.width / 3)
                }
            }
    }

    @ViewBuilder
    private var diskRadiusSlider: some View {
        HStack {
            Text("Disk Radius: \(Int(diskRadiusFloat))")
            Slider(
                value: $diskRadiusFloat,
                in: 0...30,
                step: 1,
                label: {
                    Text("Disk Radius: \(Int(diskRadiusFloat))")
                },
                onEditingChanged: { changed in
                    viewModel.diskRadius = Int(diskRadiusFloat)
                }
            )
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
