//
//  UIView+Layout.swift
//  HexCore
//
//  Created by Matt Gannon on 8/27/26.
//

import UIKit

extension UIView {
    /// Pins the subview to the edges of the view and applies additional constraints if provided.
    /// - Parameter subview: The subview to be pinned to the edges.
    /// - Parameter insets: The insets to be applied to the subview's constraints. Default is .zero.
    /// - Parameter additionalConstraints: Additional custom constraints to be activated. Default is nil.
    func pinSubviewToEdges(
        subview: UIView,
        insets: UIEdgeInsets = .zero,
        additionalConstraints: [NSLayoutConstraint] = []
    ) {
        // Disable autoresizing mask constraints
        subview.translatesAutoresizingMaskIntoConstraints = false

        // Edge constraints
        var constraints = [
            subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom)
        ]

        // Add any additional constraints
        constraints += additionalConstraints

        // Activate constraints
        NSLayoutConstraint.activate(constraints)
    }
}

extension UILayoutGuide {
    func pinSubviewToEdges(
        subview: UIView,
        insets: UIEdgeInsets = .zero,
        additionalConstraints: [NSLayoutConstraint] = []
    ) {
        // Disable autoresizing mask constraints
        subview.translatesAutoresizingMaskIntoConstraints = false

        // Edge constraints
        var constraints = [
            subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom)
        ]

        // Add any additional constraints
        constraints += additionalConstraints

        // Activate constraints
        NSLayoutConstraint.activate(constraints)
    }
}
