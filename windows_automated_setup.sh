#!/bin/bash

git submodule update --init --recursive

# Check if .bashrc exists, create it if it doesn't
if [ ! -f ~/.bashrc ]; then
    touch ~/.bashrc
fi

# ------------ SETUP OF ORBIT ------------

# Set the ORBIT_PATH environment variable
ORBIT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )/dependencies/orbit" &> /dev/null && pwd )"
export ORBIT_PATH
echo "ORBIT_PATH: $ORBIT_PATH"

# Check if ORBIT_PATH is already in .bashrc
if ! grep -q "export ORBIT_PATH=" ~/.bashrc; then
    echo "export ORBIT_PATH=\"$ORBIT_PATH\"" >> ~/.bashrc
fi

# Define the ORBIT_DIR variable
ORBIT_DIR="$ORBIT_PATH"
export ORBIT_DIR
echo "ORBIT_DIR: $ORBIT_DIR"

# Check if ORBIT_DIR is already in .bashrc
if ! grep -q "export ORBIT_DIR=" ~/.bashrc; then
    echo "export ORBIT_DIR=\"$ORBIT_DIR\"" >> ~/.bashrc
fi

# Add a function to run orbit.sh from $ORBIT_DIR
if ! grep -q "orbit.sh()" ~/.bashrc; then
    # Append orbit.sh function to .bashrc
    echo 'orbit.sh() {
    $ORBIT_DIR/orbit.sh "$@"
}' >> ~/.bashrc
fi


# ---------- SETUP OF ISAAC SIM ----------

# Set the ISAACSIM_PATH environment variable
ISAACSIM_PATH="/c/Users/$USERNAME/AppData/Local/ov/pkg/isaac_sim-2023.1.1"
export ISAACSIM_PATH
echo "ISAACSIM_PATH: $ISAACSIM_PATH"

# Check if ISAACSIM_PATH is already in .bashrc
if ! grep -q "export ISAACSIM_PATH=" ~/.bashrc; then
    echo "export ISAACSIM_PATH=\"$ISAACSIM_PATH\"" >> ~/.bashrc
fi

# Set the ISAACSIM_PYTHON_EXE environment variable
ISAACSIM_PYTHON_EXE="${ISAACSIM_PATH}/python.bat"
export ISAACSIM_PYTHON_EXE
echo "ISAACSIM_PYTHON_EXE: $ISAACSIM_PYTHON_EXE"

# Check if ISAACSIM_PYTHON_EXE is already in .bashrc
if ! grep -q "export ISAACSIM_PYTHON_EXE=" ~/.bashrc; then
    echo "export ISAACSIM_PYTHON_EXE=\"$ISAACSIM_PYTHON_EXE\"" >> ~/.bashrc
fi

# Check if python.sh function is already defined in .bashrc
if ! grep -q "python.sh()" ~/.bashrc; then
    # Append python.sh function to .bashrc
    echo 'python.sh() {
    python.bat "$@"
}' >> ~/.bashrc
fi

# Check if isaac-sim.sh function is already defined in .bashrc
if ! grep -q "isaac-sim.sh()" ~/.bashrc; then
    # Append isaac-sim.sh function to .bashrc
    echo 'isaac-sim.sh() {
    isaac-sim.bat "$@"
}' >> ~/.bashrc
fi

source ~/.bashrc

echo ""
echo " %%%%%%%%%%%%% BASHRC %%%%%%%%%%%%% "
echo ""

cat ~/.bashrc


read -p "Press [Enter] key to start the rest of the setup, as long as these look correct..."


# Copy the .vscode directory to dependencies/orbit
cp -r .vscode "dependencies/orbit/.vscode"


# checks that python path is set correctly
${ISAACSIM_PYTHON_EXE} -c "print('Isaac Sim configuration is now complete.')"

echo "Setup complete!"