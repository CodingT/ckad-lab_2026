## Question 13 – Create NodePort Service

In namespace `default`, Deployment `api-server` exists with Pods labeled `app=api` and container port `9090`.

Your task:
Create a Service named `api-nodeport` that:
- Type: `NodePort`
- Selects Pods with label `app=api`
- Exposes Service port `80` mapping to target port `9090`