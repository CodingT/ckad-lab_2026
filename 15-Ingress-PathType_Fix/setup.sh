#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 15 (Ingress PathType Fix)...${NC}"

# Clean existing resources
kubectl delete service api-svc -n default --ignore-not-found 2>/dev/null || true
kubectl delete ingress api-ingress -n default --ignore-not-found 2>/dev/null || true
rm -f /root/fix-ingress.yaml
sleep 2

# Create Service
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: api-svc
  namespace: default
spec:
  selector:
    app: api
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080
  type: ClusterIP
EOF

# Create broken Ingress manifest at /root/fix-ingress.yaml
cat > /root/fix-ingress.yaml <<'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: default
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: ExactPath
            backend:
              service:
                name: web-svc
                port:
                  number: 80
EOF

echo -e "${GREEN}[OK] Environment ready. File /root/fix-ingress.yaml created with invalid pathType.${NC}"

echo
cat "$DIR/task.md"
echo
echo -e "${GREEN}======================================${NC}"
echo
