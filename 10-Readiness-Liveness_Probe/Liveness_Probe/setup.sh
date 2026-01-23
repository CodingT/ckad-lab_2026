#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 10-2 (Liveness Probe)...${NC}"

# Clean existing deployment and configmap
kubectl delete deployment api-deploy -n default --ignore-not-found
kubectl delete configmap nginx-config -n default --ignore-not-found
sleep 2

# Create ConfigMap with nginx config for port 8080 and /health endpoint
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: default
data:
  default.conf: |
    server {
      listen 8080;
      server_name _;
      location / {
        return 200 "OK\n";
        add_header Content-Type text/plain;
      }
      location /health {
        return 200 "Healthy\n";
        add_header Content-Type text/plain;
      }
    }
EOF

# Create Deployment without liveness probe (to be fixed by student)
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deploy
  namespace: default
  labels:
    app: api-deploy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-deploy
  template:
    metadata:
      labels:
        app: api-deploy
    spec:
      containers:
      - name: api
        image: nginxinc/nginx-unprivileged
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/conf.d
        # livenessProbe to be added by user
      volumes:
      - name: config
        configMap:
          name: nginx-config
EOF

# Wait for rollout (non-fatal if pending)
kubectl rollout status deployment/api-deploy -n default --timeout=30s || true

echo -e "${GREEN}[OK] Baseline deployment created without livenessProbe. Add the probe per task instructions.${NC}"

echo
cat "$DIR/task.md"
echo
echo -e "${GREEN}======================================${NC}"
echo
