#!/usr/bin/env bash
set -uo pipefail

# global.o= — маркер загрузчика; _$_NNNN — таблица строк обфускатора
# (нужна на случай, если маркер в новой версии сменят)
PATTERNS='global\.o[[:space:]]*=|_\$_[0-9]{3,}'

EXCLUDES=':(exclude)*/node_modules/*
:(exclude)node_modules/*
:(exclude)*/dist/*
:(exclude)dist/*
:(exclude)*/vendor/*
:(exclude)vendor/*
:(exclude)*.min.js
:(exclude)*-lock.json
:(exclude)*.map'

if [ "${1:-}" = "--staged" ]; then
  FILES=$(git diff --cached --name-only --diff-filter=ACM -- '*.js' '*.mjs' '*.cjs' '*.ts' '*.jsx' '*.tsx' $EXCLUDES)
  [ -z "$FILES" ] && exit 0
  HITS=$(echo "$FILES" | xargs -r grep -lE "$PATTERNS" 2>/dev/null || true)
else
  HITS=$(git grep -lE "$PATTERNS" -- '*.js' '*.mjs' '*.cjs' '*.ts' '*.jsx' '*.tsx' $EXCLUDES 2>/dev/null || true)
fi

if [ -n "$HITS" ]; then
  echo ""
  echo "!!! injection code detected (global.o):"
  echo "$HITS" | sed 's/^/    /'
  echo ""
  exit 1
fi
exit 0
