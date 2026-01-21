#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 8 (Deployment Fix)...${NC}"

# Cleanup any existing deployment and file
kubectl delete -f /root/broken-deploy.yaml --ignore-not-found || true
rm -f /root/broken-deploy.yaml

# Create broken Deployment manifest
cat > /root/broken-deploy.yaml <<'EOF'
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: broken-app
  namespace: default
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: broken
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
EOF

echo -e "${GREEN}[OK] Broken manifest written to /root/broken-deploy.yaml${NC}"

echo
cat "$DIR/taks.md"
