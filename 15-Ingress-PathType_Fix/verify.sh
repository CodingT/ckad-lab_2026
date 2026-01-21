#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0
NS=default
INGRESS=api-ingress

echo "Verifying Question 15: Ingress PathType Fix..."

# --- Check ingress exists ---
if ! kubectl get ingress "$INGRESS" -n "$NS" >/dev/null 2>&1; then
  echo -e "${RED}[FAIL] Ingress $INGRESS not found in namespace $NS.${NC}"
  ERRORS=$((ERRORS+1))
  exit 1
fi

# --- Check pathType is valid ---
PATH_TYPE=$(kubectl get ingress "$INGRESS" -n "$NS" -o jsonpath='{.spec.rules[0].http.paths[0].pathType}' 2>/dev/null || true)
if [ "$PATH_TYPE" = "Prefix" ] || [ "$PATH_TYPE" = "Exact" ] || [ "$PATH_TYPE" = "ImplementationSpecific" ]; then
  echo -e "${GREEN}[OK] Ingress pathType is valid.${NC}"
else
  echo -e "${RED}[FAIL] Ingress pathType is invalid.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check path ---
PATH_VAL=$(kubectl get ingress "$INGRESS" -n "$NS" -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null || true)
if [ "$PATH_VAL" = "/api" ]; then
  echo -e "${GREEN}[OK] Ingress path is correct.${NC}"
else
  echo -e "${RED}[FAIL] Ingress path is incorrect.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check backend service ---
BACKEND_SVC=$(kubectl get ingress "$INGRESS" -n "$NS" -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null || true)
BACKEND_PORT=$(kubectl get ingress "$INGRESS" -n "$NS" -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null || true)
if [ "$BACKEND_SVC" = "api-svc" ] && [ "$BACKEND_PORT" = "8080" ]; then
  echo -e "${GREEN}[OK] Ingress backend service and port are correct.${NC}"
else
  echo -e "${RED}[FAIL] Ingress backend service or port is incorrect.${NC}"
  ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 15 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 15 Failed with $ERRORS error(s).${NC}"
fi
