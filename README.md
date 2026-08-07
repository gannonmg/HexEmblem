# Hex Emblem - A Fire Emblem Ripoff
___

Proof of concept for a hex-based Tactical RPG drawing inspiration from the Fire Emblem franchise.

An opportunity to learn some game dev and practice my Swift skills alongside broader Xcode project architecture.

Graphics and animation leaning on decades of work in the Fire Emblem fan community. All animations and resources from [The Communal Fire Emblem Graphics Repository](https://github.com/Klokinator/FE-Repo).

## Broad Ideas - "The Ideal Game"
___

### Armies

The main inspiration from this game comes from the usual limits on Character use in mainline FE entries. The games inundate you with a deluge of great characters, and limit you to just using 12-14 of them. In my ideal game, you'd have 2+ armies to manage, split as you want. You'd be forced to use suboptimal units as your armies race to complete objectives in parallel.

### Hexes all the way down (well, at least 2 layers of hexes)

While the battle maps are hexes instead of FE's traditional grid, the overworld map is also a hex crawl. Travelling between hexes takes time, pushing you to reach objectives. Different travel speeds might have different effects. Traveling quickly might cause you to attract enemy attention or miss discovering a hidden treasure. Travelling slowly may result in the opposite, but make sure that your enemy doesn't reach your objective too much before you!

I was both very excited and a bit crestfallen to see a similar feature revealed during yesterday's (8/4) Nintendo Direct for Fire Emblem: Fortune's Weave. I didn't steal it!

## Blue Sky Feature List
___
If I had unlimited skill, time, budget, whatever, here's what I'd love to see.

- Multiple armies
- Talent trees instead of traditional class progression (more Pathfinder or Plotweaver than D&D).
- Resource management
- Unit support ranks
    - Marriage and Child Units. I don't care how hamfisted they were in FE: Fates, there is something about recruiting a child unit that kicks ass despite you sacrificing optimization for a cool hair color.
    - FE: Awakening/Fates style pair-ups - not necessarily same tile/hex, but adjacent units may assist/guard
- Territory control/defense on the world map.
    - Forts + Unit "Leadership" skill to deploy defensive battalions.
- Resource lines between your army and your territory.

## Macro Dependency Graph
___
[Add macro scale graph here]

## Project setup
___
Diagrams in this repo are authored as Mermaid source (`.mmd`) and rendered to
committed SVGs by a pre-commit hook. First-time setup after cloning:

1. Install [Node.js](https://nodejs.org) (LTS is fine) — used by the diagram renderer.
2. Install the render tools:
   ```bash
   cd tools/diagrams
   npm install
   ```
3. Enable the git hooks (one-time, per clone):
   ```bash
   git config core.hooksPath .githooks
   ```

Now, editing any `.mmd` and committing automatically re-renders its sibling SVG
and includes it in the same commit — no manual export. To render on demand:

```bash
cd tools/diagrams && npm run render
```

See [`tools/diagrams/README.md`](tools/diagrams/README.md) for how the diagram
pipeline works and why sources are hidden (`.mmd`) with generated SVGs.
