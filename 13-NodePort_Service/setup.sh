#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 13 (NodePort Service)...${NC}"

# Clean existing resources
kubectl delete deployment api-server -n default --ignore-not-found 2>/dev/null || true
kubectl delete service api-nodeport -n default --ignore-not-found 2>/dev/null || true
sleep 2

# Create Deployment with correct labels and port
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  namespace: default
  labels:
    app: api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: nginxinc/nginx-unprivileged
        ports:
        - containerPort: 9090
EOF

# Wait for deployment rollout
kubectl rollout status deployment/api-server -n default --timeout=30s || true

echo -e "${GREEN}[OK] Environment ready. Deployment 'api-server' with label app=api and port 9090.${NC}"

echo
cat "$DIR/task.md"
echo
echo -e "${GREEN}======================================${NC}"
echo
