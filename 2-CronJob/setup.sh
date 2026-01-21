#!/bin/bash


echo "Resetting environment for Question 2..."

# Ensure a clean state by deleting the cronjob if it already exists
kubectl delete cronjob backup-job -n default --ignore-not-found

echo "Environment reset complete."


# Display the task description
cat $(dirname "$0")/task.txt
