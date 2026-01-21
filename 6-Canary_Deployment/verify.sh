#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0
NS=default

echo "Verifying Question 6: Canary Deployment split (8 v1 / 2 v2) ..."

# --- Check base deployment (web-app v1) ---
if kubectl get deployment web-app -n "$NS" >/dev/null 2>&1; then
  DESIRED=$(kubectl get deployment web-app -n "$NS" -o jsonpath='{.spec.replicas}')
  READY=$(kubectl get deployment web-app -n "$NS" -o jsonpath='{.status.readyReplicas}')
  if [ "$DESIRED" = "8" ] && [ "$READY" = "8" ]; then
    echo -e "${GREEN}[OK] Deployment web-app scaled to 8 replicas and ready.${NC}"
  else
    echo -e "${RED}[FAIL] Deployment web-app replicas/ready = ${DESIRED}/${READY} (expected 8/8).${NC}"
    ERRORS=$((ERRORS+1))
  fi
else
  echo -e "${RED}[FAIL] Deployment 'web-app' not found in namespace ${NS}.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check canary deployment (web-app-canary v2) ---
if kubectl get deployment web-app-canary -n "$NS" >/dev/null 2>&1; then
  DESIRED_C=$(kubectl get deployment web-app-canary -n "$NS" -o jsonpath='{.spec.replicas}')
  READY_C=$(kubectl get deployment web-app-canary -n "$NS" -o jsonpath='{.status.readyReplicas}')
  LABEL_APP=$(kubectl get deployment web-app-canary -n "$NS" -o jsonpath='{.spec.template.metadata.labels.app}')
  LABEL_VER=$(kubectl get deployment web-app-canary -n "$NS" -o jsonpath='{.spec.template.metadata.labels.version}')
  if [ "$DESIRED_C" = "2" ] && [ "$READY_C" = "2" ]; then
    echo -e "${GREEN}[OK] Deployment web-app-canary scaled to 2 replicas and ready.${NC}"
  else
    echo -e "${RED}[FAIL] Deployment web-app-canary replicas/ready = ${DESIRED_C}/${READY_C} (expected 2/2).${NC}"
    ERRORS=$((ERRORS+1))
  fi
  if [ "$LABEL_APP" = "webapp" ] && [ "$LABEL_VER" = "v2" ]; then
    echo -e "${GREEN}[OK] web-app-canary labels include app=webapp and version=v2.${NC}"
  else
    echo -e "${RED}[FAIL] web-app-canary labels are missing app=webapp and/or version=v2 (found app=${LABEL_APP}, version=${LABEL_VER}).${NC}"
    ERRORS=$((ERRORS+1))
  fi
else
  echo -e "${RED}[FAIL] Deployment 'web-app-canary' not found in namespace ${NS}.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check service selector targets both versions ---
if kubectl get service web-service -n "$NS" >/dev/null 2>&1; then
  if kubectl get service web-service -n "$NS" -o jsonpath='{.spec.selector.app}' | grep -qx "webapp"; then
    echo -e "${GREEN}[OK] Service web-service selector app=webapp is set.${NC}"
  else
    echo -e "${RED}[FAIL] Service web-service selector is not app=webapp.${NC}"
    ERRORS=$((ERRORS+1))
  fi
else
  echo -e "${RED}[FAIL] Service 'web-service' not found in namespace ${NS}.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check pod readiness and split by version ---
READY_V1=$(kubectl get pods -n "$NS" -l app=webapp,version=v1 --field-selector=status.phase=Running -o json 2>/dev/null | grep -o '"ready":true' | wc -l)
READY_V2=$(kubectl get pods -n "$NS" -l app=webapp,version=v2 --field-selector=status.phase=Running -o json 2>/dev/null | grep -o '"ready":true' | wc -l)
if [ "$READY_V1" -eq 8 ] && [ "$READY_V2" -eq 2 ]; then
  echo -e "${GREEN}[OK] Ready pod split is 8 (v1) / 2 (v2).${NC}"
else
  echo -e "${RED}[FAIL] Ready pod split is ${READY_V1} (v1) / ${READY_V2} (v2); expected 8 / 2.${NC}"
  ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 6 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 6 Failed with $ERRORS error(s).${NC}"
fi
