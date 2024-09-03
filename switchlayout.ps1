# Determine the path of the current script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

# PowerToys configuration files relative to the script directory
$homeOfficeConfig = Join-Path $scriptDirectory "standard.json"
$officeConfig = Join-Path $scriptDirectory "OfficeConfig.json"

# Target path for the active configuration file
$powerToysConfigPath = "$env:LOCALAPPDATA\Microsoft\PowerToys\Keyboard Manager\default.json"

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
        Write-Host "`nDefault selected. Copying configuration..."
        Copy-Item -Path $homeOfficeConfig -Destination $powerToysConfigPath -Force
    }
    "2" {
        Write-Host "`nOffice selected. Copying configuration..."
        Copy-Item -Path $officeConfig -Destination $powerToysConfigPath -Force
    }
    default {
        Write-Host "`nInvalid selection. Default configuration will be used."
        Copy-Item -Path $homeOfficeConfig -Destination $powerToysConfigPath -Force
    }
}

# Restart PowerToys
try {
    Stop-Process -Name "PowerToys" -ErrorAction Stop
    Write-Host "PowerToys process stopped successfully."
} catch {
    Write-Host "PowerToys process is not running, no restart needed."
}

Write-Host "Starting PowerToys..."
Start-Process "C:\Program Files\PowerToys\PowerToys.exe"
