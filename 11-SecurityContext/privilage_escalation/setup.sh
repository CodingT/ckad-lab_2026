#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 11-Privilege Escalation...${NC}"

# Clean existing deployment
kubectl delete deployment hotfix-deploy -n quetzal --ignore-not-found 2>/dev/null || true
kubectl delete namespace quetzal --ignore-not-found 2>/dev/null || true
sleep 2

# Create namespace
kubectl create namespace quetzal --dry-run=client -o yaml | kubectl apply -f - >/dev/null

# Create Deployment without security context (to be fixed by student)
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hotfix-deploy
  namespace: quetzal
  labels:
    app: hotfix
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hotfix
  template:
    metadata:
      labels:
        app: hotfix
    spec:
      containers:
      - name: hotfix-container
        image: nginxinc/nginx-unprivileged
        ports:
        - containerPort: 8080
        # No securityContext - to be added by user
EOF

# Wait for rollout
kubectl rollout status deployment/hotfix-deploy -n quetzal --timeout=30s || true

echo -e "${GREEN}[OK] Baseline deployment created without securityContext. Add security context per task instructions.${NC}"

echo
cat "$DIR/task.md"