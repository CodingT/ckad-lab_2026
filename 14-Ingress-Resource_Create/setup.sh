#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 14 (Ingress Resource)...${NC}"

# Clean existing resources
kubectl delete deployment web-deploy -n default --ignore-not-found 2>/dev/null || true
kubectl delete service web-svc -n default --ignore-not-found 2>/dev/null || true
kubectl delete ingress web-ingress -n default --ignore-not-found 2>/dev/null || true
sleep 2

# Create Deployment
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deploy
  namespace: default
  labels:
    app: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginxinc/nginx-unprivileged
        ports:
        - containerPort: 8080
EOF

# Create Service
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: default
spec:
  selector:
    app: web
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080
  type: ClusterIP
EOF

# Wait for deployment rollout
kubectl rollout status deployment/web-deploy -n default --timeout=30s || true

echo -e "${GREEN}[OK] Environment ready. Deployment 'web-deploy' and Service 'web-svc' created.${NC}"

echo
cat "$DIR/task.md"
echo
echo -e "${GREEN}======================================${NC}"
echo
