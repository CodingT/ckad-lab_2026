### Solution

**Step 1 – Check the correct API version**

```bash
kubectl explain hpa
# Look for apiVersion in the output, typically autoscaling/v2 for modern Kubernetes
```

**Step 2 – Update the manifest**

Edit `~/web-hpa.yaml` and ensure it uses the correct API version:

```yaml
apiVersion: autoscaling/v2    # make sure it use correct api version here
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 1
  maxReplicas: 5
  metrics:         # correct here according to latest DOCs config
    - type: Resource
      resource:
        name: cpu
        target:             
          type: Utilization
          averageUtilization: 70
```

**Step 3 – Apply the manifest**

```bash
kubectl apply -f ~/web-hpa.yaml
```

**Step 4 – Verify the HPA**

```bash
kubectl get hpa
kubectl describe hpa web-hpa
kubectl get deployment web-app
```

K8s will create HPA with new version even if config file will not be updated, so it is important to fix manifest file itself as grading script most likelly will check it.
