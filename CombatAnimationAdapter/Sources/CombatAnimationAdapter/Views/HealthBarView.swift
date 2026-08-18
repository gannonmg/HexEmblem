//
//  HealthBarView.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/10/26.
//

import GameModels
import SwiftUI

public struct HealthBarView: View {

    private static let barSize = CGSize(width: 160, height: 14)

    let title: String
    let health: UnitHealthStatus

    public init(title: String, health: UnitHealthStatus) {
        self.title = title
        self.health = health
    }

    public var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.black.opacity(0.5))
                    .frame(width: Self.barSize.width, height: Self.barSize.height)

                Capsule()
                    .fill(fillColor)
                    .frame(
                        width: Self.barSize.width * health.fraction,
                        height: Self.barSize.height
                    )
            }

            Text("\(health.currentHealth) / \(health.maxHealth)")
                .font(.caption.monospacedDigit())
        }
        .foregroundStyle(.white)
    }

    private var fillColor: Color {
        switch health.fraction {
        case ..<0.25: .red
        case ..<0.5: .orange
        default: .green
        }
    }
}

#Preview {
    HealthBarView(title: "Preview", health: .init(currentHealth: 20, maxHealth: 25))
}
