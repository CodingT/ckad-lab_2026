#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 20 (API Deprecation - HPA)...${NC}"

# Clean existing resources
kubectl delete hpa web-hpa --ignore-not-found 2>/dev/null || true
kubectl delete deployment web-app --ignore-not-found 2>/dev/null || true
rm -f ~/web-hpa.yaml
sleep 2

# Create Deployment that HPA will scale
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: default
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
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "256Mi"
EOF

# Create broken HPA manifest with old API version
cat > ~/web-hpa.yaml <<'EOF'
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 70
EOF

echo -e "${GREEN}[OK] Environment ready. Deployment 'web-app' created, HPA manifest at ~/web-hpa.yaml with deprecated API.${NC}"

echo
cat "$DIR/task.md"
