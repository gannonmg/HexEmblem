#  Combat
___

- Combat occurs between 2 `CharacterUnit`s 
    - Req: `GameModel`
- `Battle`[^tbi] requests for `App` to present `CombatScene`
    - Req: 
        - `BattleCore`[^tbi]
        - `CombatAdapter`
- `CombatAdapter` flow
    - Receives `CharacterUnit`s
        - Req: `GameModel`
    - Asks `CombatEvaluator` to evaluate combat math and provide `CombatSummary`
        - Req: `CCEvaluator`, `CombatModel`
    - For each`CombatStrike` in `CombatSummary`, build series of `[BAPlaybackEvent]`
        - Req: `BattleAnimationCore`
        
        
        
        
[^tbi]: To be implemented
