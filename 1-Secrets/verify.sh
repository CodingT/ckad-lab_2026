#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Verifying Question 1: Secrets..."

ERRORS=0

# --- Check Secret ---
if kubectl get secret db-credentials -n default > /dev/null 2>&1; then
    echo -e "${GREEN}[OK] Secret 'db-credentials' exists.${NC}"
    
    # Check Secret Data only if secret exists
    SECRET_JSON=$(kubectl get secret db-credentials -n default -o json)
    USER_ENC=$(echo "$SECRET_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['data'].get('DB_USER', ''))")
    PASS_ENC=$(echo "$SECRET_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['data'].get('DB_PASS', ''))")

    USER_DEC=$(echo "$USER_ENC" | base64 -d 2>/dev/null)
    PASS_DEC=$(echo "$PASS_ENC" | base64 -d 2>/dev/null)

    if [ "$USER_DEC" == "admin" ]; then
        echo -e "${GREEN}[OK] DB_USER is correct.${NC}"
    else
        echo -e "${RED}[FAIL] DB_USER is incorrect. Expected 'admin'.${NC}"
        ERRORS=$((ERRORS+1))
    fi

    if [ "$PASS_DEC" == "Secret123!" ]; then
        echo -e "${GREEN}[OK] DB_PASS is correct.${NC}"
    else
        echo -e "${RED}[FAIL] DB_PASS is incorrect. Expected 'Secret123!'.${NC}"
        ERRORS=$((ERRORS+1))
    fi

else
    echo -e "${RED}[FAIL] Secret 'db-credentials' does not exist.${NC}"
    echo -e "${YELLOW}[SKIP] Skipping Secret data checks.${NC}"
    ERRORS=$((ERRORS+1))
fi

# --- Check Deployment ---
# Deployment should usually exist as per setup, but good to check.
if kubectl get deployment api-server -n default > /dev/null 2>&1; then
    
    # Check Deployment configuration
    DEP_JSON=$(kubectl get deployment api-server -n default -o json)
    ENV_VARS=$(echo "$DEP_JSON" | python3 -c "import sys, json; print(json.dumps(json.load(sys.stdin)['spec']['template']['spec']['containers'][0].get('env', [])))")

    # Check usage of SecretKeyRef for DB_USER
    if echo "$ENV_VARS" | grep -q '"name": "DB_USER"' && echo "$ENV_VARS" | grep -q '"key": "DB_USER"' && echo "$ENV_VARS" | grep -q '"name": "db-credentials"'; then
         echo -e "${GREEN}[OK] Deployment uses secretKeyRef for DB_USER.${NC}"
    else
         echo -e "${RED}[FAIL] Deployment does not look like it references the secret for DB_USER correctly.${NC}"
         ERRORS=$((ERRORS+1))
    fi

    # Check usage of SecretKeyRef for DB_PASS
    if echo "$ENV_VARS" | grep -q '"name": "DB_PASS"' && echo "$ENV_VARS" | grep -q '"key": "DB_PASS"' && echo "$ENV_VARS" | grep -q '"name": "db-credentials"'; then
         echo -e "${GREEN}[OK] Deployment uses secretKeyRef for DB_PASS.${NC}"
    else
         echo -e "${RED}[FAIL] Deployment does not look like it references the secret for DB_PASS correctly.${NC}"
         ERRORS=$((ERRORS+1))
    fi
else
    echo -e "${RED}[FAIL] Deployment 'api-server' not found (unexpected).${NC}"
    ERRORS=$((ERRORS+1))
fi


if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Question 1 Completed Successfully!${NC}"
else
    echo -e "${RED}❌ Question 1 Failed with $ERRORS errors.${NC}"
fi
