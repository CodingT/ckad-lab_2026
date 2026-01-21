#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0
NS=default
SVC=api-nodeport

echo "Verifying Question 13: NodePort Service..."

# --- Check service exists ---
if ! kubectl get service "$SVC" -n "$NS" >/dev/null 2>&1; then
  echo -e "${RED}[FAIL] Service $SVC not found in namespace $NS.${NC}"
  ERRORS=$((ERRORS+1))
  exit 1
fi

# --- Check service type is NodePort ---
SVC_TYPE=$(kubectl get service "$SVC" -n "$NS" -o jsonpath='{.spec.type}' 2>/dev/null || true)
if [ "$SVC_TYPE" = "NodePort" ]; then
  echo -e "${GREEN}[OK] Service type is NodePort.${NC}"
else
  echo -e "${RED}[FAIL] Service type is incorrect.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check service selector ---
SELECTOR=$(kubectl get service "$SVC" -n "$NS" -o jsonpath='{.spec.selector.app}' 2>/dev/null || true)
if [ "$SELECTOR" = "api" ]; then
  echo -e "${GREEN}[OK] Service selector is correct.${NC}"
else
  echo -e "${RED}[FAIL] Service selector is incorrect.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check port mapping ---
PORT=$(kubectl get service "$SVC" -n "$NS" -o jsonpath='{.spec.ports[0].port}' 2>/dev/null || true)
TARGET_PORT=$(kubectl get service "$SVC" -n "$NS" -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null || true)
if [ "$PORT" = "80" ] && [ "$TARGET_PORT" = "9090" ]; then
  echo -e "${GREEN}[OK] Port mapping is correct (80 -> 9090).${NC}"
else
  echo -e "${RED}[FAIL] Port mapping is incorrect.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check NodePort is assigned ---
NODEPORT=$(kubectl get service "$SVC" -n "$NS" -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || true)
if [ -n "$NODEPORT" ] && [ "$NODEPORT" != "0" ]; then
  echo -e "${GREEN}[OK] NodePort assigned: $NODEPORT.${NC}"
else
  echo -e "${RED}[FAIL] NodePort not assigned.${NC}"
  ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 13 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 13 Failed with $ERRORS error(s).${NC}"
fi
