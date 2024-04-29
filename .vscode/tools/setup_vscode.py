# Copyright (c) 2022-2024, The ORBIT Project Developers.
# All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""This script sets up the vs-code settings for the orbit project.

This script merges the python.analysis.extraPaths from the "_isaac_sim/.vscode/settings.json" file into
the ".vscode/settings.json" file.

This is necessary because Isaac Sim 2022.2.1 does not add the necessary python packages to the python path
when the "setup_python_env.sh" is run as part of the vs-code launch configuration.
"""

import re
import sys
import os
import pathlib


ORBIT_DIR = pathlib.Path(__file__).parents[2]
"""Path to the orbit directory."""
ISAACSIM_DIR = os.path.join(ORBIT_DIR, "_isaac_sim")
"""Path to the isaac-sim directory."""


def overwrite_python_analysis_extra_paths(orbit_settings: str) -> str:
    """Overwrite the python.analysis.extraPaths in the orbit settings file.

    The extraPaths are replaced with the path names from the isaac-sim settings file that exists in the
    "_isaac_sim/.vscode/settings.json" file.

    Args:
        orbit_settings: The settings string to use as template.

    Returns:
        The settings string with overwritten python analysis extra paths.

    Raises:
        FileNotFoundError: If the isaac-sim settings file does not exist.
    """
    # isaac-sim settings
    isaacsim_vscode_filename = os.path.join(ISAACSIM_DIR, ".vscode", "settings.json")
    # make sure the isaac-sim settings file exists
    if not os.path.exists(isaacsim_vscode_filename):
        raise FileNotFoundError(f"Could not find the isaac-sim settings file: {isaacsim_vscode_filename}")

    # read the path names from the isaac-sim settings file
    with open(isaacsim_vscode_filename) as f:
        vscode_settings = f.read()
    # extract the path names
    # search for the python.analysis.extraPaths section and extract the contents
    settings = re.search(r"\"python.analysis.extraPaths\": \[.*?\]", vscode_settings, flags=re.MULTILINE | re.DOTALL)
    settings = settings.group(0)
    settings = settings.split('"python.analysis.extraPaths": [')[-1]
    settings = settings.split("]")[0]
    # change the path names to be relative to the orbit directory
    path_names = settings.split(",")
    path_names = [path_name.strip().strip('"') for path_name in path_names]
    path_names = ['"${workspaceFolder}/_isaac_sim/' + path_name + '"' for path_name in path_names if len(path_name) > 0]
    # combine them into a single string
    path_names = ",\n\t\t".expandtabs(4).join(path_names)

    # replace the path names in the orbit settings file with the path names from the isaac-sim settings file
    orbit_settings = re.sub(
        r"\"python.analysis.extraPaths\": \[.*?\]",
        '"python.analysis.extraPaths": [\n\t\t'.expandtabs(4) + path_names + "\n\t]".expandtabs(4),
        orbit_settings,
        flags=re.DOTALL,
    )
    # return the orbit settings string
    return orbit_settings


def overwrite_default_python_interpreter(orbit_settings: str) -> str:
    """Overwrite the default python interpreter in the orbit settings file.

    The default python interpreter is replaced with the path to the python interpreter used by the
    isaac-sim project. This is necessary because the default python interpreter is the one shipped with
    isaac-sim.

    Args:
        orbit_settings: The settings string to use as template.

    Returns:
        The settings string with overwritten default python interpreter.
    """
    # read executable name
    python_exe = sys.executable
    # if python interpreter is from conda, use that. Otherwise, use the template.
    if "conda" not in python_exe:
        return orbit_settings
    # replace the default python interpreter in the orbit settings file with the path to the
    # python interpreter in the orbit directory
    orbit_settings = re.sub(
        r"\"python.defaultInterpreterPath\": \".*?\"",
        f'"python.defaultInterpreterPath": "{python_exe}"',
        orbit_settings,
        flags=re.DOTALL,
    )
    # return the orbit settings file
    return orbit_settings


def main():
    # orbit template settings
    orbit_vscode_template_filename = os.path.join(ORBIT_DIR, ".vscode", "tools", "settings.template.json")
    # make sure the orbit template settings file exists
    if not os.path.exists(orbit_vscode_template_filename):
        raise FileNotFoundError(f"Could not find the orbit template settings file: {orbit_vscode_template_filename}")
    # read the orbit template settings file
    with open(orbit_vscode_template_filename) as f:
        orbit_template_settings = f.read()

    # overwrite the python.analysis.extraPaths in the orbit settings file with the path names
    orbit_settings = overwrite_python_analysis_extra_paths(orbit_template_settings)
    # overwrite the default python interpreter in the orbit settings file
    # NOTE: thisis disabled since we don't need it. The default interpreter should always be the one from isaac-sim
    # orbit_settings = overwrite_default_python_interpreter(orbit_settings)

    # add template notice to the top of the file
    header_message = (
        "// This file is a template and is automatically generated by the setup_vscode.py script.\n"
        "// Do not edit this file directly.\n"
        "// \n"
        f"// Generated from: {orbit_vscode_template_filename}\n"
    )
    orbit_settings = header_message + orbit_settings

    # write the orbit settings file
    orbit_vscode_filename = os.path.join(ORBIT_DIR, ".vscode", "settings.json")
    with open(orbit_vscode_filename, "w") as f:
        f.write(orbit_settings)

    # copy the launch.json file if it doesn't exist
    orbit_vscode_launch_filename = os.path.join(ORBIT_DIR, ".vscode", "launch.json")
    orbit_vscode_template_launch_filename = os.path.join(ORBIT_DIR, ".vscode", "tools", "launch.template.json")
    if not os.path.exists(orbit_vscode_launch_filename):
        # read template launch settings
        with open(orbit_vscode_template_launch_filename) as f:
            orbit_template_launch_settings = f.read()
        # add header
        header_message = header_message.replace(orbit_vscode_template_filename, orbit_vscode_template_launch_filename)
        orbit_launch_settings = header_message + orbit_template_launch_settings
        # write the orbit launch settings file
        with open(orbit_vscode_launch_filename, "w") as f:
            f.write(orbit_launch_settings)


if __name__ == "__main__":
    main()