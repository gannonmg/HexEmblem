//
//  EnvironmentValues+Extension.swift
//  HexCore
//
//  Created by Matt Gannon on 8/27/26.
//

import SwiftUI

extension EnvironmentValues {
    /// The enclosing scroll view's visible rect, in content coordinates. `nil` when there
    /// isn't one publishing it — content should draw everything in that case.
    @Entry var scrollVisibleRect: CGRect?
}
