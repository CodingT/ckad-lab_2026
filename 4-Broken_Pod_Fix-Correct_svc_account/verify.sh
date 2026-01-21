#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Verifying Question 4: metrics-pod ServiceAccount and auth errors..."

ERRORS=0

# --- Check Pod exists ---
if ! kubectl get pod metrics-pod -n monitoring >/dev/null 2>&1; then
  echo -e "${RED}[FAIL] Pod 'metrics-pod' not found in namespace monitoring.${NC}"
  echo -e "${YELLOW}[INFO] Ensure setup.sh has been run.${NC}"
  exit 1
fi

# --- Report ServiceAccount in use (informational) ---
POD_SA=$(kubectl get pod metrics-pod -n monitoring -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
if [ -n "$POD_SA" ]; then
  if [ "$POD_SA" = "monitor-sa" ]; then
    echo -e "${GREEN}[OK] Pod uses correct ServiceAccount 'monitor-sa'.${NC}"
  else
    echo -e "${RED}[FAIL] Pod uses ServiceAccount '$POD_SA'"
    ERRORS=$((ERRORS+1))
  fi
else
  echo -e "${RED}[FAIL] Pod has no serviceAccountName"
  ERRORS=$((ERRORS+1))
fi

# --- Check recent logs for authorization errors (primary pass/fail) ---
echo -e "${YELLOW}[INFO] Checking pod logs for authorization errors...${NC}"
POD_LOGS=$(kubectl logs metrics-pod -n monitoring --tail=40 2>&1)
if echo "$POD_LOGS" | grep -qiE "forbidden|unauthorized|cannot list|permission denied"; then
  echo -e "${RED}[FAIL] Authorization errors detected in pod logs.${NC}"
  ERRORS=$((ERRORS+1))
else
  echo -e "${GREEN}[OK] No authorization errors detected in recent pod logs.${NC}"
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Verification passed: metrics-pod shows no auth errors.${NC}"
else
  echo -e "${RED}❌ Verification failed with $ERRORS error(s).${NC}"
fi
