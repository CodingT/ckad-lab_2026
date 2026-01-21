#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 11 (Security Context)...${NC}"

# Clean existing deployment
kubectl delete deployment secure-app -n default --ignore-not-found
sleep 2

# Create Deployment without security context (to be fixed by student)
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  namespace: default
  labels:
    app: secure-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      containers:
      - name: app
        image: nginxinc/nginx-unprivileged
        ports:
        - containerPort: 8080
        # No securityContext - to be added by user
EOF

# Wait for rollout
kubectl rollout status deployment/secure-app -n default --timeout=30s || true

echo -e "${GREEN}[OK] Baseline deployment created without securityContext. Add security context per task instructions.${NC}"

echo
cat "$DIR/task.md"
