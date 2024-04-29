#!/usr/bin/env bash

# Copyright (c) 2022-2024, The ORBIT Project Developers.
# All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

#==
# Configurations
#==

# Exits if error occurs
set -e

# Set tab-spaces
tabs 4

# get source directory
export ORBIT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export ISAACSIM_PATH="/c/Users/$USERNAME/AppData/Local/ov/pkg/isaac_sim-*"
#==
# Helper functions
#==

# extract the python from isaacsim
extract_python_exe() {
    # Check if IsaacSim directory manually specified
    if [ ! -z ${ISAACSIM_PATH} ];
    then
        # Use local build
        build_path=${ISAACSIM_PATH}
    else
        # use python from kit
        local python_exe=${build_path}/python.bat
    fi
    # check if there is a python path available
    if [ ! -f "${python_exe}" ]; then
        echo "[ERROR] No python executable found at path: ${build_path}" >&2
        exit 1
    fi
    # return the result
    echo ${python_exe}
}

# extract the simulator exe from isaacsim
extract_isaacsim_exe() {
    # Check if IsaacSim directory manually specified
    if [ ! -z ${ISAACSIM_PATH} ];
    then
        # Use local build
        build_path=${ISAACSIM_PATH}
    fi
    # Isaac Sim executable to use
    local isaacsim_exe=${build_path}/isaac-sim.bat
    # check if there is a python path available
    if [ ! -f "${isaacsim_exe}" ]; then
        echo "[ERROR] No isaac-sim executable found at path: ${build_path}" >&2
        exit 1
    fi
    # return the result
    echo ${isaacsim_exe}
}

# check if input directory is a python extension and install the module
install_orbit_extension() {
    # retrieve the python executable
    python_exe=$(extract_python_exe)
    # if the directory contains setup.py then install the python module
    if [ -f "$1/setup.py" ];
    then
        echo -e "\t module: $1"
        ${python_exe} -m pip install --editable $1
    fi
}


# update the vscode settings from template and isaac sim settings
update_vscode_settings() {
    echo "[INFO] Setting up vscode settings..."
    # retrieve the python executable
    python_exe=$(extract_python_exe)
    # path to setup_vscode.py
    setup_vscode_script="${ORBIT_PATH}/.vscode/tools/setup_vscode.py"
    # check if the file exists before attempting to run it
    if [ -f "${setup_vscode_script}" ]; then
        ${python_exe} "${setup_vscode_script}"
    else
        echo "[WARNING] setup_vscode.py not found. Aborting vscode settings setup."
    fi
}

# print the usage description
print_help () {
    echo -e "\nusage: $(basename "$0") [-h] [-i] [-e] [-p] [-s] [-t] [-v] -- Utility to manage extensions in Orbit."
    echo -e "\noptional arguments:"
    echo -e "\t-h, --help           Display the help content."
    echo -e "\t-i, --install        Install the extensions inside Orbit."
    echo -e "\t-e, --extra          Install extra dependencies such as the learning frameworks."
    echo -e "\t-p, --python         Run the python executable (python.sh) provided by Isaac Sim."
    echo -e "\t-s, --sim            Run the simulator executable (isaac-sim.sh) provided by Isaac Sim."
    echo -e "\t-t, --test           Run all python unittest tests."
    echo -e "\t-v, --vscode         Generate the VSCode settings file from template."
    echo -e "\n" >&2
}

#==
# Main
#==

# check argument provided
if [ -z "$*" ]; then
    echo "[Error] No arguments provided." >&2;
    print_help
    exit 1
fi

# pass the arguments
while [[ $# -gt 0 ]]; do
    # read the key
    case "$1" in
        -i|--install)
            # install the python packages in omni_isaac_orbit/source directory
            echo "[INFO] Installing extensions inside orbit repository..."
            # recursively look into directories and install them
            # this does not check dependencies between extensions
            export -f extract_python_exe
            export -f install_orbit_extension
            # source directory
            find -L "${ORBIT_PATH}/source/extensions" -mindepth 1 -maxdepth 1 -type d -exec bash -c 'install_orbit_extension "{}"' \;
            # unset local variables
            unset install_orbit_extension
            # setup vscode settings
            update_vscode_settings
            shift # past argument
            ;;
        -e|--extra)
            # install the python packages for supported reinforcement learning frameworks
            echo "[INFO] Installing extra requirements such as learning frameworks..."
            python_exe=$(extract_python_exe)
            # check if specified which rl-framework to install
            if [ -z "$2" ]; then
                echo "[INFO] Installing all rl-frameworks..."
                framework_name="all"
            else
                echo "[INFO] Installing rl-framework: $2"
                framework_name=$2
                shift # past argument
            fi
            # install the rl-frameworks specified
            ${python_exe} -m pip install -e "./source/extensions/omni.isaac.orbit_tasks[${framework_name}]"
            shift # past argument
            ;;
        -p|--python)
            # run the python provided by isaacsim
            python_exe=$(extract_python_exe)
            echo "[INFO] Using python from: ${python_exe}"
            shift # past argument
            ${python_exe} $@
            # exit neatly
            break
            ;;
        -s|--sim)
            # run the simulator exe provided by isaacsim
            isaacsim_exe=$(extract_isaacsim_exe)
            echo "[INFO] Running isaac-sim from: ${isaacsim_exe}"
            shift # past argument
            ${isaacsim_exe} --ext-folder ${ORBIT_PATH}/source/extensions $@
            # exit neatly
            break
            ;;
        -t|--test)
            # run the python provided by isaacsim
            python_exe=$(extract_python_exe)
            shift # past argument
            ${python_exe} ${ORBIT_PATH}/tools/run_all_tests.py $@
            # exit neatly
            break
            ;;
        -v|--vscode)
            # update the vscode settings
            update_vscode_settings
            shift # past argument
            # exit neatly
            break
            ;;
        -h|--help)
            print_help
            exit 1
            ;;
        *) # unknown option
            echo "[Error] Invalid argument provided: $1"
            print_help
            exit 1
            ;;
    esac
done