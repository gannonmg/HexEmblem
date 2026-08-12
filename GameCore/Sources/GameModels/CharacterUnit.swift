//
//  CharacterUnit.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation

public final class CharacterUnit {

    public let characterID: CharacterID
    /// Temporary value until we've decided how class, weapon, palettes, etc influence our decisions for animation selection
    public let animationID: AnimationID

    // MARK: Stats
    public let baseStatBlock: CharacterStatBlock

    // Health tracking
    public private(set) lazy var currentHealth: Int = { effectiveStats.maxHp }()
    public var maxHealth: Int { effectiveStats.maxHp }
    /// Includes current and max health. Always correct at time of retrieval.
    public var healthStatus: UnitHealthStatus { .init(currentHealth: currentHealth, maxHealth: maxHealth) }

    // MARK: Equipment
    public var weapon: Weapon { _weapon ?? .fists }
    public var armor: Armor { _armor ?? .unarmored }

    private var _weapon: Weapon?
    private var _armor: Armor?

    // MARK: - Init
    public init(
        characterID: CharacterID = CharacterID(),
        animationID: AnimationID,
        baseStatBlock: CharacterStatBlock,
        weapon: Weapon? = nil,
        armor: Armor? = nil
    ) {
        self.characterID = characterID
        self.animationID = animationID
        self.baseStatBlock = baseStatBlock
        self._weapon = weapon
        self._armor = armor
    }

    // MARK: Accessers
    public func takeDamage(_ damage: Int) {
        let damage = max(damage, 0)
        currentHealth = max(currentHealth - damage, 0)
    }

    public var isAlive: Bool { 0 < currentHealth }

    // MARK: - Functions
    // TODO: Get rid of all this duplicate compactMap / reduce code for a unified solution
    public func getResistances() -> [DamageType: Double] {
        let resistances: [DamageType: Double] = activeEffects()
            .reduce([:]) { partialResult, effect in
                if case .damageResistance(let damageType, let percent) = effect {
                    var prCopy = partialResult
                    prCopy[damageType, default: 0] += percent
                    return prCopy
                } else {
                    return partialResult
                }
            }

        return resistances
    }

    public var toHitBonus: Double {
        activeEffects()
            .compactMap {
                guard case .toHitBonus(let percent) = $0 else { return nil }
                return percent
            }
            .reduce(0, +)
    }

    public var evasionBonus: Double {
        activeEffects()
            .compactMap {
                guard case .evasionBonus(let percent) = $0 else { return nil }
                return percent
            }
            .reduce(0, +)
    }

    public var critRateBonus: Double {
        activeEffects()
            .compactMap {
                guard case .critRateBonus(let percent) = $0 else { return nil }
                return percent
            }
            .reduce(0, +)
    }

    public var critAvoidBonus: Double {
        activeEffects()
            .compactMap {
                guard case .critAvoidBonus(let percent) = $0 else { return nil }
                return percent
            }
            .reduce(0, +)
    }

    public func activeEffects() -> [CharacterEffect] {
        let weaponEffects = weapon.effects
        let armorEffects = armor.effects
        return weaponEffects + armorEffects
    }

    public var effectiveStats: CharacterStatBlock {
        return baseStatBlock.applyingEffects(activeEffects())
    }
}

extension CharacterUnit {
    public static func gwendolyn() -> CharacterUnit {
        CharacterUnit(
            animationID: .halberdierGwendolynFemale,
            baseStatBlock: .init(
                maxHp: 23,
                strength: 8,
                defense: 6,
                intelligence: 3,
                willpower: 3,
                speed: 8,
                dexterity: 4,
                luck: 6
            ),
            weapon: .lance,
            armor: .plate
        )
    }

    public static func badGuy() -> CharacterUnit {
        CharacterUnit(
            animationID: .generalVanilla, // .armorKnightMale,
            baseStatBlock: .init(
                maxHp: 27,
                strength: 6,
                defense: 7,
                intelligence: 2,
                willpower: 2,
                speed: 3,
                dexterity: 4,
                luck: 0
            ),
            weapon: .lance,
            armor: .plate
        )

    }

    public static func hunter() -> CharacterUnit {
        CharacterUnit(
            animationID: .hunterFemale,
            baseStatBlock: .init(
                maxHp: 18,
                strength: 4,
                defense: 4,
                intelligence: 2,
                willpower: 5,
                speed: 9,
                dexterity: 9,
                luck: 5
            ),
            weapon: .bow,
            armor: .leather
        )
    }

    public static func bard() -> CharacterUnit {
        CharacterUnit(
            animationID: .bardNilsMale,
            baseStatBlock: .init(
                maxHp: 18,
                strength: 1,
                defense: 3,
                intelligence: 5,
                willpower: 6,
                speed: 7,
                dexterity: 7,
                luck: 8
            ),
            weapon: .lightningBolt,
            armor: .leather
        )
    }

    public static func assassin() -> CharacterUnit {
        CharacterUnit(
            animationID: .assassin,
            baseStatBlock: .init(
                maxHp: 20,
                strength: 4,
                defense: 3,
                intelligence: 3,
                willpower: 5,
                speed: 12,
                dexterity: 10,
                luck: 8
            ),
            weapon: .dagger,
            armor: .leather
        )
    }
}
