#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0
NS=production

echo "Verifying Question 19: Traffic Distribution..."

# --- Check v1 deployment exists ---
if ! kubectl get deployment webapp-v1 -n "$NS" >/dev/null 2>&1; then
  echo -e "${RED}[FAIL] Deployment webapp-v1 not found.${NC}"
  ERRORS=$((ERRORS+1))
else
  REPLICAS_V1=$(kubectl get deployment webapp-v1 -n "$NS" -o jsonpath='{.spec.replicas}' 2>/dev/null || true)
  READY_V1=$(kubectl get deployment webapp-v1 -n "$NS" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)
  if [ "$REPLICAS_V1" = "8" ] && [ "$READY_V1" = "8" ]; then
    echo -e "${GREEN}[OK] Deployment webapp-v1 has 8 replicas ready.${NC}"
  else
    echo -e "${RED}[FAIL] Deployment webapp-v1 replica count is incorrect.${NC}"
    ERRORS=$((ERRORS+1))
  fi
fi

# --- Check v2 deployment exists ---
if ! kubectl get deployment webapp-v2 -n "$NS" >/dev/null 2>&1; then
  echo -e "${RED}[FAIL] Deployment webapp-v2 not found.${NC}"
  ERRORS=$((ERRORS+1))
else
  REPLICAS_V2=$(kubectl get deployment webapp-v2 -n "$NS" -o jsonpath='{.spec.replicas}' 2>/dev/null || true)
  READY_V2=$(kubectl get deployment webapp-v2 -n "$NS" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)
  if [ "$REPLICAS_V2" = "2" ] && [ "$READY_V2" = "2" ]; then
    echo -e "${GREEN}[OK] Deployment webapp-v2 has 2 replicas ready.${NC}"
  else
    echo -e "${RED}[FAIL] Deployment webapp-v2 replica count is incorrect.${NC}"
    ERRORS=$((ERRORS+1))
  fi
fi

# --- Check service exists ---
if ! kubectl get service webapp-svc -n "$NS" >/dev/null 2>&1; then
  echo -e "${RED}[FAIL] Service webapp-svc not found.${NC}"
  ERRORS=$((ERRORS+1))
else
  echo -e "${GREEN}[OK] Service webapp-svc exists.${NC}"
  
  # --- Check service selector ---
  SELECTOR=$(kubectl get service webapp-svc -n "$NS" -o jsonpath='{.spec.selector.app}' 2>/dev/null || true)
  if [ "$SELECTOR" = "webapp" ]; then
    echo -e "${GREEN}[OK] Service selector is correct.${NC}"
  else
    echo -e "${RED}[FAIL] Service selector is incorrect.${NC}"
    ERRORS=$((ERRORS+1))
  fi
  
  # --- Check endpoints ---
  ENDPOINTS=$(kubectl get endpoints webapp-svc -n "$NS" -o jsonpath='{.subsets[0].addresses[*].targetRef.name}' 2>/dev/null || true)
  ENDPOINT_COUNT=$(echo "$ENDPOINTS" | wc -w)
  if [ "$ENDPOINT_COUNT" = "10" ]; then
    echo -e "${GREEN}[OK] Service has 10 endpoints (8 v1 + 2 v2).${NC}"
  else
    echo -e "${RED}[FAIL] Service endpoint count is incorrect (expected 10, got $ENDPOINT_COUNT).${NC}"
    ERRORS=$((ERRORS+1))
  fi
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 19 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 19 Failed with $ERRORS error(s).${NC}"
fi
