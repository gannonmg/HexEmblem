//
//  PointerInput.swift
//  HexCore
//
//  Created by Matt Gannon on 8/23/26.
//

import Foundation

enum PointerInput {
    /// True where the primary input is an indirect pointer, so a pressed drag can never also
    /// be a scroll. Direct-touch platforms return false: there, a finger drag *is* the
    /// scroll gesture and a competing `DragGesture` fights the scroll view.
    static var usesIndirectPointer: Bool {
#if os(macOS) || targetEnvironment(macCatalyst)
        true
#else
        ProcessInfo.processInfo.isiOSAppOnMac
#endif
    }
}
