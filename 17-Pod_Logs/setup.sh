#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 17 (Pod Logs)...${NC}"

# Create working directory and files in /root
mkdir -p /root

# Create log output and pod name files
touch /root/log_Output.txt
touch /root/pod.txt

# Create winter.yaml manifest
cat > /root/winter.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: winter
  namespace: default
spec:
  containers:
  - name: winter-container
    image: busybox
    command: ["sh", "-c", "echo 'Winter pod started'; sleep 3600"]
EOF

# Delete old resources
kubectl delete pod winter -n default --ignore-not-found 2>/dev/null || true
kubectl delete namespace cpu-stress --ignore-not-found 2>/dev/null || true
sleep 2

# Create namespace for cpu-stress task
kubectl create namespace cpu-stress --dry-run=client -o yaml | kubectl apply -f - >/dev/null

# Create test pods in cpu-stress namespace
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: cpu-consumer-1
  namespace: cpu-stress
spec:
  containers:
  - name: cpu-task
    image: busybox
    command: ["sh", "-c", "while true; do dd if=/dev/zero bs=1M count=100 2>/dev/null | md5sum > /dev/null; done"]
    resources:
      requests:
        cpu: "500m"
        memory: "128Mi"
      limits:
        cpu: "500m"
        memory: "128Mi"
---
apiVersion: v1
kind: Pod
metadata:
  name: cpu-consumer-2
  namespace: cpu-stress
spec:
  containers:
  - name: cpu-task
    image: busybox
    command: ["sh", "-c", "while true; do dd if=/dev/zero bs=1M count=50 2>/dev/null | md5sum > /dev/null; done"]
    resources:
      requests:
        cpu: "250m"
        memory: "128Mi"
      limits:
        cpu: "250m"
        memory: "128Mi"
---
apiVersion: v1
kind: Pod
metadata:
  name: cpu-consumer-3
  namespace: cpu-stress
spec:
  containers:
  - name: cpu-task
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "100m"
        memory: "128Mi"
EOF

echo -e "${GREEN}[OK] Environment ready. Winter pod manifest created, cpu-stress namespace with test pods ready.${NC}"

echo
cat "$DIR/task.md"
