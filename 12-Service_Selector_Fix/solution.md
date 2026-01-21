### Solution

**Step 1 – Check current state**

```bash
kubectl get pods -n default --show-labels
kubectl get svc web-svc -n default -o yaml
kubectl get endpoints web-svc -n default  # Should be empty or wrong
```

**Step 2 – Update Service selector**

```bash
kubectl edit svc web-svc -n default
```

Change:

```yaml
spec:
  selector:
    app: wrongapp
```

To:

```yaml
spec:
  selector:
    app: webapp
```

Save and exit.

**Step 3 – Verify endpoints**

```bash
kubectl get endpoints web-svc -n default
# Should now show IPs of web-app pods
kubectl describe svc web-svc -n default
```