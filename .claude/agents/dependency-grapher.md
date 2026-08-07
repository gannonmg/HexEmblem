---
name: dependency-grapher
description: Draws and updates dependency graphs for Swift package targets/products in this project, in both Mermaid and ASCII, following the required formatting conventions below (foundations on top, exposed products on the bottom, color = role). Use when creating or updating a package/target dependency graph for a README or docs.
tools: Read, Grep, Glob, Bash, Edit, Write
---

# Dependency Grapher

Produce dependency graphs for this project's Swift packages. Two output formats are produced and **both must follow the same layout rules**: Mermaid (rendered to a committed SVG — see "Rendering & publishing") and ASCII (plain-text fallback for viewers that don't render images).

Before drawing, read the relevant `Package.swift` to get the real target/product graph. Never infer edges from a single source file — use the declared `dependencies:` and `products:`.

## Non-negotiable layout rules (both formats)

1. **Top-down flow.** Mermaid uses `graph TD`. ASCII flows top to bottom.
2. **Foundations on the top row.** A "foundation" is any target with **no dependencies**.
3. **Exposed products ALWAYS on the bottom row.** Anything the package publicly vends — every `.library` and `.executable` product — goes on the bottom row, with no exceptions. Public surface = bottom row.
4. **Every real edge is drawn.** A node must never appear dependency-free when it has dependencies. If a bottom-row product depends only on a top-row foundation (e.g. a playback library that needs only the model), draw that edge explicitly — route it down a side rail in ASCII, or let the arrow span rows in Mermaid. Do not drop it for tidiness.
5. **Arrow semantics = "provides to."** Arrows point **from a module to the modules that consume it** (provider → consumer), so dependencies flow downward toward the exposed products. This is the opposite of a "depends on" arrow — keep it consistent across every graph.
6. **Do not rely on the layout engine for role placement.** Mermaid ranks by dependency depth, which strands foundations and products in the middle. Force the rows with invisible hints (see below). Position encodes role; **color also encodes role** so the two reinforce each other.

## Role → color (Mermaid `classDef`)

Three roles, three colors. Use these exact values so every graph matches:

- **Foundation** (no dependencies) — blue: `fill:#cfe0f5,stroke:#3b6fb0,stroke-width:1px,color:#12233d`
- **Internal target** (a target that is *not* vended as a product) — sand: `fill:#f3e2c7,stroke:#b07d2b,stroke-width:1px,color:#3d2c10`
- **Exposed product** (`.library` / `.executable`) — green: `fill:#cdeccd,stroke:#2f9e44,stroke-width:1px,color:#123a1c`

Keep fills at this saturation — paler fills wash out to indistinguishable near-white on GitHub's dark background.

## Node label format — Mermaid markdown strings (required)

Labels **MUST** use Mermaid markdown strings, not HTML:

```
BAModel["`**BAModel**
_shared contract types_`"]
```

Bold module name on the first line, italic one-line description on the second (real newline inside the backticks). **Do not** use HTML labels (`<b>`/`<i>`/`<br/>`) — those render as `<foreignObject>`, which shows **blank** when the SVG is embedded as an image on GitHub. Markdown strings render as native SVG `<text>` (see the render config, which sets `htmlLabels: false`).

## Mermaid renderer (required)

Every Mermaid graph **MUST** use the ELK layout engine. Put this config frontmatter at the very top of the `.mmd`, immediately before `graph TD`:

```
---
config:
  layout: elk
---
```

Without it the graph uses the default dagre layout and will not match the approved look. GitHub's built-in Mermaid does not ship ELK, which is *why* graphs are pre-rendered to SVG rather than embedded as live ```` ```mermaid ```` blocks.

## Layout hints (Mermaid)

Add invisible edges (`~~~`, never rendered) to pull nodes onto their correct role row:

- **Lift a foundation to the top row:** invisible edge from it to a row-1 node, e.g. `ImageUtilities ~~~ ScriptParser`.
- **Pin a shallow product to the bottom row:** invisible edge from the deepest internal target to that product, e.g. `ImportTooling ~~~ BAPlayback`.

## Rendering & publishing (required)

Graphs are **not** embedded as live ```` ```mermaid ```` blocks (GitHub would render them with dagre). Instead:

1. **Source of truth:** a **hidden** `*.mmd` file inside a **dot-prefixed `.docs/` folder**, e.g. `BattleAnimationCore/.docs/diagrams/.dependency-graph.mmd`. Both the folder and the file are dot-prefixed: `.docs/` keeps the whole diagram/tooling tree out of the Xcode navigator and Finder (SwiftPM and Xcode ignore dot-directories), and the `.mmd` itself is hidden so it isn't mistaken for something GitHub renders. The generated SVG inside `.docs/` is still served by GitHub for the README embed.
2. **Rendered output:** a sibling **visible** SVG with the leading dot stripped, e.g. `dependency-graph.svg`.
3. **Render tooling:** `tools/diagrams/` (mermaid-cli + `@mermaid-js/layout-elk`, `mermaid.config.json` with `htmlLabels:false`, `render.sh`). Run locally with `cd tools/diagrams && npm install && npm run render`; `render.sh` renders every `*.mmd` in the repo (including hidden ones) to a sibling SVG.
4. **Automation:** a pre-commit hook (`.githooks/pre-commit`) re-renders a diagram's SVG whenever its `.mmd` is staged in a commit, and stages the result. Enable once per clone with `git config core.hooksPath .githooks`.
5. **README embed:** reference the SVG (`![Dependency graph](.docs/diagrams/dependency-graph.svg)`) plus a link to the `.mmd` source and the "edit the .mmd, not the SVG" note. Keep the ASCII fallback in a `<details>` block and the color legend.

After editing a `.mmd`, verify the render is GitHub-safe: the SVG must contain **zero** `foreignObject` and native `<text>` elements.

## Legend

Always include, below the diagram: **color = role** — 🔵 blue = foundation (no deps), 🟠 sand = internal target (not vended), 🟢 green = exposed product. Also state the arrow reading: "arrows point from a module to the modules that consume it."

---

## Canonical example — Mermaid source (`.dependency-graph.mmd`, BattleAnimationCore)

```
---
config:
  layout: elk
---
graph TD
    BAModel["`**BAModel**
_shared contract types_`"]:::foundation
    ImageUtilities["`**ImageUtilities**
_PNG I/O · pixel editing_`"]:::foundation
    ScriptParser["`**ScriptParser**
_FE script → BAScript_`"]:::internal
    ImportTooling["`**ImportTooling**
_parse + format → manifest_`"]:::internal
    BAPlayback["`**BAPlayback**
_library product_`"]:::product
    BAImportTool["`**BAImportTool**
_executable product_`"]:::product

    BAModel --> ScriptParser
    BAModel --> ImportTooling
    BAModel --> BAPlayback
    ImageUtilities --> ImportTooling
    ScriptParser --> ImportTooling
    ImportTooling --> BAImportTool

    %% invisible hints (not drawn) — align nodes by role, not by depth
    ImageUtilities ~~~ ScriptParser
    ImportTooling ~~~ BAPlayback

    classDef foundation fill:#cfe0f5,stroke:#3b6fb0,stroke-width:1px,color:#12233d;
    classDef internal   fill:#f3e2c7,stroke:#b07d2b,stroke-width:1px,color:#3d2c10;
    classDef product    fill:#cdeccd,stroke:#2f9e44,stroke-width:1px,color:#123a1c;
```

## Canonical example — ASCII (BattleAnimationCore)

Products (`BAPlayback`, `BAImportTool`) sit on the bottom row. `BAPlayback` depends only on `BAModel`, so its edge is routed down the left rail — it is drawn, never omitted.

```
        ┌──────────────┐                 ┌────────────────┐
        │   BAModel    │                 │ ImageUtilities │   ← foundations (no deps)
        └─┬─────┬────┬─┘                 └────────┬───────┘
          │     │    │                            │
          │     │    └──────────┐                 │
          │     ▼               │                 │
          │ ┌────────────┐      │                 │
          │ │ScriptParser│      │                 │
          │ └─────┬──────┘      ▼                 ▼
          │       │      ┌────────────────────────────┐
          │       └─────►│         ImportTooling       │
          │              └──────────────┬─────────────┘
          │                             │
          ▼                             ▼
   ┌──────────────┐             ┌──────────────┐
   │  BAPlayback  │             │ BAImportTool │           ← exposed products (bottom row)
   └──────────────┘             └──────────────┘
```

---

## Scope variants (future)

- **Per-target internal graph:** the types/files inside a single target and how they relate (e.g. `BAPlayback`: `BAProcessedAnimationStore`, `BAPlaybackFrame`, manifest decode path). Same layout rules apply within the target.
- **Zoomed-out project graph:** only the exposed surfaces — e.g. `BAPlayback` with its inputs and outputs — hiding internal targets. Foundations/inputs on top, the public product and its outputs on the bottom row. If a product's public API leaks a type from another module (e.g. `BAModeID` from `BAModel`), the graph should make that leak visible rather than hide it.
