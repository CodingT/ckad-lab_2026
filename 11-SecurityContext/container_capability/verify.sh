#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0
NS=default
DEP=secure-app

echo "Verifying Question 11: Security Context on secure-app..."

# --- Check deployment exists ---
if ! kubectl get deployment "$DEP" -n "$NS" >/dev/null 2>&1; then
  echo -e "${RED}[FAIL] Deployment $DEP not found in namespace $NS.${NC}"
  ERRORS=$((ERRORS+1))
  exit 1
fi

# --- Check Pod-level runAsUser ---
RUN_AS_USER=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.template.spec.securityContext.runAsUser}' 2>/dev/null || true)
if [ "$RUN_AS_USER" = "1000" ]; then
  echo -e "${GREEN}[OK] Pod-level runAsUser is 1000.${NC}"
else
  echo -e "${RED}[FAIL] Pod-level runAsUser is '$RUN_AS_USER' (expected 1000).${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check container-level NET_ADMIN capability ---
CAPABILITIES=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.template.spec.containers[?(@.name=="app")].securityContext.capabilities.add}' 2>/dev/null || true)
if echo "$CAPABILITIES" | grep -q "NET_ADMIN"; then
  echo -e "${GREEN}[OK] Container 'app' has NET_ADMIN capability.${NC}"
else
  echo -e "${RED}[FAIL] Container 'app' does not have NET_ADMIN capability. Found: '$CAPABILITIES'${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Verify security context in running pod ---
POD_NAME=$(kubectl get pods -n "$NS" -l app="$DEP" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
if [ -n "$POD_NAME" ]; then
  # Check pod-level runAsUser in actual pod
  POD_RUN_AS_USER=$(kubectl get pod "$POD_NAME" -n "$NS" -o jsonpath='{.spec.securityContext.runAsUser}' 2>/dev/null || true)
  if [ "$POD_RUN_AS_USER" = "1000" ]; then
    echo -e "${GREEN}[OK] Pod '$POD_NAME' is running with runAsUser 1000.${NC}"
  else
    echo -e "${RED}[FAIL] Pod '$POD_NAME' runAsUser is '$POD_RUN_AS_USER' (expected 1000).${NC}"
    ERRORS=$((ERRORS+1))
  fi

  # Check container-level capability in actual pod
  POD_CAPABILITIES=$(kubectl get pod "$POD_NAME" -n "$NS" -o jsonpath='{.spec.containers[?(@.name=="app")].securityContext.capabilities.add}' 2>/dev/null || true)
  if echo "$POD_CAPABILITIES" | grep -q "NET_ADMIN"; then
    echo -e "${GREEN}[OK] Pod '$POD_NAME' container 'app' has NET_ADMIN capability.${NC}"
  else
    echo -e "${RED}[FAIL] Pod '$POD_NAME' container 'app' does not have NET_ADMIN capability.${NC}"
    ERRORS=$((ERRORS+1))
  fi
else
  echo -e "${RED}[FAIL] No running pod found for deployment $DEP.${NC}"
  ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 11 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 11 Failed with $ERRORS error(s).${NC}"
fi
