### Solution

**Step 1 – Try to apply (will fail)**

```bash
kubectl apply -f /root/fix-ingress.yaml
# Error: pathType: Unsupported value: "InvalidType"
```

**Step 2 – View and fix the file**

```bash
cat /root/fix-ingress.yaml
vi /root/fix-ingress.yaml
```

Change the invalid `pathType` (e.g., `InvalidType`) to a valid value:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: default
spec:
  rules:
    - http:
        paths:
          - path: /api
            pathType: Prefix  # Changed from InvalidType
            backend:
              service:
                name: api-svc
                port:
                  number: 8080
```

**Step 3 – Apply the fixed manifest**

```bash
kubectl apply -f /root/fix-ingress.yaml
kubectl get ingress api-ingress -n default
```