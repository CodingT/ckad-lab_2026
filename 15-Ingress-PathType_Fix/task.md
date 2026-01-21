## Question 15 – Fix Ingress PathType

File `/root/fix-ingress.yaml` contains an Ingress manifest that fails to apply due to an invalid `pathType` value.

Your task:
1. Apply the file and note the error
2. Fix the `pathType` to a valid value (`Prefix`, `Exact`, or `ImplementationSpecific`)
3. Ensure the Ingress routes path `/api` to Service `api-svc` on port `8080`
4. Apply the fixed manifest successfully