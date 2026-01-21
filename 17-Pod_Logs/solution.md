### Solution

**Task 1 – Deploy Pod and Retrieve Logs**

```bash
kubectl apply -f /root/winter.yaml
```

Retrieve logs and save to file:

```bash
kubectl logs winter > /root/log_Output.txt
cat /root/log_Output.txt
```

**Task 2 – Find Pod with Highest CPU Usage**



View resource usage:

```bash
kubectl top pod -n cpu-stress
```

Find the pod with highest CPU and write name to file:

```bash
kubectl top pod -n cpu-stress --no-headers | sort -k2 -nr | head -n1 | awk '{print $1}' > /root/pod.txt
cat /root/pod.txt
```

Alternatively, you can manually identify from `kubectl top pod` output and write the name.
