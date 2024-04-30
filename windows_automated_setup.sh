#!/usr/bin/env bash

git submodule update --init --recursive

# Check if .bashrc exists, create it if it doesn't
if [ ! -f ~/.bashrc ]; then
    touch ~/.bashrc
fi

# ------------ SETUP OF ORBIT ------------

# Set the ORBIT_PATH environment variable
export ORBIT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )/dependencies/orbit" &> /dev/null && pwd )"
echo "ORBIT_PATH: $ORBIT_PATH"

# Check if ORBIT_PATH is already in .bashrc
if ! grep -q "export ORBIT_PATH=" ~/.bashrc; then
    echo "export ORBIT_PATH=\"$ORBIT_PATH\"" >> ~/.bashrc
fi

# Create an alias for the orbit script in the .bashrc file
if ! grep -q "alias orbit=" ~/.bashrc; then
    echo "alias orbit='${ORBIT_PATH}/orbit.sh'" >> ~/.bashrc
fi


# ---------- SETUP OF ISAAC SIM ----------

# Set the ISAACSIM_PATH environment variable
export ISAACSIM_PATH="/c/Users/$USERNAME/AppData/Local/ov/pkg/isaac_sim-2023.1.1"
echo "ISAACSIM_PATH: $ISAACSIM_PATH"

# Check if ISAACSIM_PATH is already in .bashrc
if ! grep -q "export ISAACSIM_PATH=" ~/.bashrc; then
    echo "export ISAACSIM_PATH=\"$ISAACSIM_PATH\"" >> ~/.bashrc
fi

# Set the ISAACSIM_PYTHON_EXE environment variable
export ISAACSIM_PYTHON_EXE="${ISAACSIM_PATH}/python.bat"
echo "ISAACSIM_PYTHON_EXE: $ISAACSIM_PYTHON_EXE"

# Check if ISAACSIM_PYTHON_EXE is already in .bashrc
if ! grep -q "export ISAACSIM_PYTHON_EXE=" ~/.bashrc; then
    echo "export ISAACSIM_PYTHON_EXE=\"$ISAACSIM_PYTHON_EXE\"" >> ~/.bashrc
fi


# Source the .bashrc file and print it out
source ~/.bashrc

echo ""
echo " %%%%%%%%%%%%% BASHRC %%%%%%%%%%%%% "
echo ""

cat ~/.bashrc

# Confirm with the user that the paths are correct
read -p "Press [Enter] key to start the rest of the setup, as long as these look correct..."


# Copy the .vscode directory and orbit.sh to dependencies/orbit
cp -r .vscode "dependencies/orbit"

cp orbit.sh "dependencies/orbit/orbit.sh"

# checks that python path is set correctly
${ISAACSIM_PYTHON_EXE} -c "print('Isaac Sim configuration is now complete.')"

echo "Setup complete!"
