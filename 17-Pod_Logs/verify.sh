#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0

echo "Verifying Question 17: Pod Logs and CPU Usage..."

# --- Task 1: Check logs file exists and has content ---
if [ -f "/root/log_Output.txt" ]; then
  LOG_SIZE=$(wc -c < /root/log_Output.txt)
  if [ "$LOG_SIZE" -gt 0 ]; then
    echo -e "${GREEN}[OK] Log file exists with content.${NC}"
  else
    echo -e "${RED}[FAIL] Log file is empty.${NC}"
    ERRORS=$((ERRORS+1))
  fi
else
  echo -e "${RED}[FAIL] Log file /root/log_Output.txt does not exist.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Task 2: Check pod.txt file exists and has valid pod name ---
if [ -f "/root/pod.txt" ]; then
  POD_NAME=$(cat /root/pod.txt | tr -d '\n' | tr -d ' ')
  if [ -n "$POD_NAME" ]; then
    # Check if pod exists in cpu-stress namespace
    if kubectl get pod "$POD_NAME" -n cpu-stress >/dev/null 2>&1; then
      echo -e "${GREEN}[OK] Pod name file contains valid pod: $POD_NAME.${NC}"
    else
      echo -e "${RED}[FAIL] Pod name in file does not exist in cpu-stress namespace.${NC}"
      ERRORS=$((ERRORS+1))
    fi
  else
    echo -e "${RED}[FAIL] Pod name file is empty.${NC}"
    ERRORS=$((ERRORS+1))
  fi
else
  echo -e "${RED}[FAIL] Pod name file /root/pod.txt does not exist.${NC}"
  ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 17 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 17 Failed with $ERRORS error(s).${NC}"
fi
