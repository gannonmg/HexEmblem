//
//  BAVariant.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/8/26.
//

import Foundation

public struct BAVariant: Codable, Hashable, Sendable {
    public let slot: BAWeaponID?
    public let name: String
    public let qualifier: String?
    public let rawFolder: String

    /// Parses "3. Axe (Armads)" into slot 3, name "Axe", qualifier "Armads"
    public init(folderName: String) {
        let raw = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
        var remainder = raw
        var parsedSlot: BAWeaponID?

        // Leading "<n>. "
        let ordinalSplit = raw.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        if ordinalSplit.count == 2 {
            let candidate = ordinalSplit[0]
            if candidate.hasSuffix(".") {
                let digits = candidate.dropLast()
                if !digits.isEmpty, digits.allSatisfy(\.isNumber), let number = Int(digits) {
                    parsedSlot = BAWeaponID(rawValue: number)
                    remainder = String(ordinalSplit[1]).trimmingCharacters(in: .whitespaces)
                }
            }
        }

        // Trailing "(qualifier)"
        var parsedQualifier: String?
        if remainder.hasSuffix(")"), let open = remainder.lastIndex(of: "(") {
            let start = remainder.index(after: open)
            let end = remainder.index(before: remainder.endIndex)
            parsedQualifier = String(remainder[start..<end])
            remainder = String(remainder[..<open]).trimmingCharacters(in: .whitespaces)
        }

        self.rawFolder = raw
        self.slot = parsedSlot
        self.name = remainder
        self.qualifier = parsedQualifier
    }

    public var idComponent: String {
        let slotPart = slot.map { String($0.rawValue) } ?? "x"
        let qualifierPart = qualifier.map { "-" + BASpriteSet.slug($0) } ?? ""
        return "\(slotPart)-\(BASpriteSet.slug(name))\(qualifierPart)"
    }
}
