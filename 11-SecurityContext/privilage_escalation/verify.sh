#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0
NS=quetzal
DEP=hotfix-deploy

echo "Verifying Question 11-Privilege Escalation: Security Context on hotfix-deploy..."

# --- Check deployment exists ---
if ! kubectl get deployment "$DEP" -n "$NS" >/dev/null 2>&1; then
  echo -e "${RED}[FAIL] Deployment $DEP not found in namespace $NS.${NC}"
  ERRORS=$((ERRORS+1))
  exit 1
fi

# --- Check Pod-level runAsUser is 30000 ---
RUN_AS_USER=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.template.spec.securityContext.runAsUser}' 2>/dev/null || true)
if [ "$RUN_AS_USER" = "30000" ]; then
  echo -e "${GREEN}[OK] Pod-level runAsUser is 30000.${NC}"
else
  echo -e "${RED}[FAIL] Pod-level runAsUser is '$RUN_AS_USER' (expected 30000).${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check container-level allowPrivilegeEscalation is false ---
ALLOW_PRIV_ESCALATION=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.template.spec.containers[?(@.name=="hotfix-container")].securityContext.allowPrivilegeEscalation}' 2>/dev/null || true)
if [ "$ALLOW_PRIV_ESCALATION" = "false" ]; then
  echo -e "${GREEN}[OK] Container 'hotfix-container' has allowPrivilegeEscalation: false.${NC}"
else
  echo -e "${RED}[FAIL] Container 'hotfix-container' allowPrivilegeEscalation is '$ALLOW_PRIV_ESCALATION' (expected false).${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Verify security context in running pod ---
POD_NAME=$(kubectl get pods -n "$NS" -l app=hotfix -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
if [ -n "$POD_NAME" ]; then
  # Check pod-level runAsUser in actual pod
  POD_RUN_AS_USER=$(kubectl get pod "$POD_NAME" -n "$NS" -o jsonpath='{.spec.securityContext.runAsUser}' 2>/dev/null || true)
  if [ "$POD_RUN_AS_USER" = "30000" ]; then
    echo -e "${GREEN}[OK] Pod '$POD_NAME' is running with runAsUser 30000.${NC}"
  else
    echo -e "${RED}[FAIL] Pod '$POD_NAME' runAsUser is '$POD_RUN_AS_USER' (expected 30000).${NC}"
    ERRORS=$((ERRORS+1))
  fi

  # Check container-level allowPrivilegeEscalation in actual pod
  POD_ALLOW_PRIV_ESCALATION=$(kubectl get pod "$POD_NAME" -n "$NS" -o jsonpath='{.spec.containers[?(@.name=="hotfix-container")].securityContext.allowPrivilegeEscalation}' 2>/dev/null || true)
  if [ "$POD_ALLOW_PRIV_ESCALATION" = "false" ]; then
    echo -e "${GREEN}[OK] Pod '$POD_NAME' container 'hotfix-container' has allowPrivilegeEscalation: false.${NC}"
  else
    echo -e "${RED}[FAIL] Pod '$POD_NAME' container 'hotfix-container' allowPrivilegeEscalation is '$POD_ALLOW_PRIV_ESCALATION' (expected false).${NC}"
    ERRORS=$((ERRORS+1))
  fi
else
  echo -e "${RED}[FAIL] No running pod found for deployment $DEP.${NC}"
  ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 11-Privilege Escalation Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 11-Privilege Escalation Failed with $ERRORS error(s).${NC}"
fi
