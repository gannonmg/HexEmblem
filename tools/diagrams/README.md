# Diagram rendering

Committed Mermaid diagrams are stored as **hidden** `*.mmd` files (e.g.
`.dependency-graph.mmd`) next to where their rendered `*.svg` is used. The `.mmd`
is the source of truth; the SVG is generated — GitHub can't render the ELK layout
inline, so we commit an ELK-rendered SVG instead.

- **Edit the `.mmd`, never the `.svg`.**
- A pre-commit hook (`.githooks/pre-commit`) re-renders a diagram's SVG whenever
  its `.mmd` is part of a commit, and stages the result. Enable it once with
  `git config core.hooksPath .githooks` (see the root README's "Project setup").

## Rendering locally (optional)

```bash
cd tools/diagrams
npm install
npm run render   # renders every *.mmd in the repo to a sibling *.svg
```

## Why hidden `.mmd` + generated SVG

- GitHub's Mermaid bundle does not include the ELK layout engine, so a live
  ```` ```mermaid ```` block renders with the inferior dagre layout. Pre-rendering
  with `mermaid-cli` + `@mermaid-js/layout-elk` gives the ELK layout everywhere.
- Labels use Mermaid **markdown strings** (`` "`**Name**\n_desc_`" ``) with
  `htmlLabels: false` so the SVG uses native `<text>`. HTML labels
  (`<b>`/`<i>`/`<br/>`) become `<foreignObject>`, which renders **blank** when an
  SVG is embedded as an image on GitHub.
- The `.mmd` is dot-prefixed so it doesn't clutter the file listing or get
  mistaken for something GitHub will render — the visible artifact is the SVG.
