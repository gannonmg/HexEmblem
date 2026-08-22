#  Outline

## Dictionary
- Battle: An event between two or more opposing armies, featuring many units on a hex grid.
- Combat: An event between two units of opposing forces. Animated, but not interactable. Deterministic based on incoming units' stats and a reproducable seed.
- CharacterUnit, aka Unit: An individual character in a larger army. Stats increase by growing levels, while skills and class progression are tracked on a different track.
- Force: A group of Units within a larger Army
- Army: The entire allied forces controlled by a player or NPC commander.
- BattleMap: The hex map that battles take place on. Units move around this map.
- WorldMap: The hex map that represents the larger world and displays controlled territory. Forces move around this map.

Battles begin when two or more forces contest a single Hex on the world map. Combats begin when one unit attacks another unit from a valid range, dependent on their equipped weapon.

## Dependencies
> Features are the highest level (least indented) objects on this graph. As the graph goes down layers, it shows what each feature is dependent on. Dependencies may be repeated within a tree, but should never be truly.

- Battle
    - BattleState
    - BattleMap
        - BattleHex
            - HexCore
        - BattleUI
    - Combat
        - CombatEvaluator
        - CombatAnimator
            - CombatModels.CombatSummary
            - CombatAnimationCore*                
                
* BattleAnimationCore should be renamed to CombatAnimationCore

## Roadmap

