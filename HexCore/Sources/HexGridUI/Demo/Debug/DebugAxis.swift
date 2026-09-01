//
//  DebugAxis.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import HECommon
import HexCore
import SwiftUI

struct DebugAxis: ViewModifier {

    let width: CGFloat
    let orientation: HexOrientation

    private var orientationAngle: CGFloat {
        switch orientation {
        case .pointyTop: 0
        case .flatTop: -30
        }
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    ForEach([Color.green, .blue, .pink].enumerated(), id: \.offset) { e in
                        let color = e.element
                        color
                            .padding(0.2)
                            .background(.white)
                            .rotationEffect(.degrees((-60) * e.offset - orientationAngle))
                            .frame(width: width, height: 2)
                    }
                }
            }
    }
}
