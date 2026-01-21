#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0
NS=network-demo

echo "Verifying Question 7: Pod labels for NetworkPolicy fix..."

# --- Check frontend pod label ---
if kubectl get pod frontend -n "$NS" >/dev/null 2>&1; then
  FRONTEND_ROLE=$(kubectl get pod frontend -n "$NS" -o jsonpath='{.metadata.labels.role}')
  if [ "$FRONTEND_ROLE" = "frontend" ]; then
    echo -e "${GREEN}[OK] Pod 'frontend' has correct label role=frontend.${NC}"
  else
    echo -e "${RED}[FAIL] Pod 'frontend' label is incorrect (role=${FRONTEND_ROLE}).${NC}"
    ERRORS=$((ERRORS+1))
  fi
else
  echo -e "${RED}[FAIL] Pod 'frontend' not found in namespace ${NS}.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check backend pod label ---
if kubectl get pod backend -n "$NS" >/dev/null 2>&1; then
  BACKEND_ROLE=$(kubectl get pod backend -n "$NS" -o jsonpath='{.metadata.labels.role}')
  if [ "$BACKEND_ROLE" = "backend" ]; then
    echo -e "${GREEN}[OK] Pod 'backend' has correct label role=backend.${NC}"
  else
    echo -e "${RED}[FAIL] Pod 'backend' label is incorrect (role=${BACKEND_ROLE}).${NC}"
    ERRORS=$((ERRORS+1))
  fi
else
  echo -e "${RED}[FAIL] Pod 'backend' not found in namespace ${NS}.${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check database pod label ---
if kubectl get pod database -n "$NS" >/dev/null 2>&1; then
  DB_ROLE=$(kubectl get pod database -n "$NS" -o jsonpath='{.metadata.labels.role}')
  if [ "$DB_ROLE" = "db" ]; then
    echo -e "${GREEN}[OK] Pod 'database' has correct label role=db.${NC}"
  else
    echo -e "${RED}[FAIL] Pod 'database' label is incorrect (role=${DB_ROLE}).${NC}"
    ERRORS=$((ERRORS+1))
    fi
  else
    echo -e "${RED}[FAIL] Pod 'database' not found in namespace ${NS}.${NC}"
    ERRORS=$((ERRORS+1))
  fi

  # --- Test NetworkPolicy traffic flow (run regardless of label results) ---
  echo -e "${YELLOW}[INFO] Testing NetworkPolicy traffic flow...${NC}"

  BACKEND_IP=$(kubectl get pod backend -n "$NS" -o jsonpath='{.status.podIP}' 2>/dev/null)
  DB_IP=$(kubectl get pod database -n "$NS" -o jsonpath='{.status.podIP}' 2>/dev/null)

  if [ -z "$BACKEND_IP" ] || [ -z "$DB_IP" ]; then
    echo -e "${RED}[FAIL] Could not resolve pod IPs (backend=${BACKEND_IP:-none}, database=${DB_IP:-none}).${NC}"
    ERRORS=$((ERRORS+1))
  fi

  # Test frontend → backend (should succeed)
  if kubectl exec -n "$NS" frontend -- wget -qO- --timeout=2 "$BACKEND_IP:80" >/dev/null 2>&1; then
    echo -e "${GREEN}[OK] Traffic frontend → backend: allowed (expected).${NC}"
  else
    echo -e "${RED}[FAIL] Traffic frontend → backend: blocked (should be allowed).${NC}"
    ERRORS=$((ERRORS+1))
  fi

  # Test backend → database (should succeed)
  if kubectl exec -n "$NS" backend -- wget -qO- --timeout=2 "$DB_IP:80" >/dev/null 2>&1; then
    echo -e "${GREEN}[OK] Traffic backend → database: allowed (expected).${NC}"
  else
    echo -e "${RED}[FAIL] Traffic backend → database: blocked (should be allowed).${NC}"
    ERRORS=$((ERRORS+1))
  fi

  # Test frontend → database (should fail/timeout)
  if kubectl exec -n "$NS" frontend -- wget -qO- --timeout=2 "$DB_IP:80" >/dev/null 2>&1; then
    echo -e "${RED}[FAIL] Traffic frontend → database: allowed (should be blocked).${NC}"
    ERRORS=$((ERRORS+1))
  else
    echo -e "${GREEN}[OK] Traffic frontend → database: blocked (expected).${NC}"
  fi

  if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 7 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 7 Failed with $ERRORS error(s).${NC}"
fi
