### Solution

**Step 1 – Scale existing Deployment**

```bash
kubectl scale deploy web-app --replicas=8 -n default
```

**Step 2 – Export and create canary Deployment**

Export the existing Deployment:

```bash
kubectl get deploy web-app -n default -o yaml > /tmp/web-app-canary.yaml
```

Edit the file to change:
- `metadata.name: web-app-canary`
- `spec.replicas: 2`
- `spec.template.metadata.labels.version: v2`
- `spec.selector.matchLabels.version: v2`
- Keep `app=webapp` label on both selector and template

Apply:

```bash
kubectl apply -f /tmp/web-app-canary.yaml
```

Or create directly:

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-canary
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
      version: v2
  template:
    metadata:
      labels:
        app: webapp
        version: v2
    spec:
      containers:
        - name: web
          image: nginx:latest
EOF
```

**Step 3 – Verify Service selects both**

```bash
kubectl get endpoints web-service -n default
kubectl get pods -n default -l app=webapp --show-labels
```

Both `version=v1` and `version=v2` pods should appear in endpoints.

**Step 4 – Test traffic split (if curl available)**

```bash
# Run multiple requests to see distribution
for i in {1..10}; do
  kubectl exec -it <pod-name> -n default -- curl http://web-service
done
```
```bash
kubectl run test-client --image=curlimages/curl:latest --rm -it --restart=Never -- sh -c '
for i in $(seq 1 20); do 
  curl -s http://web-service.default.svc.cluster.local | grep -o "nginx.*" | head -1
  sleep 0.1
done
'
```
#should return 10 IPs 
kubectl get endpoints web-service -n default -o yaml | grep -i 'ip' | wc -l