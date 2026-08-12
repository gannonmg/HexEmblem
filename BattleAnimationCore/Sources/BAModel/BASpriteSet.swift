//
//  BASpriteSet.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/7/26.
//

import Foundation

public struct BASpriteSet: Codable, Hashable, Sendable {
    public let id: String
    public let displayName: String
    public let tag: String?
    public let gender: Gender?
    public let author: String?
    public let rawFolder: String

    public enum Gender: String, Codable, Hashable, Sendable {
        case male
        case female
    }

    /// Parses "[Hero-Reskin] FE6 Armor +Basic Shield (Vanilla palette fix) [M] by tatata"
    public init(folderName: String) {
        let raw = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
        var working = raw

        // Leading [Tag]
        var parsedTag: String?
        if working.hasPrefix("["), let close = working.firstIndex(of: "]") {
            let start = working.index(after: working.startIndex)
            parsedTag = String(working[start..<close])
            working = String(working[working.index(after: close)...])
        }

        // Trailing " by Author"
        var parsedAuthor: String?
        if let byRange = working.range(of: " by ", options: .backwards) {
            parsedAuthor = String(working[byRange.upperBound...])
                .trimmingCharacters(in: .whitespaces)
            working = String(working[..<byRange.lowerBound])
        }

        // Gender marker — matched as a whole token so "(Vanilla palette fix)" is untouched
        var parsedGender: Gender?
        for token in ["[F]", "(F)"] where working.contains(token) {
            parsedGender = .female
            working = working.replacingOccurrences(of: token, with: "")
        }
        for token in ["[M]", "(M)"] where working.contains(token) {
            parsedGender = .male
            working = working.replacingOccurrences(of: token, with: "")
        }

        self.rawFolder = raw
        self.displayName = working.trimmingCharacters(in: .whitespaces)
        self.tag = parsedTag
        self.gender = parsedGender
        self.author = parsedAuthor
        self.id = BASpriteSet.slug(raw)
    }

    public static func slug(_ value: String) -> String {
        let mapped = value.map { $0.isLetter || $0.isNumber ? $0 : "-" }
        return String(mapped)
            .split(separator: "-", omittingEmptySubsequences: true)
            .joined(separator: "-")
    }
}
