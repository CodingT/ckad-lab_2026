#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

# Resetting environment...
echo "Resetting environment for Question 1..."

# Delete the secret if it exists (Cleanup solution)
kubectl delete secret db-credentials -n default --ignore-not-found

# Delete deployment to ensure fresh start (optional but cleaner)
kubectl delete deployment api-server -n default --ignore-not-found


# Generate fresh initial-deployment.yaml
cat <<EOF > $(dirname "$0")/initial-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  namespace: default
  labels:
    app: api-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
    spec:
      containers:
      - name: api-server
        image: nginx:alpine
        env:
        - name: DB_USER
          value: "admin"
        - name: DB_PASS
          value: "Secret123!"
EOF

# Apply the initial deployment
kubectl apply -f $(dirname "$0")/initial-deployment.yaml

echo -e "${GREEN}[OK] Environment reset complete.${NC}"


# Display the task description
cat $(dirname "$0")/task.md
echo
echo -e "${GREEN}======================================${NC}"
echo
