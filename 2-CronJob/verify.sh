#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Verifying Question 2: CronJob..."

ERRORS=0

# Check if CronJob exists
if kubectl get cronjob backup-job -n default > /dev/null 2>&1; then
    echo -e "${GREEN}[OK] CronJob 'backup-job' exists.${NC}"
    
    # Get JSON output
    CJ_JSON=$(kubectl get cronjob backup-job -n default -o json)

    # Check Schedule
    SCHEDULE=$(echo "$CJ_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['spec']['schedule'])")
    if [ "$SCHEDULE" == "*/30 * * * *" ]; then
        echo -e "${GREEN}[OK] Schedule is correct (*/30 * * * *).${NC}"
    else
        echo -e "${RED}[FAIL] Schedule is incorrect. Expected '*/30 * * * *', got '$SCHEDULE'.${NC}"
        ERRORS=$((ERRORS+1))
    fi

    # Check Image
    IMAGE=$(echo "$CJ_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['spec']['jobTemplate']['spec']['template']['spec']['containers'][0]['image'])")
    if [[ "$IMAGE" == "busybox:latest" || "$IMAGE" == "busybox" ]]; then
        echo -e "${GREEN}[OK] Image is correct (busybox:latest).${NC}"
    else
        echo -e "${RED}[FAIL] Image is incorrect. Expected 'busybox:latest', got '$IMAGE'.${NC}"
        ERRORS=$((ERRORS+1))
    fi

    # Check Limits
    SUCCESS_LIMIT=$(echo "$CJ_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['spec'].get('successfulJobsHistoryLimit', 'None'))")
    FAILED_LIMIT=$(echo "$CJ_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['spec'].get('failedJobsHistoryLimit', 'None'))")

    if [ "$SUCCESS_LIMIT" == "3" ]; then
        echo -e "${GREEN}[OK] successfulJobsHistoryLimit is 3.${NC}"
    else
        echo -e "${RED}[FAIL] successfulJobsHistoryLimit is incorrect. Expected 3, got '$SUCCESS_LIMIT'.${NC}"
        ERRORS=$((ERRORS+1))
    fi

    if [ "$FAILED_LIMIT" == "2" ]; then
        echo -e "${GREEN}[OK] failedJobsHistoryLimit is 2.${NC}"
    else
        echo -e "${RED}[FAIL] failedJobsHistoryLimit is incorrect. Expected 2, got '$FAILED_LIMIT'.${NC}"
        ERRORS=$((ERRORS+1))
    fi

    # Check ActiveDeadlineSeconds
    DEADLINE=$(echo "$CJ_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['spec']['jobTemplate']['spec'].get('activeDeadlineSeconds', 'None'))")
    if [ "$DEADLINE" == "300" ]; then
        echo -e "${GREEN}[OK] activeDeadlineSeconds is 300.${NC}"
    else
        echo -e "${RED}[FAIL] activeDeadlineSeconds is incorrect. Expected 300, got '$DEADLINE'.${NC}"
        ERRORS=$((ERRORS+1))
    fi

    # Check RestartPolicy
    POLICY=$(echo "$CJ_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['spec']['jobTemplate']['spec']['template']['spec']['restartPolicy'])")
    if [ "$POLICY" == "Never" ]; then
        echo -e "${GREEN}[OK] restartPolicy is Never.${NC}"
    else
        echo -e "${RED}[FAIL] restartPolicy is incorrect. Expected 'Never', got '$POLICY'.${NC}"
        ERRORS=$((ERRORS+1))
    fi

    # Check Command (Checking if it contains the echo message)
    COMMAND_ARGS=$(echo "$CJ_JSON" | python3 -c "import sys, json; c=json.load(sys.stdin)['spec']['jobTemplate']['spec']['template']['spec']['containers'][0]; print(str(c.get('command', [])) + str(c.get('args', [])))")
    if [[ "$COMMAND_ARGS" == *"Backup completed"* ]]; then
        echo -e "${GREEN}[OK] Command/Args contains 'Backup completed'.${NC}"
    else
        echo -e "${RED}[FAIL] Command/Args does not contain 'Backup completed'. Got: $COMMAND_ARGS${NC}"
        ERRORS=$((ERRORS+1))
    fi

else
    echo -e "${RED}[FAIL] CronJob 'backup-job' does not exist.${NC}"
    echo -e "${YELLOW}[SKIP] Skipping CronJob property checks.${NC}"
    ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Question 2 Completed Successfully!${NC}"
else
    echo -e "${RED}❌ Question 2 Failed with $ERRORS errors.${NC}"
fi
