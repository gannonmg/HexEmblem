//
//  CGAffineTransform.swift
//  HexCore
//
//  Created by Matt Gannon on 8/28/26.
//

import CoreGraphics

extension CGAffineTransform {
    static func translation(with point: CGPoint) -> Self {
        CGAffineTransform(translationX: point.x, y: point.y)
    }

    func translated(by point: CGPoint) -> Self {
        self.translatedBy(x: point.x, y: point.y)
    }
}
