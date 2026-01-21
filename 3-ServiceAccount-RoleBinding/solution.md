# Solution — Question 3

## Steps

### 1) Create ServiceAccount
```bash
kubectl create sa log-sa -n audit
```

### 2) Create Role
```bash
kubectl apply -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: log-role
  namespace: audit
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
EOF
```

### 3) Create RoleBinding
```bash
kubectl create rolebinding log-rb \
  --role=log-role \
  --serviceaccount=audit:log-sa \
  -n audit
```

### 4) Update Pod to use ServiceAccount
Pods have immutable `serviceAccountName`; delete and recreate if needed.

```bash
kubectl get pod log-collector -n audit -o yaml > /tmp/log-collector.yaml
# edit /tmp/log-collector.yaml: set spec.serviceAccountName: log-sa (remove spec.serviceAccount if present)
kubectl delete pod log-collector -n audit
kubectl apply -f /tmp/log-collector.yaml

# Alternatively (may fail if immutable):
kubectl patch pod log-collector -n audit \
  -p '{"spec":{"serviceAccountName":"log-sa"}}'
```
