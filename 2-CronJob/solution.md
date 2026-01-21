# Solution

## Step 1 – Create the CronJob

Apply the CronJob manifest with all required specifications:

```bash
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
  namespace: default
spec:
  schedule: "*/30 * * * *"
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 2
  jobTemplate:
    spec:
      activeDeadlineSeconds: 300
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: backup
              image: busybox:latest
              command: ["/bin/sh", "-c"]
              args: ["echo Backup completed"]
EOF
```

## Step 2 – Verify the CronJob

Check that the CronJob was created successfully:

```bash
kubectl get cronjob backup-job
```

Get detailed information about the CronJob:

```bash
kubectl describe cronjob backup-job
```

## Step 3 – Test the CronJob

To test immediately without waiting for the schedule, create a Job from the CronJob:

```bash
kubectl create job backup-job-test --from=cronjob/backup-job
```

Check the Job status and logs:

```bash
kubectl get jobs
kubectl logs job/backup-job-test
```
