### Solution

**Create the Pod**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: cache
  namespace: web
spec:
  containers:
  - name: redis
    image: redis:3.2
    ports:
    - containerPort: 6379
EOF
```

**Verify the Pod**

```bash
kubectl get pod cache -n web
kubectl describe pod cache -n web
```

The pod should be running and port 6379 should be exposed.
