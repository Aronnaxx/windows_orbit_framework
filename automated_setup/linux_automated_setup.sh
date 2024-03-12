#!/bin/bash

isaac_sim_dir=$(ls -d $HOME/.local/share/ov/pkg/isaac_sim-* | head -1)

# Determine the directories based on script location
script_dir="$(dirname "$(realpath "$0")")"
automated_setup_dir="$script_dir"
# Get the parent directory of 'automated_setup', which will also be the parent for 'orbit'
parent_dir="$(dirname "$automated_setup_dir")"
# Define the path for the 'orbit' directory, which should be a sibling to 'automated_setup'
orbit_dir="$parent_dir/orbit"

# Check if 'orbit' directory exists, if not, create it
if [ ! -d "$orbit_dir" ]; then
    mkdir -p "$orbit_dir"
fi

# Clone Orbit if it doesn't exist and switch to the latest release
if [ ! -d "$orbit_dir" ]; then
    echo "Orbit directory not found. Cloning..."
    git clone https://github.com/NVIDIA-Omniverse/Orbit.git "$orbit_dir"
else
    echo "Orbit directory found."
fi

# Expand the wildcard to find the actual directory name

# Check if Isaac Sim directory exists
if [ ! -d "$isaac_sim_dir" ]; then
    echo "Isaac Sim directory not found."
    exit 1
fi

# Create symlinks in the Orbit directory
ln -sfn "$isaac_sim_dir" "$orbit_dir/_isaac_sim"

echo "All configurations are successfully applied."

# Run Orbit commands
echo "Running Orbit setup commands..."
cd "$orbit_dir"
./orbit.sh -v
./orbit.sh -i
./orbit.sh -e rsl_rl
./orbit.sh -p source/standalone/tutorials/03_envs/create_quadruped_base.py