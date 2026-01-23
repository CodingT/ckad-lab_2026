#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 19 (Traffic Distribute)...${NC}"

# Clean existing resources
kubectl delete deployment webapp-v1 -n production --ignore-not-found 2>/dev/null || true
kubectl delete deployment webapp-v2 -n production --ignore-not-found 2>/dev/null || true
kubectl delete service webapp-svc -n production --ignore-not-found 2>/dev/null || true
kubectl delete namespace production --ignore-not-found 2>/dev/null || true
sleep 2

# Create namespace
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f - >/dev/null

echo -e "${GREEN}[OK] Environment ready.${NC}"

echo
cat "$DIR/task.md"
echo
echo -e "${GREEN}======================================${NC}"
echo
