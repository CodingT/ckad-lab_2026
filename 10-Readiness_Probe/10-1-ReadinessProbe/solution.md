### Solution

**Step 1 – Edit the Deployment**

```bash
kubectl edit deploy nginx -n default
```

Add under the container spec:

```yaml
spec:
  template:
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
          readinessProbe:
            httpGet:
              path: /ready
              port: 80
            initialDelaySeconds: 5
```

Save and exit.

**Step 2 – Verify rollout**

```bash
kubectl rollout status deploy nginx -n default
kubectl describe deploy nginx -n default
```

**Step 3 – Check probe status**

```bash
kubectl get pods -n default -l app=nginx
kubectl describe pod <pod-name> -n default
# Look for Readiness in Conditions section
```
