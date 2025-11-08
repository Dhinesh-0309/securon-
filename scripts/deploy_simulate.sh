#!/usr/bin/env bash
# scripts/deploy_simulate.sh
# Usage: ./scripts/deploy_simulate.sh <output-file>
set -e

OUT=${1:-deployment_status.txt}

echo "Simulating Terraform apply..."
sleep 2

# Write a human-friendly deploy status (this is the artifact reviewers will see)
cat > "$OUT" <<EOF
Securon Deployment Simulation
-----------------------------
Status: DEPLOYED (SIMULATED)
Deployed at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Deployed by: GitHub Actions
Notes: This is a simulated deployment artifact (no real AWS calls were made).
EOF

echo "Deployment simulation complete. Artifact: $OUT"
