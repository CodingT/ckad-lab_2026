#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m' # No Color

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 4...${NC}"

# Clean up namespace to ensure fresh start
kubectl delete namespace monitoring --ignore-not-found

# Give Kubernetes a moment to remove resources
sleep 2

# Recreate namespace
kubectl create namespace monitoring

# ServiceAccounts
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: monitor-sa
  namespace: monitoring
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: wrong-sa
  namespace: monitoring
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-sa
  namespace: monitoring
EOF

# Roles
kubectl apply -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: metrics-reader
  namespace: monitoring
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: full-access
  namespace: monitoring
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: view-only
  namespace: monitoring
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
EOF

# RoleBindings
kubectl apply -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: monitor-binding
  namespace: monitoring
subjects:
- kind: ServiceAccount
  name: monitor-sa
  namespace: monitoring
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: metrics-reader
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: admin-binding
  namespace: monitoring
subjects:
- kind: ServiceAccount
  name: admin-sa
  namespace: monitoring
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: full-access
EOF

# Pod using wrong ServiceAccount (intentionally broken)
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: metrics-pod
  namespace: monitoring
spec:
  serviceAccountName: wrong-sa
  containers:
  - name: metrics
    image: bitnami/kubectl:latest
    command: ['sh', '-c', 'while true; do kubectl get pods -n monitoring; sleep 5; done']
EOF

# Wait for pod to start (may log authorization errors as intended)
kubectl wait --for=condition=Ready pod/metrics-pod -n monitoring --timeout=30s || true

echo -e "${GREEN}[OK] Environment ready for Question 4. Pod should show authorization errors due to wrong ServiceAccount.${NC}"

echo
cat "$DIR/task.md"
