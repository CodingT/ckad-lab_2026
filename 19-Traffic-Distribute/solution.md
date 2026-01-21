### Solution

**Step 1 – Create Deployment for v1 (8 replicas for 80% traffic)**

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-v1
  namespace: production
spec:
  replicas: 8
  selector:
    matchLabels:
      app: webapp
      version: v1
  template:
    metadata:
      labels:
        app: webapp
        version: v1
    spec:
      containers:
      - name: webapp
        image: nginx
        ports:
        - containerPort: 80
EOF
```

**Step 2 – Create Deployment for v2 (2 replicas for 20% traffic)**

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-v2
  namespace: production
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
      - name: webapp
        image: nginx
        ports:
        - containerPort: 80
EOF
```

**Step 3 – Create Service to expose both versions**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: webapp-svc
  namespace: production
spec:
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF
```

**Verify**

```bash
kubectl get pods -n production -l app=webapp
kubectl describe svc webapp-svc -n production
```

The Service will distribute traffic across all 10 pods (8 v1 + 2 v2), resulting in ~80/20 traffic split.
