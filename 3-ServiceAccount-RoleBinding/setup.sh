#!/bin/bash


# Resetting environment...
echo "Resetting environment for Question 3..."

# Delete resources if they exist (Cleanup solution)
kubectl delete rolebinding log-rb -n audit --ignore-not-found
kubectl delete role log-role -n audit --ignore-not-found
kubectl delete serviceaccount log-sa -n audit --ignore-not-found
kubectl delete pod log-collector -n audit --ignore-not-found
kubectl delete namespace audit --ignore-not-found

# Wait a moment for cleanup
sleep 2

# Create namespace
kubectl create namespace audit

# Create Pod that will fail with authorization errors
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: log-collector
  namespace: audit
spec:
  containers:
  - name: log-collector
    image: bitnami/kubectl:latest
    command: ['sh', '-c', 'while true; do kubectl get pods -n audit; sleep 5; done']
EOF

echo "Environment reset complete."
echo ""
echo "Waiting for pod to start..."
sleep 3

echo ""
echo "Checking pod logs (showing authorization error):"
kubectl logs -n audit log-collector 2>&1 || echo "Pod may still be starting..."

echo ""
echo "===================="
echo ""

# Display the task description
cat $(dirname "$0")/task.md
