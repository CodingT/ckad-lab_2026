## Question 10-1 – Add Readiness Probe to Deployment

In namespace `default`, Deployment `nginx` exists with a container listening on port `80`.

Your task:
Add a readiness probe to the Deployment with:
- HTTP GET on path `/ready`
- Port `80`
- `initialDelaySeconds: 5`

Do not modify any other settings.
