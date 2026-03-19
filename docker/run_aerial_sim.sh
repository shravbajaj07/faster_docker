#!/usr/bin/env bash
set -euo pipefail

WS_DIR="${1:-/workspaces/faster/ws}"

source /opt/ros/melodic/setup.bash
source "${WS_DIR}/devel/setup.bash"

SESSION_NAME=faster_aerial

if tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
  echo "tmux session ${SESSION_NAME} already exists. Attach with: tmux attach -t ${SESSION_NAME}"
  exit 0
fi

tmux new-session -d -s "${SESSION_NAME}" -n world
tmux send-keys -t "${SESSION_NAME}:world" "roslaunch acl_sim start_world.launch" C-m

tmux new-window -t "${SESSION_NAME}" -n tracker
tmux send-keys -t "${SESSION_NAME}:tracker" "roslaunch acl_sim perfect_tracker_and_sim.launch" C-m

tmux new-window -t "${SESSION_NAME}" -n mapper
tmux send-keys -t "${SESSION_NAME}:mapper" "roslaunch global_mapper_ros global_mapper_node.launch" C-m

tmux new-window -t "${SESSION_NAME}" -n ui
tmux send-keys -t "${SESSION_NAME}:ui" "roslaunch faster faster_interface.launch" C-m

tmux new-window -t "${SESSION_NAME}" -n planner
tmux send-keys -t "${SESSION_NAME}:planner" "roslaunch faster faster.launch" C-m

echo "Launched aerial simulation in tmux session ${SESSION_NAME}."
echo "Attach using: tmux attach -t ${SESSION_NAME}"
