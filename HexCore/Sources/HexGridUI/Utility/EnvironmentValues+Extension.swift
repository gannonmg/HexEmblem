//
//  EnvironmentValues+Extension.swift
//  HexCore
//
//  Created by Matt Gannon on 8/27/26.
//

import SwiftUI

extension EnvironmentValues {
    /// The enclosing scrollview's visible rect, in content coordinates.
    /// `zero` only until it is overidden in `ZoomableScrollUIView.makeUIView(context:)`
    @Entry var scrollViewport: CGRect = .zero
}
