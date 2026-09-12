#!/usr/bin/env bash
set -euo pipefail

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
OUT_DIR="pdf"
mkdir -p "$OUT_DIR"

for md in "$@"; do
  name="$(basename "${md%.*}" | sed 's/^Readme/resume/')"
  html="$(mktemp -t "$name").html"

  {
    cat <<'HEAD'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<style>
  @page { size: A4; margin: 14mm 15mm; }
  html { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
  body {
    font-family: -apple-system, "Helvetica Neue", Arial, sans-serif;
    font-size: 9.5pt;
    line-height: 1.45;
    color: #1a1a1a;
    margin: 0;
  }
  h1 {
    font-size: 20pt;
    letter-spacing: -0.01em;
    margin: 0 0 6pt;
  }
  h2 {
    font-size: 11pt;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: #000;
    border-bottom: 0.75pt solid #c8c8c8;
    padding-bottom: 3pt;
    margin: 16pt 0 8pt;
    break-after: avoid;
  }
  p { margin: 0 0 6pt; }
  ul { margin: 0 0 6pt; padding-left: 14pt; }
  li { margin: 0 0 2pt; }
  a { color: #1a1a1a; text-decoration: none; border-bottom: 0.5pt solid #b4b4b4; }
  blockquote {
    margin: 4pt 0 10pt;
    padding: 0 0 0 9pt;
    border-left: 1.5pt solid #dcdcdc;
    color: #3c3c3c;
    text-align: justify;
  }
  h2 + p, blockquote + p { break-before: avoid; }
  p:has(+ blockquote) { break-after: avoid; font-size: 10pt; }
  blockquote { break-inside: avoid; }
</style>
</head>
<body>
HEAD
    npx --yes marked --gfm < "$md"
    printf '</body></html>\n'
  } > "$html"

  "$CHROME" --headless --disable-gpu --no-pdf-header-footer \
    --print-to-pdf="$OUT_DIR/$name.pdf" "file://$html" 2>/dev/null

  rm -f "$html"
  echo "$OUT_DIR/$name.pdf"
done
