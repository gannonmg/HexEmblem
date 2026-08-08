//
//  BAWeaponID.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/7/26.
//

import Foundation

// This is overkill, but I am tired and I did not want to simply bury
// unknown Kinds with a nil optional and logging the value
public struct BAWeaponID: Codable, Hashable, Sendable {

    public let weaponIDKind: Kind
    public var rawValue: Int {
        switch self.weaponIDKind {
        case .known(let knownKind): knownKind.rawValue
        case .unknown(let rawValue): rawValue
        }
    }

    public init(rawValue: Int) {
        self.weaponIDKind = .init(rawValue: rawValue)
    }

    public enum KnownKind: Int, Codable, Hashable, Sendable {
        case sword = 1
        case lance = 2
        case axe = 3
        case handaxe = 4
        case bow = 5
        case magic = 6
        case staff = 7
        case unarmed = 8
    }

    public enum Kind: Codable, Hashable, Sendable {
        case known(KnownKind)
        case unknown(rawValue: Int)

        public init(rawValue: Int) {
            self = if let kind = KnownKind(rawValue: rawValue) {
                .known(kind)
            } else {
                .unknown(rawValue: rawValue)
            }
        }
    }
}

extension BAWeaponID {
    public init(_ known: KnownKind) {
        self.init(rawValue: known.rawValue)
    }
}

extension BAWeaponID: CustomStringConvertible {
    public var description: String { weaponIDKind.description }
}

extension BAWeaponID.Kind: CustomStringConvertible {
    public var description: String {
        switch self {
        case .known(let knownKind): "\(knownKind)"
        case .unknown(let rawValue): "slot \(rawValue)"
        }
    }
}

// Encode as the bare slot number so catalog.json stays readable and greppable.
extension BAWeaponID {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(Int.self))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

