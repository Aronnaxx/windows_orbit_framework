# Check if CMake is installed and in the PATH
$cmakePath = Get-Command cmake -ErrorAction SilentlyContinue
if ($null -eq $cmakePath) {
    Write-Host "CMake is not found." -ForegroundColor Red
    $userChoice = Read-Host "Do you want to install CMake automatically? (Y for Yes, N for No, download manually)"
    if ($userChoice -eq 'Y') {
        # Check if Chocolatey is installed
        $chocoPath = Get-Command choco -ErrorAction SilentlyContinue
        if ($null -eq $chocoPath) {
            Write-Host "Chocolatey is not installed. Installing Chocolatey..." -ForegroundColor Yellow
            # Install Chocolatey
            Set-ExecutionPolicy Bypass -Scope Process -Force
            iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        }
        # Install CMake using Chocolatey
        Write-Host "Installing CMake using Chocolatey..." -ForegroundColor Yellow
        choco install cmake -y
    } elseif ($userChoice -eq 'N') {
        Write-Host "Please download and install CMake from https://cmake.org/download/ then rerun this script." -ForegroundColor Yellow
        exit
    } else {
        Write-Host "Invalid input. Exiting script." -ForegroundColor Red
        exit
    }
}

# Set Isaac Sim directory
$currentUsername = $env:USERNAME
$isaac_sim_dir = "C:\Users\$currentUsername\AppData\Local\ov\pkg\isaac_sim-*"

# Determine the directories based on script location
# Get the current script's directory
$script_dir = Split-Path $script:MyInvocation.MyCommand.Path
# Get the 'automated_setup' directory
$automated_setup_dir = $script_dir
# Get the parent directory of 'automated_setup', which will also be the parent for 'orbit'
$parent_dir = Split-Path $automated_setup_dir
# Define the path for the 'orbit' directory, which should be a sibling to 'automated_setup'
$orbit_dir = Join-Path $parent_dir "orbit"

# Clone Orbit if it doesn't exist and switch to the latest release
if (-not (Test-Path $orbit_dir)) {
    Write-Host "Orbit directory not found. Cloning..."
    git clone https://github.com/NVIDIA-Omniverse/Orbit.git $orbit_dir
    Push-Location $orbit_dir
    git fetch --tags
    $latest_tag = git describe --tags $(git rev-list --tags --max-count=1)
    git checkout $latest_tag
    Pop-Location
} else {
    Write-Host "Orbit directory found."
}

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


# Replace symlink creation section with this
$process = Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\\create-symlinks.ps1`" $scriptParams" -Verb RunAs -PassThru
$process.WaitForExit()

# Check if the script was successful
if ($process.ExitCode -eq 0) {
    Write-Host "Symlinks created successfully."
    # Continue with the rest of the script
} else {
    Write-Host "Failed to create symlinks. Exit code: $($process.ExitCode)" -ForegroundColor Red
    exit
}

# Run Orbit commands via Git Bash
Write-Host "Running Orbit setup commands..."
# Convert the Windows-style path to Unix-style for Git Bash
$unixStyleOrbitDir = $orbit_dir -replace '^C:', '/c' -replace '\\', '/'

Start-Process "https://isaac-orbit.github.io/orbit/source/setup/developer.html"

Write-Host "Running Orbit setup commands..."
$gitBashPath = "C:\Program Files\Git\bin\bash.exe" # Ensure this path is correct for the system
& $gitBashPath -c "cd `"$unixStyleOrbitDir`"; ./orbit.sh -v; ./orbit.sh -i; ./orbit.sh -e rsl_rl; ./orbit.sh -p -m pip uninstall torch -y; ./orbit.sh -p -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118; ./orbit.sh -p source/standalone/demos/quadrupeds.py"


