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

#==
# Helper functions
#==

# extract the python from isaacsim
extract_python_exe() {
    if [ ! -z ${ISAACSIM_PATH} ];
    then
        build_path=${ISAACSIM_PATH}
    else
        build_path=${ORBIT_PATH}/_isaac_sim
    fi
    if ! [[ -z "${CONDA_PREFIX}" ]]; then
        local python_exe=${CONDA_PREFIX}/bin/python
    else
        local python_exe=${build_path}/python.bat
    fi
    if [ ! -f "${python_exe}" ]; then
        echo "[ERROR] No python executable found at path: ${build_path}" >&2
        exit 1
    fi
    echo ${python_exe}
}

# extract the simulator exe from isaacsim
extract_isaacsim_exe() {
    if [ ! -z ${ISAACSIM_PATH} ];
    then
        build_path=${ISAACSIM_PATH}
    else
        build_path=${ORBIT_PATH}/_isaac_sim
    fi
    local isaacsim_exe=${build_path}/isaac-sim.bat
    if [ ! -f "${isaacsim_exe}" ]; then
        echo "[ERROR] No isaac-sim executable found at path: ${build_path}" >&2
        exit 1
    fi
    echo ${isaacsim_exe}
}

# check if input directory is a python extension and install the module
install_orbit_extension() {
    python_exe=$(extract_python_exe)
    if [ -f "$1/setup.py" ];
    then
        echo -e "\t module: $1"
        ${python_exe} -m pip install --editable $1
    fi
}

# update the vscode settings from template and isaac sim settings
update_vscode_settings() {
    echo "[INFO] Setting up vscode settings..."
    python_exe=$(extract_python_exe)
    setup_vscode_script="${ORBIT_PATH}/.vscode/tools/setup_vscode.py"
    if [ -f "${setup_vscode_script}" ]; then
        ${python_exe} "${setup_vscode_script}"
    else
        echo "[WARNING] setup_vscode.py not found. Aborting vscode settings setup."
    fi
}

# print the usage description
print_help () {
    echo -e "\nusage: $(basename "$0") [-h] [-i] [-e] [-p] [-s] [-v] -- Utility to manage extensions in Orbit."
    echo -e "\noptional arguments:"
    echo -e "\t-h, --help           Display the help content."
    echo -e "\t-i, --install        Install the extensions inside Orbit."
    echo -e "\t-e, --extra          Install extra dependencies such as the learning frameworks."
    echo -e "\t-p, --python         Run the python executable (python.sh) provided by Isaac Sim."
    echo -e "\t-s, --sim            Run the simulator executable (isaac-sim.sh) provided by Isaac Sim."
    echo -e "\t-v, --vscode         Generate the VSCode settings file from template."
    echo -e "\n" >&2
}

#==
# Main
#==

if [ -z "$*" ]; then
    echo "[Error] No arguments provided." >&2;
    print_help
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--install)
            echo "[INFO] Installing extensions inside orbit repository..."
            export -f extract_python_exe
            export -f install_orbit_extension
            find -L "${ORBIT_PATH}/source/extensions" -mindepth 1 -maxdepth 1 -type d -exec bash -c 'install_orbit_extension "{}"' \;
            unset install_orbit_extension
            # update_vscode_settings
            shift
            ;;
        -e|--extra)
            echo "[INFO] Installing extra requirements such as learning frameworks..."
            python_exe=$(extract_python_exe)
            if [ -z "$2" ]; then
                echo "[INFO] Installing all rl-frameworks..."
                framework_name="all"
            else
                echo "[INFO] Installing rl-framework: $2"
                framework_name=$2
                shift # past argument
            fi
            ${python_exe} -m pip install -e "./source/extensions/omni.isaac.orbit_tasks[${framework_name}]"
            shift # past argument
            ;;
        -p|--python)
            python_exe=$(extract_python_exe)
            echo "[INFO] Using python from: ${python_exe}"
            shift # past argument
            ${python_exe} $@
            break
            ;;
        -s|--sim)
            isaacsim_exe=$(extract_isaacsim_exe)
            echo "[INFO] Running isaac-sim from: ${isaacsim_exe}"
            shift # past argument
            ${isaacsim_exe} --ext-folder ${ORBIT_PATH}/source/extensions $@
            break
            ;;
        -v|--vscode)
            update_vscode_settings
            shift # past argument
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
