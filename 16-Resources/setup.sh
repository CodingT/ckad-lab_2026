#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 16 (Resource Requests and Limits)...${NC}"

# Clean existing resources
kubectl delete pod resource-pod -n prod --ignore-not-found 2>/dev/null || true
kubectl delete namespace prod --ignore-not-found 2>/dev/null || true
sleep 2

# Create namespace
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f - >/dev/null

# Create ResourceQuota in prod namespace
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ResourceQuota
metadata:
  name: prod-quota
  namespace: prod
spec:
  hard:
    limits.cpu: "2"
    limits.memory: "4Gi"
    requests.cpu: "1"
    requests.memory: "2Gi"
EOF

echo -e "${GREEN}[OK] Environment ready. Namespace 'prod' with ResourceQuota created.${NC}"

echo
cat "$DIR/task.md"
echo
echo -e "${GREEN}======================================${NC}"
echo
