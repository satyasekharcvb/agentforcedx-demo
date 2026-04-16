#!/usr/bin/env bash
# Deploy force-app to a scratch org. Temporarily strips <agentAccesses> from
# Merchant_Management_Agent_Access because the Merchant_Management_Agent bot is
# not deployed when aiAuthoringBundles/ is excluded by .forceignore (and the bot
# requires additional Apex in org). Restores the file after deploy.
set -euo pipefail
TARGET_ORG="${1:?Usage: $0 <target-org-alias-or-username>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PS_FILE="$ROOT/force-app/main/default/permissionsets/Merchant_Management_Agent_Access.permissionset-meta.xml"
# Use mktemp — a *.bak beside the metadata file can be picked up by deploy and break the deploy.
BAK="$(mktemp)"

cleanup() {
  if [[ -f "$BAK" ]]; then
    mv "$BAK" "$PS_FILE"
    echo "Restored $PS_FILE"
  fi
}
trap cleanup EXIT

cp "$PS_FILE" "$BAK"
perl -i -0pe 's/\s*<agentAccesses>[\s\S]*?<\/agentAccesses>//g' "$PS_FILE"

sf project deploy start --source-dir "$ROOT/force-app" --target-org "$TARGET_ORG" --wait 30 --ignore-conflicts
