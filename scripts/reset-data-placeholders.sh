#!/usr/bin/env bash
# Restore Partner_Account placeholder in sample data (undo patch-partner-record-type.sh).
# Uses git when available; otherwise replaces 18-char RecordType Ids in known files.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
if git rev-parse --git-dir >/dev/null 2>&1; then
  git checkout -- data/pronto-export/pronto-Account-import.json data/pronto-export/import-overrides.json 2>/dev/null || true
  echo "Restored data files from git (if tracked)."
else
  echo "Not a git repo: manually set RecordTypeId back to __PARTNER_ACCOUNT_RECORD_TYPE_ID__ in:"
  echo "  data/pronto-export/pronto-Account-import.json"
  echo "  data/pronto-export/import-overrides.json"
fi
