#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 12 (Service Selector Fix)...${NC}"

# Clean existing resources
kubectl delete deployment web-app -n default --ignore-not-found 2>/dev/null || true
kubectl delete service web-svc -n default --ignore-not-found 2>/dev/null || true
sleep 2

# Create Deployment with correct labels
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: default
  labels:
    app: webapp
    tier: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
      tier: frontend
  template:
    metadata:
      labels:
        app: webapp
        tier: frontend
    spec:
      containers:
      - name: web
        image: nginxinc/nginx-unprivileged
        ports:
        - containerPort: 8080
EOF

# Create Service with incorrect selector (to be fixed by student)
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: default
spec:
  selector:
    app: wrongapp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: ClusterIP
EOF

# Wait for deployment rollout
kubectl rollout status deployment/web-app -n default --timeout=30s || true

echo -e "${GREEN}[OK] Environment ready. Deployment 'web-app' with correct labels, Service 'web-svc' with incorrect selector.${NC}"

echo
cat "$DIR/task.md"
echo
echo -e "${GREEN}======================================${NC}"
echo
