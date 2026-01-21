#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0
NS=default
DEP=nginx

echo "Verifying Question 10-1: Readiness probe on nginx..."

# --- Check deployment exists ---
if ! kubectl get deployment "$DEP" -n "$NS" >/dev/null 2>&1; then
  echo -e "${RED}[FAIL] Deployment $DEP not found in namespace $NS.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check readiness probe ---
RP=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}' 2>/dev/null || true)
if [ -z "$RP" ]; then
  echo -e "${RED}[FAIL] No readinessProbe found on container 'nginx'.${NC}"
  ERRORS=$((ERRORS+1))
else
  PATH_VAL=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null || true)
  PORT_VAL=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null || true)
  INIT_DELAY=$(kubectl get deployment "$DEP" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.initialDelaySeconds}' 2>/dev/null || true)

  if [ "$PATH_VAL" = "/ready" ]; then
    echo -e "${GREEN}[OK] readinessProbe path is /ready.${NC}"
  else
    echo -e "${RED}[FAIL] readinessProbe path is '$PATH_VAL' (expected /ready).${NC}"
    ERRORS=$((ERRORS+1))
  fi

  if [ "$PORT_VAL" = "80" ]; then
    echo -e "${GREEN}[OK] readinessProbe port is 80.${NC}"
  else
    echo -e "${RED}[FAIL] readinessProbe port is '$PORT_VAL' (expected 80).${NC}"
    ERRORS=$((ERRORS+1))
  fi

  if [ "$INIT_DELAY" = "5" ]; then
    echo -e "${GREEN}[OK] initialDelaySeconds is 5.${NC}"
  else
    echo -e "${RED}[FAIL] initialDelaySeconds is '$INIT_DELAY' (expected 5).${NC}"
    ERRORS=$((ERRORS+1))
  fi

  # Only check rollout if probe is configured
  if kubectl rollout status deployment/"$DEP" -n "$NS" --timeout=30s >/dev/null 2>&1; then
    echo -e "${GREEN}[OK] Deployment rollout completed successfully.${NC}"
  else
    echo -e "${RED}[FAIL] Deployment rollout did not complete successfully.${NC}"
    ERRORS=$((ERRORS+1))
  fi
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 10-1 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 10-1 Failed with $ERRORS error(s).${NC}"
fi
