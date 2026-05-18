#!/usr/bin/env bash
# Scan [project-root]/modules/ for DONE.md files and print completion status per task output directory.
# DONE.md must have ## Status: DONE|BLOCKED|PARTIAL as first heading, ## Blockers present.
# Usage: ./check-done.sh [project-root]
#   project-root defaults to ./project

PROJECT_ROOT="${1:-./project}"
MODULES_DIR="$PROJECT_ROOT/modules"

if [[ ! -d "$MODULES_DIR" ]]; then
  echo "ERROR: modules directory not found at $MODULES_DIR"
  exit 1
fi

echo "=== Task Output Completion Status ==="
echo "Project: $PROJECT_ROOT"
echo ""

TOTAL=0
DONE=0
BLOCKED=0
PARTIAL=0
MISSING=0

for module_dir in "$MODULES_DIR"/*/; do
  module_name=$(basename "$module_dir")
  done_file="$module_dir/DONE.md"
  TOTAL=$((TOTAL + 1))

  if [[ ! -f "$done_file" ]]; then
    echo "[ MISSING ] $module_name — no DONE.md"
    MISSING=$((MISSING + 1))
    continue
  fi

  status=$(grep -m1 "^## Status:" "$done_file" | sed 's/## Status: //')

  case "$status" in
    DONE*)
      echo "[  DONE   ] $module_name"
      DONE=$((DONE + 1))
      ;;
    BLOCKED*)
      echo "[ BLOCKED ] $module_name"
      blocker=$(grep -A2 "## Blockers" "$done_file" | tail -1)
      echo "            $blocker"
      BLOCKED=$((BLOCKED + 1))
      ;;
    PARTIAL*)
      echo "[ PARTIAL ] $module_name"
      PARTIAL=$((PARTIAL + 1))
      ;;
    *)
      echo "[UNKNOWN  ] $module_name — status: $status"
      ;;
  esac
done

echo ""
echo "=== Summary ==="
echo "Total:   $TOTAL"
echo "Done:    $DONE"
echo "Partial: $PARTIAL"
echo "Blocked: $BLOCKED"
echo "Missing: $MISSING"

if [[ "$DONE" -eq "$TOTAL" && "$TOTAL" -gt 0 ]]; then
  echo ""
  echo "All task outputs complete. Ready for integration."
  exit 0
else
  echo ""
  echo "Project incomplete. Review blocked/partial/missing task outputs."
  exit 1
fi
