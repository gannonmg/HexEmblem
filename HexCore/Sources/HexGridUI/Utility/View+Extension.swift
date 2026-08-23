//
//  View+Extension.swift
//  HexCore
//
//  Created by Matt Gannon on 8/22/26.
//

import SwiftUI

extension View {
    func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        self.frame(width: size.width, height: size.height, alignment: alignment)
    }
}
