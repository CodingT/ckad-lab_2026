## Question 16 – Add Resource Requests and Limits to Pod

In namespace `prod`, a ResourceQuota exists that sets resource limits for the namespace.

Your task:
1. Check the ResourceQuota for namespace `prod` to see the limits set
2. Create a Pod named `resource-pod` with:
   - Image: `nginx:latest`
   - Set the CPU and memory limits to **half** of the limits set in the ResourceQuota
   - Set appropriate requests (at least `100m` CPU and `128Mi` memory)
