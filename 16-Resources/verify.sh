#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0
NS=prod
POD=resource-pod

echo "Verifying Question 16: Resource Requests and Limits..."

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

# --- Check CPU and memory requests are set ---
CPU_REQUEST=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null || true)
MEMORY_REQUEST=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null || true)
if [ -n "$CPU_REQUEST" ] && [ -n "$MEMORY_REQUEST" ]; then
  echo -e "${GREEN}[OK] CPU and memory requests are set (CPU: $CPU_REQUEST, Memory: $MEMORY_REQUEST).${NC}"
else
  echo -e "${RED}[FAIL] CPU or memory requests are not set.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check CPU and memory limits are set ---
CPU_LIMIT=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null || true)
MEMORY_LIMIT=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null || true)
if [ -n "$CPU_LIMIT" ] && [ -n "$MEMORY_LIMIT" ]; then
  echo -e "${GREEN}[OK] CPU and memory limits are set (CPU: $CPU_LIMIT, Memory: $MEMORY_LIMIT).${NC}"
else
  echo -e "${RED}[FAIL] CPU or memory limits are not set.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check limits are reasonable (typically half of quota limits) ---
# Quota: CPU: 2, Memory: 4Gi
# Expected limits: CPU <= 1, Memory <= 2Gi
CPU_LIMIT_VAL=${CPU_LIMIT%m}  # Remove 'm' suffix if present
MEMORY_LIMIT_VAL=${MEMORY_LIMIT%Gi}  # Remove 'Gi' suffix if present

# Convert to comparable format
if [[ "$CPU_LIMIT" == *"m" ]]; then
  CPU_LIMIT_VAL=$((${CPU_LIMIT%m}))
else
  CPU_LIMIT_VAL=$((${CPU_LIMIT:-0} * 1000))
fi

if [[ "$MEMORY_LIMIT" == *"Gi" ]]; then
  MEMORY_LIMIT_VAL=$((${MEMORY_LIMIT%Gi}))
else
  MEMORY_LIMIT_VAL=$((${MEMORY_LIMIT%Mi} / 1024))
fi

if [ "$CPU_LIMIT_VAL" -le 1000 ] && [ "$MEMORY_LIMIT_VAL" -le 2 ]; then
  echo -e "${GREEN}[OK] Limits are reasonable (within half of quota).${NC}"
else
  echo -e "${RED}[FAIL] Limits appear to exceed half of quota limits.${NC}"
  ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 16 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 16 Failed with $ERRORS error(s).${NC}"
fi
