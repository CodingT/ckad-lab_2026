# Solution

## Step 1 – Create the Secret

Create a generic Secret with the database credentials:

```bash
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASS=Secret123! \
  -n default
```

## Step 2 – Update Deployment to use the Secret

Edit the Deployment to replace hard-coded environment variables with Secret references:

```bash
kubectl edit deploy api-server -n default
```

Replace the `env` section with:

```yaml
env:
  - name: DB_USER
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: DB_USER
  - name: DB_PASS
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: DB_PASS
```

Save and exit the editor.

## Step 3 – Verify the Deployment

Check that the rollout was successful:

```bash
kubectl rollout status deploy api-server -n default
```

Verify the Pod is running with the Secret environment variables:

```bash
kubectl get pods -n default
kubectl logs -n default <pod-name>
```
