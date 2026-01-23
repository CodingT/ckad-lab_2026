#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 9 (Rolling Update & Rollback)...${NC}"

# Clean existing deployment
kubectl delete deployment app-v1 -n default --ignore-not-found

# Brief pause for cleanup
sleep 2

# Base Deployment using nginx:1.20
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v1
  namespace: default
  labels:
    app: app-v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app-v1
  template:
    metadata:
      labels:
        app: app-v1
    spec:
      containers:
      - name: web
        image: nginx:1.20
        ports:
        - containerPort: 80
EOF

# Wait for readiness (non-fatal if slow)
kubectl rollout status deployment/app-v1 -n default --timeout=60s || true

echo -e "${GREEN}[OK] Baseline Deployment ready with image nginx:1.20.${NC}"

echo
cat "$DIR/task.md"
echo
echo -e "${GREEN}======================================${NC}"
echo
