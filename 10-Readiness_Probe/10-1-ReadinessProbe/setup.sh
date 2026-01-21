#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 10-1 (Readiness Probe - HTTP GET on port 80)...${NC}"

# Clean existing deployment
kubectl delete deployment nginx -n default --ignore-not-found
sleep 2

# Create Deployment without readiness probe (to be fixed by student)
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        # readinessProbe to be added by user
EOF

# Wait for rollout (non-fatal if pending)
kubectl rollout status deployment/nginx -n default --timeout=30s || true

echo -e "${GREEN}[OK] Baseline deployment created without readinessProbe. Add the probe per task instructions.${NC}"

echo
cat "$DIR/task.md"