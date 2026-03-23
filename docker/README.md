 # Docker setup for FASTER simulation

This setup targets Ubuntu 18.04 + ROS Melodic inside Docker.

## Why this simulation mode

Recommended default: **aerial simulation**.

Reason:
- It is the primary workflow documented in this repository.
- The ground robot path often needs controller gain retuning across Gazebo versions.

If you still want ground mode, use `setup_ws.sh ground`.

## Prerequisites on host

- Docker Engine + Docker Compose plugin
- X11 desktop session (for Gazebo and RViz)
- A working Gurobi install and license file on host

Expected host directory structure (customizable via `GUROBI_HOST_PATH`):

```
/opt/gurobi/ (or /opt/gurobi1301/ or similar)
├── linux64/
│   ├── bin/
│   ├── lib/
│   └── ...
└── gurobi.lic
```

If your Gurobi path is different, set:

```bash
export GUROBI_HOST_PATH=/your/gurobi/path
```

Example for a versioned install:

```bash
export GUROBI_HOST_PATH=/opt/gurobi1301
```

## Quick Start (Easiest)

```bash
bash docker/quickstart.sh
```

This script auto-detects your Gurobi install, creates `.env.docker`, builds the image, and launches the shell.

---

## Manual Steps

### 1) Allow X11 from local Docker containers

```bash
xhost +local:docker
```

### 2) Build image

Run from repository root:

```bash
docker compose -f docker/docker-compose.yml build
```

### 3) Start container shell

```bash
docker compose -f docker/docker-compose.yml run --rm faster-sim bash
```

### 4) Build workspace inside container

Aerial mode:

```bash
/usr/local/bin/setup_ws.sh aerial
```

Ground mode:

```bash
/usr/local/bin/setup_ws.sh ground
```

## 5) Launch aerial simulation

After build finishes, still in container shell:

```bash
source /workspaces/faster/ws/devel/setup.bash
/usr/local/bin/run_aerial_sim.sh
```

Attach to tmux session:

```bash
tmux attach -t faster_aerial
```

## Manual launch sequence (equivalent)

```bash
roslaunch acl_sim start_world.launch
roslaunch acl_sim perfect_tracker_and_sim.launch
roslaunch global_mapper_ros global_mapper_node.launch
roslaunch faster faster_interface.launch
roslaunch faster faster.launch
```

## Notes

- `setup_ws.sh` validates `GUROBI_HOME` and `GRB_LICENSE_FILE` before building.
- If Gazebo/RViz cannot open display, verify `DISPLAY` env var and `/tmp/.X11-unix` mount in compose.
- Might have to add Gurobi license to docker if the build or run command fails.
