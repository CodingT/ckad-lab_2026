## Question 10-1 – Add Readiness Probe to Deployment

In namespace `default`, Deployment `api-deploy` exists with a container listening on port `8080`.

Your task:
1. Add a readiness probe to the Deployment with:
- HTTP GET on path `/ready`
- Port `8080`
- `initialDelaySeconds: 5`
- `periodSeconds: 10`

2. Ensure the Deployment rolls out successfully.
