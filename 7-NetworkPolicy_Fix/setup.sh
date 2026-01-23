#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 7 (NetworkPolicy Fix)...${NC}"

# Clean namespace
kubectl delete namespace network-demo --ignore-not-found
sleep 2

# Create namespace
kubectl create namespace network-demo

# Create Pods with incorrect labels (intentionally broken)
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: network-demo
  labels:
    role: wrong-frontend
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: backend
  namespace: network-demo
  labels:
    role: wrong-backend
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: database
  namespace: network-demo
  labels:
    role: wrong-db
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
EOF

# Create NetworkPolicies with correct selectors
kubectl apply -f - <<'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: network-demo
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: network-demo
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-to-db
  namespace: network-demo
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: backend
EOF

# Wait for pods to be ready
kubectl wait --for=condition=Ready pod --all -n network-demo --timeout=30s || true

echo -e "${GREEN}[OK] Environment ready. Pods have wrong labels; NetworkPolicies expect correct labels.${NC}"

echo
cat "$DIR/task.md"
echo
echo -e "${GREEN}======================================${NC}"
echo
