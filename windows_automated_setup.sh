#!/usr/bin/env bash

echo "This script does the following:"
echo ""
echo "1. Check if you have a bashrc and Orbit installed, and if not, do so."
echo "2. Create the Orbit and Isaac Sim paths for your bashrc."
echo "3. Copy the \".vscode\" and \"orbit.sh\" folders into Orbit's main directory in order to allow for Windows-based Orbit development."
echo ""
echo "Should any part of this script not work as intended, simply copy the .vscode and orbit.sh items into the Orbit directory. This will let you run ./orbit.sh inside of the Orbit project, and follow the installation steps on the project's documentation page as usual."
echo ""
echo "Please note that some items, such as CMAKE and certain LINUX based libraries will not work without further modification / installation. This script has been tested and confirmed working with Isaac Sim 2023.1.1, and Orbit Release v0.3.0"
echo ""
read -p "Please type 'windows_orbit' to continue and acknowledge that you have read the above: " user_input
if [ "$user_input" != "windows_orbit" ]; then
    echo "Invalid input. Exiting script."
    exit 1
fi



# Update and initialize git submodules recursively
git submodule update --init --recursive

# Check if .bashrc exists in the user's home directory, create it if it doesn't
if [ ! -f ~/.bashrc ]; then
    touch ~/.bashrc
fi

# ------------ SETUP OF ORBIT ------------

# Check if the "orbit" directory exists in the parent directory
if [ ! -d "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../orbit" &> /dev/null && pwd )" ]; then
    # Print an error message if the "orbit" directory is not found
    echo "[ERROR] The 'orbit' directory is not found in the expected location."
    # Prompt the user to clone the 'orbit' repository
    read -p "Do you want to clone the 'orbit' repository here? (y/n): " choice
    if [[ "$choice" == [Yy]* ]]; then
        # Clone the 'orbit' repository into the parent directory
        git clone https://github.com/your-repo/orbit.git "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )/orbit"
        # Change directory to the newly cloned 'orbit' directory
        cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../orbit" &> /dev/null && pwd )"
        # Checkout the v0.3.0 tag in the 'orbit' repository
        git checkout v0.3.0
    else
        # Print a message and exit if the user chooses not to clone the repository
        echo "Please make sure that the 'orbit' directory is installed in the same directory as this repo."
        exit 1
    fi
fi

# Set the ORBIT_PATH environment variable to the path of the 'orbit' directory
export ORBIT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../orbit" &> /dev/null && pwd )"
# Check if ORBIT_PATH is already defined in .bashrc, if not, add it
if ! grep -q "export ORBIT_PATH=" ~/.bashrc; then
    echo "export ORBIT_PATH=\"$ORBIT_PATH\"" >> ~/.bashrc
fi

# Create an alias for the orbit script in the .bashrc file if it doesn't already exist
if ! grep -q "alias orbit=" ~/.bashrc; then
    echo "alias orbit='${ORBIT_PATH}/orbit.sh'" >> ~/.bashrc
fi

# ---------- SETUP OF ISAAC SIM ----------

# Set the ISAACSIM_PATH environment variable to the path of the Isaac Sim installation
export ISAACSIM_PATH="/c/Users/$USERNAME/AppData/Local/ov/pkg/isaac_sim-2023.1.1"

# Check if ISAACSIM_PATH is already defined in .bashrc, if not, add it
if ! grep -q "export ISAACSIM_PATH=" ~/.bashrc; then
    echo "export ISAACSIM_PATH=\"$ISAACSIM_PATH\"" >> ~/.bashrc
fi

# Set the ISAACSIM_PYTHON_EXE environment variable to the path of the Isaac Sim Python executable
export ISAACSIM_PYTHON_EXE="${ISAACSIM_PATH}/python.bat"

# Check if ISAACSIM_PYTHON_EXE is already defined in .bashrc, if not, add it
if ! grep -q "export ISAACSIM_PYTHON_EXE=" ~/.bashrc; then
    echo "export ISAACSIM_PYTHON_EXE=\"$ISAACSIM_PYTHON_EXE\"" >> ~/.bashrc
fi

# Source the .bashrc file to apply the changes made
source ~/.bashrc

# Print the contents of the .bashrc file to the console
echo ""
echo " %%%%%%%%%%%%% BASHRC %%%%%%%%%%%%% "
echo ""
cat ~/.bashrc

echo ""
echo " %%%%%%%%%%%%% %%%%%%%%%%%%% %%%%%%%%%%%%% "
echo ""

# Prompt the user to confirm that the paths are correct before proceeding
read -p "Press [Enter] key to start the rest of the setup, as long as these look correct..."

# Get the directory that the script is located in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Copy the .vscode directory to the ORBIT_PATH directory
cp -r "${DIR}/.vscode" "${ORBIT_PATH}/"

# Copy the orbit.sh script to the ORBIT_PATH directory
cp "${DIR}/orbit.sh" "${ORBIT_PATH}/"

# Check that the Python executable path is set correctly by running a simple Python command
${ISAACSIM_PYTHON_EXE} -c "print('Isaac Sim configuration is now complete.')"

# Run the orbit.sh script with the -i option to install extensions
"${ORBIT_PATH}/orbit.sh" -i

# Print a message indicating that the Windows framework setup is complete
echo "Windows framework setup complete!"
