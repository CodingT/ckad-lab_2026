#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 6 (Canary Deployment)...${NC}"

# Clean previous resources
kubectl delete deployment web-app web-app-canary -n default --ignore-not-found
kubectl delete service web-service -n default --ignore-not-found

# Give the API a brief moment
sleep 2

# Base deployment (v1) with 5 replicas
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: default
  labels:
    app: webapp
    version: v1
spec:
  replicas: 5
  selector:
    matchLabels:
      app: webapp
      version: v1
  template:
    metadata:
      labels:
        app: webapp
        version: v1
    spec:
      containers:
      - name: web
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
EOF

# Service selecting app=webapp (will target both v1 and v2 when canary is added)
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: default
spec:
  selector:
    app: webapp
  ports:
  - name: http
    port: 80
    targetPort: 80
EOF

echo -e "${GREEN}[OK] Environment ready.${NC}"
echo

cat "$DIR/task.md"
echo
echo -e "${GREEN}======================================${NC}"
echo
