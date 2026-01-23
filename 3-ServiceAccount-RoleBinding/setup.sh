#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 3 (ServiceAccount & RoleBinding)...${NC}"

# Delete resources if they exist (Cleanup solution)
kubectl delete rolebinding log-rb -n audit --ignore-not-found 2>/dev/null || true
kubectl delete role log-role -n audit --ignore-not-found 2>/dev/null || true
kubectl delete serviceaccount log-sa -n audit --ignore-not-found 2>/dev/null || true
kubectl delete pod log-collector -n audit --ignore-not-found 2>/dev/null || true
kubectl delete namespace audit --ignore-not-found 2>/dev/null || true

# Wait a moment for cleanup
sleep 2

# Create namespace
kubectl create namespace audit

# Create Pod that will fail with authorization errors
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: log-collector
  namespace: audit
spec:
  serviceAccountName: default
  containers:
  - name: log-collector
    image: bitnami/kubectl:latest
    command: ['sh', '-c', 'while true; do kubectl get pods -n audit; sleep 5; done']
EOF

# Wait for pod to be created and running
echo "Waiting for pod to start and show authorization error..."
for i in {1..30}; do
  if kubectl get pod log-collector -n audit &>/dev/null; then
    PHASE=$(kubectl get pod log-collector -n audit -o jsonpath='{.status.phase}' 2>/dev/null || echo "")
    if [ "$PHASE" = "Running" ] || [ "$PHASE" = "CrashLoopBackOff" ]; then
      break
    fi
  fi
  sleep 1
done

sleep 2

echo -e "${GREEN}[OK] Environment ready. Pod 'log-collector' created in namespace 'audit'.${NC}"
echo -e "${GREEN}[OK] Pod is showing authorization errors as expected.${NC}"

echo
cat "$DIR/task.md"
