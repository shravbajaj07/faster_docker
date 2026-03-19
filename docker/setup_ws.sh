#!/usr/bin/env bash
set -euo pipefail

SIM_MODE="${1:-aerial}"
REPO_ROOT="${2:-/workspaces/faster}"
WS_DIR="${3:-${REPO_ROOT}/ws}"
SRC_DIR="${WS_DIR}/src"

source "/opt/ros/${ROS_DISTRO}/setup.bash"

if [[ ! -d "${REPO_ROOT}/faster" || ! -d "${REPO_ROOT}/faster_msgs" ]]; then
  echo "Expected repository root at ${REPO_ROOT} with faster and faster_msgs directories." >&2
  exit 1
fi

if [[ -z "${GUROBI_HOME:-}" || ! -d "${GUROBI_HOME}" ]]; then
  echo "GUROBI_HOME is not set to a valid directory. Current value: ${GUROBI_HOME:-<unset>}" >&2
  exit 1
fi

# Normalize GUROBI_HOME to the linux64 directory expected by FindGUROBI.cmake.
if [[ -d "${GUROBI_HOME}/linux64" ]]; then
  export GUROBI_HOME="${GUROBI_HOME}/linux64"
fi

if [[ ! -d "${GUROBI_HOME}/lib" ]]; then
  echo "GUROBI_HOME does not contain a lib directory: ${GUROBI_HOME}" >&2
  exit 1
fi

if [[ ! -d "${GUROBI_HOME}/include" ]]; then
  echo "GUROBI_HOME does not contain an include directory: ${GUROBI_HOME}" >&2
  exit 1
fi

export GUROBI_DIR="${GUROBI_HOME}"
export PATH="${GUROBI_HOME}/bin:${PATH}"
export LD_LIBRARY_PATH="${GUROBI_HOME}/lib:${LD_LIBRARY_PATH:-}"

# Newer Gurobi versions ship libgurobi<major>.so, while FindGUROBI searches for libgurobi.so.
if [[ ! -e "${GUROBI_HOME}/lib/libgurobi.so" ]]; then
  versioned_lib="$(ls -1 "${GUROBI_HOME}"/lib/libgurobi*.so 2>/dev/null | grep -E 'libgurobi[0-9]+\.so$' | head -n 1 || true)"
  if [[ -n "${versioned_lib}" ]]; then
    ln -sf "$(basename "${versioned_lib}")" "${GUROBI_HOME}/lib/libgurobi.so"
  fi
fi

if [[ ! -e "${GUROBI_HOME}/lib/libgurobi.so" ]]; then
  echo "Could not locate a Gurobi shared library in ${GUROBI_HOME}/lib" >&2
  exit 1
fi

if [[ ! -f "${GRB_LICENSE_FILE:-}" ]]; then
  echo "GRB_LICENSE_FILE is not set to a valid license file. Current value: ${GRB_LICENSE_FILE:-<unset>}" >&2
  exit 1
fi

mkdir -p "${SRC_DIR}"

link_if_missing() {
  local src_path="$1"
  local dst_path="$2"
  if [[ ! -e "${dst_path}" ]]; then
    ln -s "${src_path}" "${dst_path}"
  fi
}

link_if_missing "${REPO_ROOT}/faster" "${SRC_DIR}/faster"
link_if_missing "${REPO_ROOT}/faster_msgs" "${SRC_DIR}/faster_msgs"
link_if_missing "${REPO_ROOT}/thirdparty" "${SRC_DIR}/thirdparty"

cd "${SRC_DIR}"

if [[ ! -f .rosinstall ]]; then
  wstool init .
fi

wstool merge "${SRC_DIR}/faster/install/faster.rosinstall"
if [[ "${SIM_MODE}" == "ground" ]]; then
  wstool merge "${SRC_DIR}/faster/install/faster_ground_robot.rosinstall"
fi

wstool update -j8

catkin config --workspace "${WS_DIR}" --extend "/opt/ros/${ROS_DISTRO}" -DCMAKE_BUILD_TYPE=Release
catkin build --workspace "${WS_DIR}"

echo
if [[ "${SIM_MODE}" == "ground" ]]; then
  echo "Build complete for ground mode."
else
  echo "Build complete for aerial mode."
fi
echo "Use this before launching: source ${WS_DIR}/devel/setup.bash"
