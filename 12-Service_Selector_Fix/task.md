# Question 12 – Fix Service Selector

In namespace `default`, Deployment `web-app` exists with Pods labeled `app=webapp, tier=frontend`.

Service `web-svc` exists but has incorrect selector `app=wrongapp`.

Your task:
1. Update Service `web-svc` to correctly select Pods from Deployment `web-app`.