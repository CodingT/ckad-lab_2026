## Question 19 – Distribute Traffic Between Multiple Application Versions

In namespace `production`, an application named `webapp` has two versions (v1 and v2).

Your task:
- Create Deployments `webapp-v1` and `webapp-v2` with appropriate replicas
- Both versions must be accessible through Service `webapp-svc`
- Route approximately 80% of traffic to v1 and 20% to v2
- Use only Kubernetes native objects (no Ingress, Service Mesh, or external load balancers)

**Note:** Traffic distribution is achieved by adjusting the number of pod replicas.
