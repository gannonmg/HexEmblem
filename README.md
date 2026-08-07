# HexEmblem

## Project setup

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
