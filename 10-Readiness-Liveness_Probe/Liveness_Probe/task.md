## Question 10-2 – Add Liveness Probe to Deployment

In namespace `default`, Deployment `api-deploy` exists with a container listening on port `8080`.

Your task:
1. Add a liveness probe to the Deployment with:
- HTTP GET on path `/health`
- Port `8080`
- `initialDelaySeconds: 5`
- `periodSeconds: 10`

2. Ensure the Deployment rolls out successfully.
