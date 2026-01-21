### Solution

**Step 1 – Check the ResourceQuota**

```bash
kubectl get quota -n prod
kubectl describe quota <quota-name> -n prod
```

For example, if the quota shows:
- `limits.cpu: "2"`
- `limits.memory: "4Gi"`

Then half would be:
- CPU limit: `1` (or `1000m`)
- Memory limit: `2Gi`

**Step 2 – Create the Pod with half the quota limits**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: resource-pod
  namespace: prod
spec:
  containers:
    - name: web
      image: nginx:latest
      resources:
        requests:
          cpu: "100m"
          memory: "128Mi"
        limits:
          cpu: "1"
          memory: "2Gi"
EOF
```

**Note:** Adjust the limit values (`cpu: "1"`, `memory: "2Gi"`) based on what you found in the ResourceQuota. If quota shows `limits.cpu: "4"`, use `cpu: "2"`. If quota shows `limits.memory: "8Gi"`, use `memory: "4Gi"`.

