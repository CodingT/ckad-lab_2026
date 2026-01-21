# Question 2 — Create CronJob with Schedule and History Limits

Create a CronJob named `backup-job` in namespace **default** with the following specifications:

## Requirements

- **Schedule**: Run every 30 minutes (`*/30 * * * *`)
- **Image**: `busybox:latest`
- **Container command**: `echo "Backup completed"`
- **successfulJobsHistoryLimit**: 3
- **failedJobsHistoryLimit**: 2
- **activeDeadlineSeconds**: 300
- **restartPolicy**: Never
