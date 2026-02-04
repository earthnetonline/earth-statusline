# earth-statusline installer (PowerShell)
# For Windows users
#
# Requires: Git, Windows Terminal (for colors)

$ErrorActionPreference = "Stop"

# Use proper path joining for Windows
$InstallDir = Join-Path $env:USERPROFILE ".earth-statusline"
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$StatuslineScript = Join-Path $ClaudeDir "statusline-command.ps1"

Write-Host "installing earth-statusline..." -ForegroundColor Cyan

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host ""
    Write-Host "PowerShell 5.0+ required. You have $($PSVersionTable.PSVersion)" -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Check for git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "git is required but not installed." -ForegroundColor Red
    Write-Host ""
    Write-Host "install it from: https://git-scm.com/download/win"
    Write-Host ""
    exit 1
}

# Warn about Windows Terminal
$wtInstalled = Get-Command wt -ErrorAction SilentlyContinue
if (-not $wtInstalled) {
    Write-Host ""
    Write-Host "warning: Windows Terminal not detected." -ForegroundColor Yellow
    Write-Host "colors may not display correctly in cmd.exe or old PowerShell."
    Write-Host "get it: https://aka.ms/terminal"
    Write-Host ""
}

# Clone or update
if (Test-Path $InstallDir) {
    Write-Host "updating existing installation..."
    Push-Location $InstallDir
    try {
        git pull
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Host "cloning to $InstallDir..."
    git clone https://github.com/earthnetonline/earth-statusline.git $InstallDir
}

# Create claude dir if needed
if (-not (Test-Path $ClaudeDir)) {
    New-Item -ItemType Directory -Path $ClaudeDir | Out-Null
}

# Copy script (symlinks require admin on Windows, so we copy instead)
$SourceScript = Join-Path $InstallDir "adapters\claude.ps1"
if (Test-Path $StatuslineScript) {
    Remove-Item $StatuslineScript -Force
}
Copy-Item $SourceScript $StatuslineScript
Write-Host "copied to $StatuslineScript"

# Determine which PowerShell to use in the command
$pwshPath = if (Get-Command pwsh -ErrorAction SilentlyContinue) { "pwsh" } else { "powershell" }

# Escape backslashes for JSON
$scriptPathJson = $StatuslineScript -replace '\\', '\\\\'

Write-Host ""
Write-Host "almost done. add this to $ClaudeDir\settings.json:" -ForegroundColor Yellow
Write-Host ""
Write-Host '{'
Write-Host '  "statusLine": {'
Write-Host '    "type": "command",'
Write-Host "    `"command`": `"$pwshPath -NoProfile -ExecutionPolicy Bypass -File \`"$scriptPathJson\`"`""
Write-Host '  }'
Write-Host '}'
Write-Host ""
Write-Host "then restart claude code. (°⩊°)" -ForegroundColor Green
Write-Host ""
