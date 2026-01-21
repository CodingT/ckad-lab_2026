## Question 20 – Update HPA Manifest to Current API Version

A team has an HPA (HorizontalPodAutoscaler) manifest created for an older Kubernetes cluster at `~/web-hpa.yaml`.

Your task:
- Identify the correct API version for HPA on Kubernetes v1.32
- Update the manifest to use the current API version
- Verify the HPA is created successfully
- The HPA should scale Deployment `web-app` based on CPU utilization at 70%
