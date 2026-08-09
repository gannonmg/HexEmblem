//
//  BAVariant.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/8/26.
//

import Foundation

public struct BAVariant: Codable, Hashable, Sendable {
    public let slot: BAWeaponSlot?
    public let name: String
    public let qualifier: Qualifier?
    public let rawFolder: String

    /// Parses "3. Axe (Armads)" into slot 3, name "Axe", qualifier "Armads"
    public init(folderName: String) {
        let raw = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
        var remainder = raw
        var parsedSlot: BAWeaponSlot?

        // Leading "<n>. "
        let ordinalSplit = raw.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        if ordinalSplit.count == 2 {
            let candidate = ordinalSplit[0]
            if candidate.hasSuffix(".") {
                let digits = candidate.dropLast()
                if !digits.isEmpty, digits.allSatisfy(\.isNumber), let number = Int(digits) {
                    parsedSlot = BAWeaponSlot(rawValue: number)
                    remainder = String(ordinalSplit[1]).trimmingCharacters(in: .whitespaces)
                }
            }
        }

        // Trailing "(qualifier)"
        var qualifier: BAVariant.Qualifier?
        if remainder.hasSuffix(")"), let open = remainder.lastIndex(of: "(") {
            let start = remainder.index(after: open)
            let end = remainder.index(before: remainder.endIndex)
            let parsedQualifier = String(remainder[start..<end])
            qualifier = Qualifier(rawValue: parsedQualifier)
            remainder = String(remainder[..<open]).trimmingCharacters(in: .whitespaces)
        }

        self.rawFolder = raw
        self.slot = parsedSlot
        self.name = remainder
        self.qualifier = qualifier
    }

    public var idComponent: String {
        let slotPart = slot.map { String($0.rawValue) } ?? "x"
        let qualifierPart = qualifier.map { "-" + BASpriteSet.slug($0.rawValue) } ?? ""
        return "\(slotPart)-\(BASpriteSet.slug(name))\(qualifierPart)"
    }

}

extension BAVariant {
    public enum Qualifier: Codable, Hashable, Sendable {
        case magic
        case gun
        case stab
        case swing
        /// FE Legendary Axe (from FE: Blinding/Blazing Blade)
        case armads
        case unknown(String)
    }
}

extension BAVariant.Qualifier: RawRepresentable {
    public init(rawValue: String) {
        self = switch rawValue {
        case Self.magic.rawValue: .magic
        case Self.gun.rawValue: .gun
        case Self.stab.rawValue: .stab
        case Self.swing.rawValue: .swing
        case Self.armads.rawValue: .armads
        default: .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .magic: "Magic"
        case .gun: "Gun"
        case .stab: "Stab"
        case .swing: "Swing"
        case .armads: "Armads"
        case .unknown(let rawValue): rawValue
        }
    }
}
