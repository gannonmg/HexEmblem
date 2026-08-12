//
//  PlaybackDebugPanel.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/11/26.
//

import SwiftUI

struct PlaybackDebugPanel: View {

    private static let speeds: [CGFloat] = [1, 0.5, 0.25]

    @Bindable private var debug = PlaybackDebug.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Picker("Speed", selection: $debug.speed) {
                ForEach(Self.speeds, id: \.self) { speed in
                    Text(String(format: "%gx", Double(speed))).tag(speed)
                }
            }
            .pickerStyle(.segmented)

            ForEach(debug.layers.keys.sorted(), id: \.self) { name in
                if let report = debug.layers[name] {
                    Text("\(name)  \(report.summary)")
                        .font(.caption.monospaced())
                }
            }
        }
        .padding(8)
        .background(.black.opacity(0.6), in: .rect(cornerRadius: 8))
        .foregroundStyle(.white)
    }
}
