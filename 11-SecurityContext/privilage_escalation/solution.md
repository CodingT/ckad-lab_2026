### Solution

**Step 1 – Edit the Deployment**

```bash
kubectl edit deploy hotfix-deployment -n quetzal
```

Add security context at Pod level and container level:

```yaml
spec:
  template:
    spec:
      securityContext:  # Pod-level
        runAsUser: 30000
      containers:
        - name: hotfix-container
          image: nginxinc/nginx-unprivileged
          ports:
            - containerPort: 8080
          securityContext:  # Container-level
            allowPrivilegeEscalation: false
```

Save and exit.

**Step 2 – Verify rollout**

```bash
kubectl rollout status deploy hotfix-deployment -n quetzal
```

**Step 3 – Verify security context**

```bash
kubectl get pod -n quetzal -l app=hotfix -o yaml | grep -A 10 securityContext
```

Or describe a pod:

```bash
kubectl describe pod <pod-name> -n quetzal
```