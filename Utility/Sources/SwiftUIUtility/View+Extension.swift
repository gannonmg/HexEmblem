//
//  View+Extension.swift
//  Utility
//
//  Created by Matt Gannon on 8/18/26.
//

import SwiftUI

extension View {
    public func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        self.frame(width: size.width, height: size.height, alignment: alignment)
    }
}
