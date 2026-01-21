#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0
NS=default
DEP=broken-app
FILE=/root/broken-deploy.yaml

echo "Verifying Question 8: Fixed Deployment manifest..."

FILE_MISSING=0
if [ ! -f "$FILE" ]; then
  echo -e "${RED}[FAIL] File $FILE not found. Save your fixed manifest there.${NC}"
  ERRORS=$((ERRORS+1))
  FILE_MISSING=1
fi

# --- Check apiVersion ---
if [ $FILE_MISSING -eq 0 ]; then
  if grep -q '^apiVersion: apps/v1' "$FILE"; then
    echo -e "${GREEN}[OK] apiVersion is apps/v1.${NC}"
  else
    echo -e "${RED}[FAIL] apiVersion is not apps/v1.${NC}"
    ERRORS=$((ERRORS+1))
  fi
fi

# --- Check selector matches template labels ---
if [ $FILE_MISSING -eq 0 ]; then
  SELECTOR_APP=$(yq '.spec.selector.matchLabels.app' "$FILE" 2>/dev/null || true)
  TEMPLATE_APP=$(yq '.spec.template.metadata.labels.app' "$FILE" 2>/dev/null || true)
  if [ -n "$SELECTOR_APP" ] && [ "$SELECTOR_APP" = "$TEMPLATE_APP" ]; then
    echo -e "${GREEN}[OK] selector.matchLabels.app matches template label (app=${SELECTOR_APP}).${NC}"
  else
    echo -e "${RED}[FAIL] selector.matchLabels.app (${SELECTOR_APP:-none}) does not match template label (${TEMPLATE_APP:-none}).${NC}"
    ERRORS=$((ERRORS+1))
  fi
fi

# --- Check Deployment exists and is ready ---
if kubectl get deployment "$DEP" -n "$NS" >/dev/null 2>&1; then
  DEP_API=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.apiVersion}')
  if [ "$DEP_API" = "apps/v1" ]; then
    echo -e "${GREEN}[OK] Deployment $DEP API version is apps/v1.${NC}"
  else
    echo -e "${RED}[FAIL] Deployment $DEP API version is ${DEP_API} (expected apps/v1).${NC}"
    ERRORS=$((ERRORS+1))
  fi
  READY=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.status.readyReplicas}')
  DESIRED=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.replicas}')
  if [ "${READY:-0}" = "${DESIRED:-0}" ] && [ -n "${READY:-}" ]; then
    echo -e "${GREEN}[OK] Deployment $DEP is ready (${READY}/${DESIRED}).${NC}"
  else
    echo -e "${RED}[FAIL] Deployment $DEP not fully ready (${READY:-0}/${DESIRED:-0}).${NC}"
    ERRORS=$((ERRORS+1))
  fi
else
  echo -e "${RED}[FAIL] Deployment $DEP not found in namespace $NS.${NC}"
  ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 8 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 8 Failed with $ERRORS error(s).${NC}"
fi
