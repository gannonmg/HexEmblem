//
//  AnimationID.swift
//  GameCore
//
//  Created by Matt Gannon on 8/8/26.
//

public typealias AnimationID = String

extension AnimationID {

    /// Cowboy, male, by MeatofJustice.
    /// Slots: 5 bow (+ "Gun" variant), 8 unarmed.
    public static let cowboyMale: AnimationID = "Crossbow-Cowboy-M-by-MeatofJustice"

    /// Halberdier +Axes, male, by TBA. Widest melee coverage in the library.
    /// Slots: 2 lance, 3 axe (stab/swing, each with a magic variant), 4 handaxe, 5 bow, 8 unarmed.
    public static let halberdierAxesMale: AnimationID = "Custom-Halb-Halberdier-Axes-M-by-TBA"

    /// Halberdier Gwendolyn, female, by UltraFenix.
    /// Slots: 2 lance, 3 axe (stab/swing), 4 handaxe, 8 unarmed.
    public static let halberdierGwendolynFemale: AnimationID = "Custom-Halb-Halberdier-Gwendolyn-F-by-UltraFenix"

    /// Militia (Deserter), female.
    /// Slots: 2 lance, 8 unarmed.
    public static let militiaDeserterFemale: AnimationID = "Custom-Lance-Militia-Deserter-F"

    /// Militia (Deserter), male, by Alusq.
    /// Slots: 2 lance, 8 unarmed.
    public static let militiaDeserterMale: AnimationID = "Custom-Lance-Militia-Deserter-M-by-Alusq"

    /// FE6 Armor +Basic Shield, female. The only set covering every weapon slot.
    /// Slots: 1 sword (+ knife, v2), 3 axe (+ Armads, v2), 4 handaxe, 5 bow, 6 magic, 7 staff, 8 unarmed (+ no shield).
    public static let armorKnightFemale: AnimationID = "Hero-Reskin-FE6-Armor-Basic-Shield-Vanilla-palette-fix-F"

    /// FE6 Armor +Basic Shield, male, by tatata.
    /// Slots: 1 sword, 3 axe, 4 handaxe, 8 unarmed.
    public static let armorKnightMale: AnimationID = "Hero-Reskin-FE6-Armor-Basic-Shield-Vanilla-palette-fix-M-by-tatata"

    /// Hunter, female, by MeatOfJustice.
    /// Slots: 5 bow, 8 unarmed.
    public static let hunterFemale: AnimationID = "HunterM-Hunter-F-by-MeatOfJustice"

    /// Hunter, male, by MeatOfJustice.
    /// Slots: 5 bow, 8 unarmed.
    public static let hunterMale: AnimationID = "HunterM-Hunter-M-by-MeatOfJustice"

    /// General, ungendered
    ///  All or most slots available with many alts
    public static let generalVanilla: AnimationID = "General-Base-Vanilla-Weapons-U"

    /// Bard (Nils), male. Long lead-in from the spell release to the HP barrier — useful for
    /// testing the drain hold.
    /// Slots: 6 magic, 7 staff (+ magic), 8 dragonstone/refresh/transform variants.
    public static let bardNilsMale: AnimationID = "Bard-Base-M-Nils-Weapons"
}
