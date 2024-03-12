# param($orbit_dir, $isaac_sim_dir, $bd0_orbit_rl_dir, $nested_dir)

# Set Isaac Sim directory
$currentUsername = $env:USERNAME
$isaac_sim_dir = "C:\Users\$currentUsername\AppData\Local\ov\pkg\isaac_sim-*"

# Get the current script's directory
$script_dir = Split-Path $script:MyInvocation.MyCommand.Path

# Get the 'automated_setup' directory
$automated_setup_dir = $script_dir

# Get the parent directory of 'automated_setup', which will also be the parent for 'orbit'
$parent_dir = Split-Path $automated_setup_dir

# Define the path for the 'orbit' directory, which should be a sibling to 'automated_setup'
$orbit_dir = Join-Path $parent_dir "orbit"

# If 'orbit' directory does not exist, create it
if (-not (Test-Path $orbit_dir)) {
    New-Item -ItemType Directory -Path $orbit_dir
}

# Now, both 'automated_setup' and 'orbit' directories exist under $parent_dir
# You can add your logic here to copy files or do other operations with the 'orbit' directory


# Create symlinks in the Orbit directory
New-Item -ItemType SymbolicLink -Path "$orbit_dir\_isaac_sim" -Target $isaac_sim_dir
