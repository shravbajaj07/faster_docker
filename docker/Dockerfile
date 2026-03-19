FROM osrf/ros:melodic-desktop-full

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-lc"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    git \
    python-pip \
    python-wstool \
    python-catkin-tools \
    tmux \
    x11-apps \
    mesa-utils \
    ros-melodic-gazebo-ros-pkgs \
    ros-melodic-mavros-msgs \
    ros-melodic-tf2-sensor-msgs \
    ros-melodic-control-toolbox \
    ros-melodic-ros-control \
    ros-melodic-robot-localization \
    ros-melodic-lms1xx \
    ros-melodic-interactive-marker-twist-server \
    ros-melodic-hector-gazebo-plugins \
    ros-melodic-move-base \
    ros-melodic-ros-controllers \
    ros-melodic-pointgrey-camera-description \
    ros-melodic-hardware-interface \
    ros-melodic-message-to-tf \
    ros-melodic-gazebo-ros-control \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir pyquaternion

ENV ROS_DISTRO=melodic
ENV CATKIN_WS=/workspaces/faster/ws

COPY docker/setup_ws.sh /usr/local/bin/setup_ws.sh
COPY docker/run_aerial_sim.sh /usr/local/bin/run_aerial_sim.sh
RUN chmod +x /usr/local/bin/setup_ws.sh /usr/local/bin/run_aerial_sim.sh

WORKDIR /workspaces/faster
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

# Create the directory and copy Gurobi from your host to the image
RUN mkdir -p /opt/gurobi
COPY docker/gurobi/ /opt/gurobi/

# Optional: Set environment variables Gurobi typically requires
ENV GUROBI_HOME="/opt/gurobi"
ENV PATH="${PATH}:${GUROBI_HOME}/bin"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
