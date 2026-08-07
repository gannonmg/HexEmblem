#!/usr/bin/env bash
set -euo pipefail

# Render Mermaid sources (*.mmd, including hidden .*.mmd) to sibling SVGs.
#   render.sh              -> render every *.mmd in the repo
#   render.sh a.mmd b.mmd  -> render only the given files (repo-root-relative)
# A hidden source ".foo.mmd" renders to a visible "foo.svg".
#
# The .mmd is the source of truth; the SVG is generated. GitHub cannot render the
# ELK layout inline, so we commit an ELK-rendered SVG instead. Labels use Mermaid
# markdown strings with htmlLabels:false so the output uses native <text> (HTML
# labels become <foreignObject>, which renders blank when an SVG is embedded as
# an image on GitHub).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG="$SCRIPT_DIR/mermaid.config.json"
PUPPETEER="$SCRIPT_DIR/puppeteer.config.json"
MMDC="$SCRIPT_DIR/node_modules/.bin/mmdc"

if [ ! -x "$MMDC" ]; then
  echo "mmdc not found — run 'npm install' in $SCRIPT_DIR first (see the root README, 'Project setup')." >&2
  exit 1
fi

cd "$ROOT"

render_one() {
  local src="$1" dir base out
  dir="$(dirname "$src")"
  base="$(basename "$src" .mmd)"
  base="${base#.}"                 # strip a single leading dot for the visible output
  out="$dir/$base.svg"
  echo "rendering $src -> $out"
  "$MMDC" -i "$src" -o "$out" -c "$CONFIG" -p "$PUPPETEER" -b transparent
}

if [ "$#" -gt 0 ]; then
  for src in "$@"; do render_one "$src"; done
else
  while IFS= read -r -d '' src; do render_one "$src"; done \
    < <(find . -type f -name '*.mmd' -not -path '*/node_modules/*' -print0)
fi
