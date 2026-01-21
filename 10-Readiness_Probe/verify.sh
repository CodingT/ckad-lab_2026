#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0
NS=default
DEP=api-deploy

echo "Verifying Question 10: Readiness probe on api-deploy..."

# --- Check deployment exists ---
if ! kubectl get deployment "$DEP" -n "$NS" >/dev/null 2>&1; then
  echo -e "${RED}[FAIL] Deployment $DEP not found in namespace $NS.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check readiness probe ---
RP=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}' 2>/dev/null || true)
if [ -z "$RP" ]; then
  echo -e "${RED}[FAIL] No readinessProbe found on container 'api'.${NC}"
  ERRORS=$((ERRORS+1))
else
  PATH_VAL=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null || true)
  PORT_VAL=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null || true)
  INIT_DELAY=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.initialDelaySeconds}' 2>/dev/null || true)
  PERIOD=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.periodSeconds}' 2>/dev/null || true)

  if [ "$PATH_VAL" = "/ready" ]; then
    echo -e "${GREEN}[OK] readinessProbe path is /ready.${NC}"
  else
    echo -e "${RED}[FAIL] readinessProbe path is '$PATH_VAL' (expected /ready).${NC}"
    ERRORS=$((ERRORS+1))
  fi

  if [ "$PORT_VAL" = "8080" ]; then
    echo -e "${GREEN}[OK] readinessProbe port is 8080.${NC}"
  else
    echo -e "${RED}[FAIL] readinessProbe port is '$PORT_VAL' (expected 8080).${NC}"
    ERRORS=$((ERRORS+1))
  fi

  if [ "$INIT_DELAY" = "5" ]; then
    echo -e "${GREEN}[OK] initialDelaySeconds is 5.${NC}"
  else
    echo -e "${RED}[FAIL] initialDelaySeconds is '$INIT_DELAY' (expected 5).${NC}"
    ERRORS=$((ERRORS+1))
  fi

  if [ "$PERIOD" = "10" ]; then
    echo -e "${GREEN}[OK] periodSeconds is 10.${NC}"
  else
    echo -e "${RED}[FAIL] periodSeconds is '$PERIOD' (expected 10).${NC}"
    ERRORS=$((ERRORS+1))
  fi
fi

# --- Check rollout status ---
if kubectl rollout status deployment/"$DEP" -n "$NS" --timeout=60s >/dev/null 2>&1; then
  echo -e "${GREEN}[OK] Deployment rollout completed successfully.${NC}"
else
  echo -e "${RED}[FAIL] Deployment rollout did not complete successfully.${NC}"
  ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 10 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 10 Failed with $ERRORS error(s).${NC}"
fi
