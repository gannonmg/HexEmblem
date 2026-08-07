//
//  CharacterUnit.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/2/26.
//

import Foundation

public final class CharacterUnit {

    public let characterID: CharacterID

    // MARK: Stats
    public let baseStatBlock: CharacterStatBlock

    public private(set) lazy var currentHealth: Int = { effectiveStats.maxHp }()

    // MARK: Equipment
    public var weapon: Weapon { .fists }
    public var armor: Armor { .unarmored }

    private var _weapon: Weapon?
    private var _armor: Armor?

    // MARK: - Init
    public init(
        characterID: CharacterID = CharacterID(),
        baseStatBlock: CharacterStatBlock,
        weapon: Weapon? = nil,
        armor: Armor? = nil
    ) {
        self.characterID = characterID
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

    public func critRateBonus() -> Double {
        activeEffects()
            .compactMap {
                guard case .critRateBonus(let percent) = $0 else { return nil }
                return percent
            }
            .reduce(0, +)
    }

    public func critAvoidBonus() -> Double {
        let equipmentBonus: Double = activeEffects()
            .compactMap {
                guard case .critAvoidBonus(let percent) = $0 else { return nil }
                return percent
            }
            .reduce(0, +)

        let effectiveLuck = effectiveStats[.luck]
        return equipmentBonus + Double(effectiveLuck)
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
    @MainActor
    public static let gwendolyn = CharacterUnit(
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
        weapon: .sword,
        armor: .plate
    )

    @MainActor
    public static let badGuy = CharacterUnit(
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
        weapon: .sword,
        armor: .plate
    )

    @MainActor
    public static let hunter = CharacterUnit(
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
