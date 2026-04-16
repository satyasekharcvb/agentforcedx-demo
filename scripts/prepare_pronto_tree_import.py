#!/usr/bin/env python3
"""Normalize `sf data export tree` JSON for cross-org import into a target org."""
from __future__ import annotations

import json
import sys
from pathlib import Path


def _clean_record(rec: dict) -> dict:
    t = rec.get("attributes", {}).get("type")
    out: dict = {"attributes": dict(rec["attributes"])}

    for k, v in rec.items():
        if k == "attributes" or v is None:
            continue

        if t == "Storefront__c":
            if k not in ("Name", "Account__c"):
                continue

        out[k] = v

    return out


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "data/pronto-export")
    mapping = [
        ("pronto-Account.json", "pronto-Account-import.json", "Account"),
        ("pronto-Contact.json", "pronto-Contact-import.json", "Contact"),
        ("pronto-Storefront__c.json", "pronto-Storefront__c-import.json", "Storefront__c"),
    ]
    plan: list[dict] = []

    overrides_path = root / "import-overrides.json"
    overrides: dict = {}
    if overrides_path.exists():
        overrides = json.loads(overrides_path.read_text())

    for src_name, dst_name, sobj in mapping:
        src = root / src_name
        if not src.exists():
            print(f"Skip missing {src}", file=sys.stderr)
            continue
        data = json.loads(src.read_text())
        extra = overrides.get(sobj, {})
        records = []
        for r in data.get("records", []):
            rec = _clean_record(r)
            for field, val in extra.items():
                rec[field] = val
            records.append(rec)
        data["records"] = records
        dst = root / dst_name
        dst.write_text(json.dumps(data, indent=4) + "\n")
        print(f"Wrote {dst}")
        plan.append({"sobject": sobj, "files": [dst_name]})

    plan_path = root / "pronto-import-plan.json"
    plan_path.write_text(json.dumps(plan, indent=4) + "\n")
    print(f"Wrote {plan_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
