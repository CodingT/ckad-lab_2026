# Question 1 — Create and Use Secrets

In namespace **default**, Deployment `api-server` exists with hard-coded environment variables:

- `DB_USER=admin`
- `DB_PASS=Secret123!`

## Requirements

- Create a Secret named `db-credentials` in namespace **default** containing these credentials.
- Update Deployment `api-server` to use the Secret via `valueFrom.secretKeyRef`.
- Do not change the Deployment name or namespace.
