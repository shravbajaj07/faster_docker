#!/usr/bin/env bash
# Quick setup helper for FASTER Docker simulation
# Automatically detects host Gurobi and sets env vars

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env.docker"

echo "=== FASTER Docker Quick Setup ==="
echo "Repository: ${REPO_ROOT}"

# Detect Gurobi install
GUROBI_PATH=""
for path in /opt/gurobi1* /opt/gurobi; do
  if [[ -d "${path}/linux64" ]] && [[ -f "${path}/gurobi.lic" ]]; then
    GUROBI_PATH="${path}"
    echo "✓ Gurobi found at: ${GUROBI_PATH}"
    break
  fi
done

if [[ -z "${GUROBI_PATH}" ]]; then
  echo "✗ Gurobi not found in /opt/gurobi* directories."
  echo "Set GUROBI_HOST_PATH manually: export GUROBI_HOST_PATH=/your/gurobi/path"
  exit 1
fi

# Write .env.docker
cat > "${ENV_FILE}" <<EOF
# Docker environment overrides
GUROBI_HOST_PATH=${GUROBI_PATH}
DISPLAY=\${DISPLAY:-:0}
EOF

echo "✓ Env file updated: ${ENV_FILE}"
echo

echo "=== Building Docker image ==="
docker compose --env-file "${ENV_FILE}" -f "${SCRIPT_DIR}/docker-compose.yml" build

echo
echo "=== Starting container shell ==="
docker compose --env-file "${ENV_FILE}" -f "${SCRIPT_DIR}/docker-compose.yml" run --rm faster-sim bash
