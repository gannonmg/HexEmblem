//
//  Int+Extension.swift
//  HexCore
//
//  Created by Matt Gannon on 8/21/26.
//

import Foundation

extension Int {
    public static func + (lhs: Int, rhs: CGFloat) -> CGFloat {
        return CGFloat(lhs) + rhs
    }

    public static func - (lhs: Int, rhs: CGFloat) -> CGFloat {
        return CGFloat(lhs) - rhs
    }

    public static func * (lhs: Int, rhs: CGFloat) -> CGFloat {
        return CGFloat(lhs) * rhs
    }

    public static func / (lhs: Int, rhs: CGFloat) -> CGFloat {
        return CGFloat(lhs) / rhs
    }
}

extension CGFloat {
    public static func + (lhs: CGFloat, rhs: Int) -> CGFloat {
        return lhs + CGFloat(rhs)
    }

    public static func - (lhs: CGFloat, rhs: Int) -> CGFloat {
        return lhs - CGFloat(rhs)
    }

    public static func * (lhs: CGFloat, rhs: Int) -> CGFloat {
        return lhs * CGFloat(rhs)
    }

    public static func / (lhs: CGFloat, rhs: Int) -> CGFloat {
        return lhs / CGFloat(rhs)
    }
}
