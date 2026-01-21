# Question 3 — ServiceAccount, Role, and RoleBinding

In namespace **audit**, Pod `log-collector` is failing with authorization errors.

Check the Pod logs to identify the missing permissions:

```bash
kubectl logs -n audit log-collector
```

Example error:

```text
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:audit:default" cannot list resource "pods" in API group "" in the namespace "audit"
```

## Requirements
- Create ServiceAccount `log-sa` in **audit**.
- Create Role `log-role` in **audit** with verbs `get`, `list`, `watch` on resource `pods`.
- Create RoleBinding `log-rb` in **audit** binding Role `log-role` to ServiceAccount `log-sa`.
- Update Pod `log-collector` in **audit** to use ServiceAccount `log-sa`.
