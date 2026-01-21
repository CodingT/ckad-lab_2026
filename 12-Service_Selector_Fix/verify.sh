#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0
NS=default
SVC=web-svc

echo "Verifying Question 12: Service Selector Fix..."

# --- Check service exists ---
if ! kubectl get service "$SVC" -n "$NS" >/dev/null 2>&1; then
  echo -e "${RED}[FAIL] Service $SVC not found in namespace $NS.${NC}"
  ERRORS=$((ERRORS+1))
  exit 1
fi

# --- Check service selector is correct ---
SELECTOR=$(kubectl get service "$SVC" -n "$NS" -o jsonpath='{.spec.selector.app}' 2>/dev/null || true)
if [ "$SELECTOR" = "webapp" ]; then
  echo -e "${GREEN}[OK] Service selector is correct.${NC}"
else
  echo -e "${RED}[FAIL] Service selector is incorrect.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check endpoints are populated ---
ENDPOINTS=$(kubectl get endpoints "$SVC" -n "$NS" -o jsonpath='{.subsets[0].addresses[*].targetRef.name}' 2>/dev/null || true)
if [ -n "$ENDPOINTS" ]; then
  POD_COUNT=$(echo "$ENDPOINTS" | wc -w)
  echo -e "${GREEN}[OK] Service has $POD_COUNT endpoints.${NC}"
else
  echo -e "${RED}[FAIL] Service has no endpoints.${NC}"
  ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 12 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 12 Failed with $ERRORS error(s).${NC}"
fi
