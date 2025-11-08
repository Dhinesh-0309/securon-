#!/usr/bin/env python3
"""
Securon IaC Static Scanner
-----------------------------------
Scans Terraform plan.json for misconfigurations based on rules.json
Generates scan_report.json and exit code:
  0 = Safe
  1 = Blocking findings
Usage:
  python3 scanner.py --plan plan.json --rules rules.json --report scan_report.json
"""

import json
import argparse
import sys

def load_json(path):
    try:
        with open(path) as f:
            return json.load(f)
    except Exception as e:
        print(f"❌ Error reading {path}: {e}")
        sys.exit(1)

# ---------------- Operator Functions ---------------- #

def check_sg_ingress_open_to_any_port(resource, rule):
    """
    Checks if any SG ingress rule opens specified port to 0.0.0.0/0
    """
    after = resource.get("change", {}).get("after", {})
    ingress = after.get("ingress", [])
    for entry in ingress or []:
        cidrs = entry.get("cidr_blocks", [])
        if "0.0.0.0/0" in cidrs:
            from_p = entry.get("from_port")
            to_p = entry.get("to_port")
            if rule.get("port") in range(from_p, to_p + 1):
                return True
    return False


def check_field_equals(resource, rule):
    """
    Generic field equals check (supports nested fields)
    """
    after = resource.get("change", {}).get("after", {})
    field_path = rule.get("field")
    expected_value = rule.get("value")

    # Navigate nested fields (like "values.acl")
    keys = field_path.split(".")
    val = after
    for k in keys:
        if isinstance(val, dict) and k in val:
            val = val[k]
        else:
            return False
    return val == expected_value


def check_field_missing_or_false(resource, rule):
    """
    Detects if a boolean field is missing or false
    Example: encryption or public access block disabled
    """
    after = resource.get("change", {}).get("after", {})
    field_path = rule.get("field")
    keys = field_path.split(".")
    val = after
    for k in keys:
        if isinstance(val, dict) and k in val:
            val = val[k]
        else:
            return True  # missing field = misconfig
    return val is False


# ---------------- Rule Evaluation Engine ---------------- #

def evaluate_rule(resource, rule):
    op = rule.get("operator")
    if op == "sg_ingress_open_to_any_port":
        return check_sg_ingress_open_to_any_port(resource, rule)
    elif op == "equals":
        return check_field_equals(resource, rule)
    elif op == "missing_or_false":
        return check_field_missing_or_false(resource, rule)
    else:
        print(f"⚠️ Unsupported operator: {op}")
        return False


# ---------------- Scanner Logic ---------------- #

def run_scan(plan_path, rules_path, report_path):
    plan = load_json(plan_path)
    rules = load_json(rules_path)["rules"]
    resources = plan.get("resource_changes", [])

    findings = []

    for res in resources:
        r_type = res.get("type")
        address = res.get("address")
        for rule in rules:
            if rule["resource"] == r_type:
                if evaluate_rule(res, rule):
                    findings.append({
                        "resource": address,
                        "rule_id": rule["id"],
                        "message": rule["message"],
                        "severity": rule["severity"]
                    })

    report = {
        "summary": {
            "total_resources": len(resources),
            "total_findings": len(findings),
            "blocking_findings": len([f for f in findings if f["severity"] == "block"])
        },
        "findings": findings
    }

    with open(report_path, "w") as f:
        json.dump(report, f, indent=2)

    # Display summary
    print(f"\n🔍 Scanned {len(resources)} resources")
    print(f"⚠️  Findings: {len(findings)} (Blocking: {report['summary']['blocking_findings']})")

    if any(f["severity"] == "block" for f in findings):
        print("❌ Blocking misconfigurations found. Check scan_report.json")
        sys.exit(1)
    else:
        print("✅ No blocking misconfigurations found.")
        sys.exit(0)


# ---------------- CLI ---------------- #
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Securon Terraform IaC Static Scanner")
    parser.add_argument("--plan", required=True, help="Path to plan.json")
    parser.add_argument("--rules", required=True, help="Path to rules.json")
    parser.add_argument("--report", required=True, help="Output report path")
    args = parser.parse_args()

    run_scan(args.plan, args.rules, args.report)
