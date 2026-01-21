#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Verifying Question 3: ServiceAccount, Role, and RoleBinding..."

ERRORS=0

# --- Check ServiceAccount ---
if kubectl get serviceaccount log-sa -n audit > /dev/null 2>&1; then
    echo -e "${GREEN}[OK] ServiceAccount 'log-sa' exists in namespace audit.${NC}"
else
    echo -e "${RED}[FAIL] ServiceAccount 'log-sa' does not exist in namespace audit.${NC}"
    ERRORS=$((ERRORS+1))
fi

# --- Check Role ---
if kubectl get role log-role -n audit > /dev/null 2>&1; then
    echo -e "${GREEN}[OK] Role 'log-role' exists in namespace audit.${NC}"
    
    # Check Role rules
    ROLE_JSON=$(kubectl get role log-role -n audit -o json)
    
    # Check if role has correct resources (pods)
    if echo "$ROLE_JSON" | grep -q '"pods"'; then
        echo -e "${GREEN}[OK] Role grants permissions on 'pods' resource.${NC}"
    else
        echo -e "${RED}[FAIL] Role does not grant permissions on 'pods' resource.${NC}"
        ERRORS=$((ERRORS+1))
    fi
    
    # Check if role has correct verbs (get, list, watch)
    HAS_GET=$(echo "$ROLE_JSON" | grep -q '"get"' && echo "yes" || echo "no")
    HAS_LIST=$(echo "$ROLE_JSON" | grep -q '"list"' && echo "yes" || echo "no")
    HAS_WATCH=$(echo "$ROLE_JSON" | grep -q '"watch"' && echo "yes" || echo "no")
    
    if [ "$HAS_GET" == "yes" ] && [ "$HAS_LIST" == "yes" ] && [ "$HAS_WATCH" == "yes" ]; then
        echo -e "${GREEN}[OK] Role has correct verbs (get, list, watch).${NC}"
    else
        echo -e "${RED}[FAIL] Role is missing required verbs. Expected: get, list, watch.${NC}"
        ERRORS=$((ERRORS+1))
    fi
else
    echo -e "${RED}[FAIL] Role 'log-role' does not exist in namespace audit.${NC}"
    echo -e "${YELLOW}[SKIP] Skipping Role rules checks.${NC}"
    ERRORS=$((ERRORS+1))
fi

# --- Check RoleBinding ---
if kubectl get rolebinding log-rb -n audit > /dev/null 2>&1; then
    echo -e "${GREEN}[OK] RoleBinding 'log-rb' exists in namespace audit.${NC}"
    
    # Check RoleBinding references correct role
    RB_JSON=$(kubectl get rolebinding log-rb -n audit -o json)
    
    if echo "$RB_JSON" | grep -q '"name": "log-role"'; then
        echo -e "${GREEN}[OK] RoleBinding references Role 'log-role'.${NC}"
    else
        echo -e "${RED}[FAIL] RoleBinding does not reference Role 'log-role'.${NC}"
        ERRORS=$((ERRORS+1))
    fi
    
    # Check RoleBinding references correct ServiceAccount
    if echo "$RB_JSON" | grep -q '"name": "log-sa"' && echo "$RB_JSON" | grep -q '"kind": "ServiceAccount"'; then
        echo -e "${GREEN}[OK] RoleBinding binds to ServiceAccount 'log-sa'.${NC}"
    else
        echo -e "${RED}[FAIL] RoleBinding does not bind to ServiceAccount 'log-sa'.${NC}"
        ERRORS=$((ERRORS+1))
    fi
else
    echo -e "${RED}[FAIL] RoleBinding 'log-rb' does not exist in namespace audit.${NC}"
    echo -e "${YELLOW}[SKIP] Skipping RoleBinding checks.${NC}"
    ERRORS=$((ERRORS+1))
fi

# --- Check Pod ---
if kubectl get pod log-collector -n audit > /dev/null 2>&1; then
    echo -e "${GREEN}[OK] Pod 'log-collector' exists in namespace audit.${NC}"
    
    # Check Pod uses correct ServiceAccount
    POD_JSON=$(kubectl get pod log-collector -n audit -o json)
    POD_SA=$(echo "$POD_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['spec'].get('serviceAccountName', 'default'))" 2>/dev/null)
    
    if [ "$POD_SA" == "log-sa" ]; then
        echo -e "${GREEN}[OK] Pod uses ServiceAccount 'log-sa'.${NC}"
    else
        echo -e "${RED}[FAIL] Pod does not use ServiceAccount 'log-sa'. Current: '$POD_SA'.${NC}"
        ERRORS=$((ERRORS+1))
    fi
    
    # Check Pod logs for errors (should not have authorization errors)
    echo -e "${YELLOW}[INFO] Checking pod logs for authorization errors...${NC}"
    sleep 2
    POD_LOGS=$(kubectl logs log-collector -n audit --tail=10 2>&1)
    
    if echo "$POD_LOGS" | grep -qi "forbidden\|cannot list\|unauthorized"; then
        echo -e "${RED}[FAIL] Pod still has authorization errors. Check logs: kubectl logs log-collector -n audit${NC}"
        ERRORS=$((ERRORS+1))
    else
        echo -e "${GREEN}[OK] Pod is running without authorization errors.${NC}"
    fi
else
    echo -e "${RED}[FAIL] Pod 'log-collector' not found in namespace audit.${NC}"
    ERRORS=$((ERRORS+1))
fi


if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Question 3 Completed Successfully!${NC}"
else
    echo -e "${RED}❌ Question 3 Failed with $ERRORS errors.${NC}"
fi
