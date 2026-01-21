#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

ERRORS=0

echo "Verifying Question 5: Podman image build and tarball save..."

# --- Check image exists ---
if podman image exists my-app:1.0; then
  echo -e "${GREEN}[OK] Image 'my-app:1.0' exists.${NC}"
else
  echo -e "${RED}[FAIL] Image 'my-app:1.0' not found. Build it with podman ${NC}"
  ERRORS=$((ERRORS+1))
fi

# --- Check tarball exists and is readable ---
if [ -f /root/my-app.tar ]; then
  if tar -tf /root/my-app.tar >/dev/null 2>&1; then
    echo -e "${GREEN}[OK] Tarball /root/my-app.tar exists and is readable.${NC}"
  else
    echo -e "${RED}[FAIL] Tarball /root/my-app.tar exists but is not a valid tar archive.${NC}"
    ERRORS=$((ERRORS+1))
  fi
else
  echo -e "${RED}[FAIL] Tarball /root/my-app.tar not found. Save it with podman ${NC}"
  ERRORS=$((ERRORS+1))
fi

# Optional: ensure tarball corresponds to the image by checking manifest name
if [ -f /root/my-app.tar ] && podman image exists my-app:1.0; then
  if podman load -i /root/my-app.tar >/tmp/podman_verify_load.log 2>&1; then
    echo -e "${GREEN}[OK] Tarball loads successfully with podman load (see /tmp/podman_verify_load.log).${NC}"
  else
    echo -e "${RED}[FAIL] podman load failed for /root/my-app.tar (check /tmp/podman_verify_load.log).${NC}"
    ERRORS=$((ERRORS+1))
  fi
fi

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ Question 5 Completed Successfully!${NC}"
else
  echo -e "${RED}❌ Question 5 Failed with $ERRORS error(s).${NC}"
fi
