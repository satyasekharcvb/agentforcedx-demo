#!/usr/bin/env bash
# Replace __PARTNER_ACCOUNT_RECORD_TYPE_ID__ in data/pronto-export JSON with the
# Partner_Account RecordType Id from the target org. Run after Account record types exist.
set -euo pipefail
TARGET_ORG="${1:?Usage: $0 <target-org-alias-or-username>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

RTID=$(sf data query \
  --query "SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Partner_Account' LIMIT 1" \
  --target-org "$TARGET_ORG" \
  --json | python3 -c 'import json,sys; r=json.load(sys.stdin); print(r["result"]["records"][0]["Id"])')

export RTID
python3 - "$ROOT" <<'PY'
import os, pathlib, sys
root = pathlib.Path(sys.argv[1])
rt = os.environ["RTID"]
for p in (root / "data" / "pronto-export").glob("*.json"):
    text = p.read_text(encoding="utf-8")
    if "__PARTNER_ACCOUNT_RECORD_TYPE_ID__" in text:
        p.write_text(text.replace("__PARTNER_ACCOUNT_RECORD_TYPE_ID__", rt), encoding="utf-8")
        print("Patched", p)
PY
