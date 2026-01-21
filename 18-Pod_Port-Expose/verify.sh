#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0
NS=web
POD=cache

echo "Verifying Question 18: Pod Port Expose..."

# --- Check pod exists ---
if ! kubectl get pod "$POD" -n "$NS" >/dev/null 2>&1; then
  echo -e "${RED}[FAIL] Pod $POD not found in namespace $NS.${NC}"
  ERRORS=$((ERRORS+1))
  exit 1
fi

# --- Check pod is running ---
POD_STATUS=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.status.phase}' 2>/dev/null || true)
if [ "$POD_STATUS" = "Running" ]; then
  echo -e "${GREEN}[OK] Pod is running.${NC}"
else
  echo -e "${RED}[FAIL] Pod is not running (status: $POD_STATUS).${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check image ---
IMAGE=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].image}' 2>/dev/null || true)
if [ "$IMAGE" = "redis:3.2" ]; then
  echo -e "${GREEN}[OK] Pod image is correct.${NC}"
else
  echo -e "${RED}[FAIL] Pod image is incorrect.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check port is exposed ---
PORT=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].ports[0].containerPort}' 2>/dev/null || true)
if [ "$PORT" = "6379" ]; then
  echo -e "${GREEN}[OK] Port 6379 is exposed.${NC}"
else
  echo -e "${RED}[FAIL] Port is not correctly exposed.${NC}"
  ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 18 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 18 Failed with $ERRORS error(s).${NC}"
fi
