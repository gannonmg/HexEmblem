//
//  Overridable.swift
//  HexCore
//
//  Created by Matt Gannon on 8/27/26.
//

import SwiftUI

/// A value the view owns unless the caller supplies a binding to drive it, mirroring how
/// `ScrollView` works standalone but defers to `.scrollPosition()`.
@propertyWrapper
struct Overridable<Value>: DynamicProperty {
    @State private var internalValue: Value
    private let external: Binding<Value>?

    init(wrappedValue: Value) {
        self._internalValue = State(initialValue: wrappedValue)
        self.external = nil
    }

    init(_ binding: Binding<Value>) {
        self._internalValue = State(initialValue: binding.wrappedValue)
        self.external = binding
    }

    var wrappedValue: Value {
        get { external?.wrappedValue ?? internalValue }
        nonmutating set {
            if let external {
                external.wrappedValue = newValue
            } else {
                internalValue = newValue
            }
        }
    }

    var projectedValue: Binding<Value> {
        external ?? $internalValue
    }
}
