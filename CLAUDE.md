# HexEmblem

Hex-based tactical RPG in SpriteKit (macOS). Battle animations are sourced from the Fire
Emblem GBA community repo ([FE-Repo](https://github.com/Klokinator/FE-Repo)) and imported
into a processed, catalog-indexed form.

## Working agreement

See [.claude/working-agreement.md](.claude/working-agreement.md). It is injected into
context on every prompt — read it before responding.

## Packages

Three local SPM packages. DTOs sit below the logic that produces them so nothing needs a
circular dependency.

```
GameCore/GameModels      CharacterUnit, Weapon, CharacterStats, DamageType
        ↑
CombatCore
  ├─ CombatModels        CombatSummary, CombatStrike, StrikeResult, DamageInstance, CombatRules
  ├─ CombatCore          resolver, plan builder, calculators (internal)
  └─ CCEvaluator         public facade — CombatEvaluator
        ↑
BattleAnimationCore
  ├─ BAModel             BAManifest, BACatalog, BAModeID, BAWeaponID, BASpriteSet, BAVariant
  ├─ ScriptParser        FEditorAdv .txt → BAScript
  ├─ ImageUtilities      PNG decode/crop/write
  ├─ ImportTooling       BAImporter
  ├─ BAImportTool        executable — regenerates ProcessedAnimations + catalog.json
  └─ BAPlayback          BAProcessedAnimationStore (@_exported imports BAModel)
```

The app links `BAPlayback` and `GameModels`.

## Animation pipeline

`Resources/SourceAnimations/<SpriteSet>/<N>. <Variant>/` → `swift run BAImportTool` →
`Resources/ProcessedAnimations/<id>/{manifest.json, frames/}` plus a top-level
`catalog.json`.

- Source folder structure carries the taxonomy: the parent folder encodes sprite set
  (tag, display name, gender, author) and the numbered child encodes weapon slot +
  qualifier (`3. Axe (Armads)` → slot 3, qualifier "Armads").
- `catalog.json` is the lookup index — sprite set, variant, and which modes each animation
  actually contains. Mode fallback resolves against it before touching disk.
- Frames are full 240×160 GBA canvases, not sprite crops. Two combatants render at the
  same origin with one mirrored.
- Regenerating requires re-running the import tool; the processed tree is generated output.

## Domain notes

FE animation scripts use numbered modes (1 melee, 3 melee crit, 5 ranged, 6 ranged crit, 7/8 dodge,
12 miss; 2 and 4 are engine-generated and never scripted). Command opcodes (`C1A` impact,
`C01` wait-for-HP, `C06`/`C0D` handshake) drive hit timing. Animator comments in the
scripts are unreliable — `C01` is labeled "NOP" everywhere but actually means
wait-for-HP-deplete. Map by opcode against the FEBuilderGBA tables, never by comment.

Background: `.localDocs/HANDOFF-battle-animation-scripts.md`.

## Commands

```bash
swift run BAImportTool          # from BattleAnimationCore/ — regenerates processed animations
swift test                      # per package
xcodebuild -project HexEmblem.xcodeproj -scheme HexEmblem -destination 'platform=macOS' build
```
