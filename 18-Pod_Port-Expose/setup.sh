#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 18 (Pod Port Expose)...${NC}"

# Clean existing resources
kubectl delete pod cache -n web --ignore-not-found 2>/dev/null || true
kubectl delete namespace web --ignore-not-found 2>/dev/null || true
sleep 2

# Create namespace
kubectl create namespace web --dry-run=client -o yaml | kubectl apply -f - >/dev/null

echo -e "${GREEN}[OK] Environment ready.${NC}"

echo
cat "$DIR/task.md"
