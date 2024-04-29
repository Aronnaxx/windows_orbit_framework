# Set Isaac Sim directory
$currentUsername = $env:USERNAME
$isaac_sim_dir = "C:\Users\$currentUsername\AppData\Local\ov\pkg\isaac_sim-*"

# Resolve the actual Isaac Sim directory by expanding the wildcard
$isaac_sim_dir = Resolve-Path $isaac_sim_dir | Select-Object -First 1

# Check if Isaac Sim directory exists
if (-not (Test-Path $isaac_sim_dir)) {
    Write-Host "Isaac Sim directory not found."
    exit
}

# Specific steps for Windows: copy orbit.sh and tasks.json
Write-Host "Copying orbit.sh and .vscode folder to the Orbit directory..."
Copy-Item "$parent_dir\automated_setup\orbit.sh" -Destination "$orbit_dir\orbit.sh" -Force
Copy-Item "$parent_dir\automated_setup\.vscode" -Destination "$orbit_dir\" -Recurse -Force

# Run Orbit commands via Git Bash
Write-Host "Running Orbit setup commands..." 
# Convert the Windows-style path to Unix-style for Git Bash
$unixStyleOrbitDir = $orbit_dir -replace '^C:', '/c' -replace '\\', '/'

Write-Host "Running Orbit setup commands..."
$gitBashPath = "C:\Program Files\Git\bin\bash.exe" # Ensure this path is correct for the system
& $gitBashPath -c "cd `"$unixStyleOrbitDir`"; ./orbit.sh -v; ./orbit.sh -i; ./orbit.sh -e rsl_rl; ./orbit.sh -p -m pip uninstall torch -y; ./orbit.sh -p -m pip install torch torchvision torchaudio --index-url https://download.pytorch../orbit.sh -p source/standalone/demos/quadrupeds.py"
