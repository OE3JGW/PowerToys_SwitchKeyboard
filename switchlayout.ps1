# Determine the path of the current script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

# PowerToys configuration files relative to the script directory
$homeOfficeConfig = Join-Path $scriptDirectory "standard.json"
$officeConfig = Join-Path $scriptDirectory "OfficeConfig.json"

# Target path for the active configuration file
$powerToysConfigPath = Join-Path $env:LOCALAPPDATA "Microsoft\PowerToys\Keyboard Manager\default.json"

# Selection menu for the environment
$menu = @"
Choose your location for keyboard config setup:
1. Default
2. Office (keychron k4)
"@

Write-Host $menu

# Wait for a key press without needing to press Enter
$choice = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character

switch ($choice) {
    "1" {
        Write-Host "Default selected. Copying configuration..."
        Copy-Item -Path $homeOfficeConfig -Destination $powerToysConfigPath -Force
    }
    "2" {
        Write-Host "Office selected. Copying configuration..."
        Copy-Item -Path $officeConfig -Destination $powerToysConfigPath -Force
    }
    default {
        Write-Host "Invalid selection. Default configuration will be used."
        Copy-Item -Path $homeOfficeConfig -Destination $powerToysConfigPath -Force
    }
}

# Function to dynamically find PowerToys installation path
function Get-PowerToysPath {
    # Check the registry for PowerToys installation path
    try {
        $installPath = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\PowerToys" -ErrorAction Stop).InstallLocation
        if (-not [string]::IsNullOrEmpty($installPath)) {
            return $installPath
        }
    } catch {
        Write-Host "PowerToys registry entry not found."
    }

    # Check in LOCALAPPDATA as the user-specific installation location
    $localAppDataPath = Join-Path $env:LOCALAPPDATA "PowerToys"
    if (Test-Path (Join-Path $localAppDataPath "PowerToys.exe")) {
        return $localAppDataPath
    }

    # Common installation paths
    $commonPaths = @(
        "$env:LOCALAPPDATA\Microsoft\PowerToys",
        "C:\Program Files\PowerToys",
        "C:\Program Files (x86)\PowerToys"
    )

    # Check each common path
    foreach ($path in $commonPaths) {
        $exePath = Join-Path $path "PowerToys.exe"
        if (Test-Path $exePath) {
            return $path
        }
    }

    throw "PowerToys installation not found on the system."
}

# Restart PowerToys
try {
    Stop-Process -Name "PowerToys" -ErrorAction Stop
    Write-Host "PowerToys process stopped successfully."
} catch {
    Write-Host "PowerToys process is not running, no restart needed."
}

# Get dynamic PowerToys path and start it
try {
    $powerToysPath = Join-Path (Get-PowerToysPath) "PowerToys.exe"
    Write-Host "Starting PowerToys from: $powerToysPath"
    Start-Process $powerToysPath
} catch {
    Write-Host "Error: PowerToys installation could not be found. Please verify your installation."
}