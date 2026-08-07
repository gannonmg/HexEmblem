//
//  CharacterStats.swift
//  hex-emblem-swift-poc
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation

/// A struct representing a Characters Stat Block.
/// May represent either a character's "Base" stats acquired through natural growth,
/// or a character's "Effective" stats after evaluation bonus from skills, weapons, and armor.
public struct CharacterStatBlock: Sendable {
    private(set) var maxHp: Int // Maximum Health
    private(set) var strength: Int // Physical Attack
    private(set) var defense: Int // Physical Defense
    private(set) var intelligence: Int // Magic Attack
    private(set) var willpower: Int // Magic Defense
    private(set) var speed: Int // Combat Speed
    private(set) var dexterity: Int // Stealth, Accuracy, Evasion
    private(set) var luck: Int // Crit Avoid

    public private(set) subscript(_ stat: CharacterStat) -> Int {
        get {
            switch stat {
            case .maxHp: maxHp
            case .strength: strength
            case .defense: defense
            case .intelligence: intelligence
            case .willpower: willpower
            case .speed: speed
            case .dexterity: dexterity
            case .luck: luck
            }
        }
        set {
            switch stat {
            case .maxHp: self.maxHp = newValue
            case .strength: self.strength = newValue
            case .defense: self.defense = newValue
            case .intelligence: self.intelligence = newValue
            case .willpower: self.willpower = newValue
            case .speed: self.speed = newValue
            case .dexterity: self.dexterity = newValue
            case .luck: self.luck = newValue
            }
        }
    }

    func applyingEffects(_ effects: [CharacterEffect]) -> CharacterStatBlock {
        var copy = self

        for effect in effects {
            switch effect {
            case .statBoost(let characterStat, let amount):
                copy[characterStat] += amount
            case .equipmentWeight(let weight):
                copy[.speed] -= weight
            default:
                break
            }
        }

        return copy
    }
}

public enum CharacterStat: Sendable {
    case maxHp
    case strength
    case defense
    case intelligence
    case willpower
    case speed
    case dexterity
    case luck
}
