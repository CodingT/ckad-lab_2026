#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0
NS=default
HPA=web-hpa

echo "Verifying Question 20: Update HPA Manifest to Current API Version..."

# --- Check HPA exists ---
if ! kubectl get hpa "$HPA" -n "$NS" >/dev/null 2>&1; then
  echo -e "${RED}[FAIL] HPA $HPA not found in namespace $NS.${NC}"
  ERRORS=$((ERRORS+1))
  exit 1
fi

# --- Check HPA API version is autoscaling/v2 ---
API_VERSION=$(kubectl get hpa "$HPA" -n "$NS" -o jsonpath='{.apiVersion}' 2>/dev/null || true)
if [ "$API_VERSION" = "autoscaling/v2" ]; then
  echo -e "${GREEN}[OK] HPA API version is autoscaling/v2.${NC}"
else
  echo -e "${RED}[FAIL] HPA API version is incorrect (found: $API_VERSION).${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check HPA targets correct deployment ---
TARGET=$(kubectl get hpa "$HPA" -n "$NS" -o jsonpath='{.spec.scaleTargetRef.name}' 2>/dev/null || true)
if [ "$TARGET" = "web-app" ]; then
  echo -e "${GREEN}[OK] HPA targets correct Deployment 'web-app'.${NC}"
else
  echo -e "${RED}[FAIL] HPA target is incorrect.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check HPA min/max replicas ---
MIN=$(kubectl get hpa "$HPA" -n "$NS" -o jsonpath='{.spec.minReplicas}' 2>/dev/null || true)
MAX=$(kubectl get hpa "$HPA" -n "$NS" -o jsonpath='{.spec.maxReplicas}' 2>/dev/null || true)
if [ "$MIN" = "1" ] && [ "$MAX" = "5" ]; then
  echo -e "${GREEN}[OK] HPA replica bounds are correct (min: 1, max: 5).${NC}"
else
  echo -e "${RED}[FAIL] HPA replica bounds are incorrect.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check HPA has metrics configured ---
METRICS=$(kubectl get hpa "$HPA" -n "$NS" -o jsonpath='{.spec.metrics}' 2>/dev/null || true)
if [ -n "$METRICS" ]; then
  echo -e "${GREEN}[OK] HPA has metrics configured.${NC}"
else
  echo -e "${RED}[FAIL] HPA has no metrics configured.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check manifest file exists and has v2 API version ---
if [ -f ~/web-hpa.yaml ]; then
  FILE_API=$(grep '^apiVersion:' ~/web-hpa.yaml | head -1 | awk '{print $2}' || true)
  if [ "$FILE_API" = "autoscaling/v2" ]; then
    echo -e "${GREEN}[OK] Manifest file has correct API version (autoscaling/v2).${NC}"
  else
    echo -e "${RED}[FAIL] Manifest file has incorrect API version (found: $FILE_API).${NC}"
    ERRORS=$((ERRORS+1))
  fi
else
  echo -e "${RED}[FAIL] Manifest file ~/web-hpa.yaml not found.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check target utilization is set in manifest with v2 format ---
if grep -q 'metrics:' ~/web-hpa.yaml 2>/dev/null && ! grep -q 'targetCPUUtilizationPercentage\|targetMemoryUtilizationPercentage' ~/web-hpa.yaml 2>/dev/null; then
  echo -e "${GREEN}[OK] Manifest has v2 format metrics configured.${NC}"
else
  echo -e "${RED}[FAIL] Manifest does not use v2 metrics format (must have 'metrics:' key, not old 'targetCPUUtilizationPercentage').${NC}"
  ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 20 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 20 Failed with $ERRORS error(s).${NC}"
fi
