# earth-statusline installer (PowerShell)
# For Windows users

$ErrorActionPreference = "Stop"

$InstallDir = "$env:USERPROFILE\.earth-statusline"
$ClaudeDir = "$env:USERPROFILE\.claude"
$StatuslineScript = "$ClaudeDir\statusline-command.ps1"

Write-Host "installing earth-statusline..." -ForegroundColor Cyan

# Check for git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "git is required but not installed." -ForegroundColor Red
    Write-Host ""
    Write-Host "install it from: https://git-scm.com/download/win"
    Write-Host ""
    exit 1
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
$SourceScript = "$InstallDir\adapters\claude.ps1"
if (Test-Path $StatuslineScript) {
    Remove-Item $StatuslineScript -Force
}
Copy-Item $SourceScript $StatuslineScript
Write-Host "copied to $StatuslineScript"

Write-Host ""
Write-Host "almost done. add this to $ClaudeDir\settings.json:" -ForegroundColor Yellow
Write-Host ""
Write-Host '  {'
Write-Host '    "statusLine": {'
Write-Host '      "type": "command",'
Write-Host "      `"command`": `"pwsh -NoProfile -File '$StatuslineScript'`""
Write-Host '    }'
Write-Host '  }'
Write-Host ""
Write-Host "then restart claude code. (°⩊°)" -ForegroundColor Green
Write-Host ""
