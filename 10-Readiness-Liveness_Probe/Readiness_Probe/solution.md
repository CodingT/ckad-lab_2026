### Solution

**Step 1 – Edit the Deployment**

```bash
kubectl edit deploy api-deploy -n default
```

Add the readiness probe under the container spec:

```yaml
spec:
  template:
    spec:
      containers:
        - name: api
          image: nginxinc/nginx-unprivileged
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: config
              mountPath: /etc/nginx/conf.d
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
```

**Step 3 – Check probe status**

```bash
kubectl get pods -n default -l app=api-deploy
kubectl describe pod <pod-name> -n default
```

Look for **Readiness** in the Conditions section - it should show `True`.
