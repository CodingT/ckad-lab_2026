### Solution

**Step 1 – View existing NetworkPolicies**

```bash
kubectl get networkpolicies -n network-demo -o yaml
```

Identify the label selectors used in the NetworkPolicies (likely `role=frontend`, `role=backend`, `role=db`).

**Step 2 – Update Pod labels**

```bash
kubectl label pod frontend -n network-demo role=frontend --overwrite
kubectl label pod backend -n network-demo role=backend --overwrite
kubectl label pod database -n network-demo role=db --overwrite
```

Verify:

```bash
kubectl get pods -n network-demo --show-labels
```

**Step 3 – Verify NetworkPolicy rules**

```bash
kubectl describe networkpolicy allow-frontend-to-backend -n network-demo
kubectl describe networkpolicy allow-backend-to-db -n network-demo
```

**Step 4 – Test connectivity**

Test frontend → backend (should work):

```bash
BACKEND_IP=$(kubectl get pod backend -n network-demo -o jsonpath='{.status.podIP}')
kubectl exec -n network-demo frontend -- wget -qO- --timeout=2 $BACKEND_IP:80
```

Test backend → database (should work):

```bash
DB_IP=$(kubectl get pod database -n network-demo -o jsonpath='{.status.podIP}')
kubectl exec -n network-demo backend -- wget -qO- --timeout=2 $DB_IP:80
```

Test frontend → database (should FAIL - blocked by policy):

```bash
kubectl exec -n network-demo frontend -- wget -qO- --timeout=2 $DB_IP:80
```

Expected result: timeout or connection refused (no policy allows frontend → database directly)


