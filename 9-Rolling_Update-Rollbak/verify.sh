#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0
NS=default
DEP=app-v1

echo "Verifying Question 9: Rolling update to 1.25 completed and rolled back to previous..."

# --- Check deployment exists ---
if ! kubectl get deployment "$DEP" -n "$NS" >/dev/null 2>&1; then
  echo -e "${RED}[FAIL] Deployment $DEP not found in namespace $NS.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Get current image ---
CUR_IMG=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)

# --- Check rollout history has update + rollback (>=2 revisions) ---
REV_COUNT=$(kubectl rollout history deployment "$DEP" -n "$NS" 2>/dev/null | grep -c '^\s*[0-9]')
if [ "$REV_COUNT" -ge 2 ]; then
  echo -e "${GREEN}[OK] Rollout history shows at least 2 revisions (update + rollback).${NC}"
else
  echo -e "${RED}[FAIL] Rollout history has fewer than 2 revisions. Perform update then rollback.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check readiness ---
READY=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo 0)
DESIRED=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo 0)
if [ "$READY" = "$DESIRED" ] && [ -n "$READY" ]; then
  echo -e "${GREEN}[OK] Deployment ready (${READY}/${DESIRED}).${NC}"
else
  echo -e "${RED}[FAIL] Deployment not fully ready (${READY}/${DESIRED}).${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check that rollback happened (current image should be nginx:1.20) ---
if [ "$CUR_IMG" = "nginx:1.20" ]; then
  echo -e "${GREEN}[OK] Deployment is currently at nginx:1.20 (rollback state).${NC}"
else
  echo -e "${RED}[FAIL] Deployment image is $CUR_IMG (expected nginx:1.20 after rollback).${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Ensure previous update to nginx:1.25 occurred (look at ReplicaSets) ---
RS_IMAGES=$(kubectl get rs -n "$NS" -l app=app-v1 -o jsonpath='{range .items[*]}{.metadata.name}:{.spec.template.spec.containers[0].image}{"\n"}{end}' 2>/dev/null || true)
if echo "$RS_IMAGES" | grep -q 'nginx:1.25'; then
  echo -e "${GREEN}[OK] Found a ReplicaSet with image nginx:1.25 (update step observed).${NC}"
else
  echo -e "${RED}[FAIL] No ReplicaSet found with image nginx:1.25 (update step not detected).${NC}"
  ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 9 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 9 Failed with $ERRORS error(s).${NC}"
fi
