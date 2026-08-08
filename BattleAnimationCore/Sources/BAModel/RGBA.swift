//
//  RGBA.swift
//  hex-emblem-swift
//
//  Created by Matt Gannon on 8/3/26.
//

public struct RGBA: Codable, Hashable, Sendable {
    public var r: UInt8
    public var g: UInt8
    public var b: UInt8
    public var a: UInt8

    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}
