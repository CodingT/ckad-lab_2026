### Solution

**Step 1 – Edit the Deployment**

```bash
kubectl edit deploy secure-app -n default
```

Add security context at Pod level and container level:

```yaml
spec:
  template:
    spec:
      containers:
        - name: app
          image: nginxinc/nginx-unprivileged
          ports:
            - containerPort: 8080
          securityContext:  # Container-level
            capabilities:
              add:
                - NET_ADMIN
```

Save and exit.

**Step 2 – Verify rollout**

```bash
kubectl rollout status deploy secure-app -n default
```

**Step 3 – Verify security context**

```bash
kubectl get pod -n default -l app=secure-app -o yaml | grep -A 10 securityContext
```

Or describe a pod:

```bash
kubectl describe pod <pod-name> -n default
```