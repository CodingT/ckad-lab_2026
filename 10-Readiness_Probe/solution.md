### Solution

**Step 1 – Edit the Deployment**

```bash
kubectl edit deploy api-deploy -n default
```

Add under the container spec:

```yaml
spec:
  template:
    spec:
      containers:
        - name: api
          image: nginx
          ports:
            - containerPort: 8080
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
```

Save and exit.

**Step 2 – Verify rollout**

```bash
kubectl rollout status deploy api-deploy -n default
kubectl describe deploy api-deploy -n default
```

**Step 3 – Check probe status**

```bash
kubectl get pods -n default -l app=api-deploy
kubectl describe pod <pod-name> -n default
# Look for Readiness in Conditions section
```