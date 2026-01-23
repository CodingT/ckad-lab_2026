#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

set -euo pipefail
DIR=$(dirname "$0")

echo -e "${GREEN}Resetting environment for Question 5...${NC}"

# Clean old artifacts
podman rmi my-app:1.0 -f >/dev/null 2>&1 || true
rm -f /root/my-app.tar

# Prepare build context with a simple Dockerfile
mkdir -p /root/app-source
cat > /root/app-source/Dockerfile <<'EOF'
FROM docker.io/library/alpine:3.19
RUN echo "Hello CKAD" > /app.txt
CMD ["cat", "/app.txt"]
EOF

# Show the task description
echo -e "${GREEN}[OK] Environment ready. Build container per task instructions.${NC}"
echo
cat "$DIR/task.md"
echo
echo -e "${GREEN}======================================${NC}"
echo


