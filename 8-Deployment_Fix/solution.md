### Solution

**Step 1 – View the broken file**

```bash
cat /root/broken-deploy.yaml
```

You'll likely see something like:

```yaml
apiVersion: extensions/v1beta1  # Deprecated
kind: Deployment
metadata:
  name: broken-app
spec:
  replicas: 2
  template:  # Missing selector
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: web
          image: nginx
```

**Step 2 – Fix the file**

```bash
vi /root/broken-deploy.yaml
```

Update to:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: web
          image: nginx
```

**Step 3 – Apply and verify**

```bash
kubectl apply -f /root/broken-deploy.yaml
kubectl get deploy broken-app
kubectl rollout status deploy broken-app
kubectl get pods -l app=myapp