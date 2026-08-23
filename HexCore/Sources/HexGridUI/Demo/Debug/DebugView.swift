//
//  DebugView.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import SwiftUI

struct DebugView: View {
    let visibleRect: CGRect

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Visible X: \(truncate(visibleRect.minX))-\(truncate(visibleRect.maxX))")
            Text("Visible Y: \(truncate(visibleRect.minY))-\(truncate(visibleRect.maxY))")
            Text("Offset: \(truncate(visibleRect.origin.x)), \(truncate(visibleRect.origin.y))")
        }
        .padding(2)
        .background(.black)
        .foregroundStyle(.white)
    }

    func truncate(_ value: CGFloat) -> String {
        String(format: "%.2f", value)
    }
}
