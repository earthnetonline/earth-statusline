# Earth Status Line - Claude Code Adapter (PowerShell)
# Statusline for Claude Code CLI on Windows
#
# Line 1: Repo/code context
# Line 2: Session/context info
#
# Requires: Windows Terminal (for ANSI colors), Git

$ErrorActionPreference = "SilentlyContinue"

# ESC character - compatible with PowerShell 5.1+
$script:ESC = [char]27

# ANSI color codes (Windows Terminal supports these)
$script:C_DIR = "$ESC[38;2;136;136;136m"
$script:C_BRANCH = "$ESC[38;2;122;130;118m"
$script:C_ADD = "$ESC[38;2;122;130;118m"
$script:C_DEL = "$ESC[38;2;140;130;130m"
$script:C_MODEL = "$ESC[38;2;85;85;85m"
$script:C_TOKENS = "$ESC[38;2;152;136;184m"
$script:C_CTX_GOOD = "$ESC[38;2;136;168;128m"
$script:C_CTX_WARN = "$ESC[38;2;168;152;104m"
$script:C_CTX_BAD = "$ESC[38;2;168;114;104m"
$script:C_DIM = "$ESC[38;2;102;102;102m"
$script:C_STAGED = "$ESC[38;2;136;152;176m"
$script:C_RESET = "$ESC[0m"

# Claude auto-compacts context around 22% remaining
$script:AUTOCOMPACT_THRESHOLD = 22

function Format-Tokens {
    param([long]$tokens = 0)

    if ($tokens -ge 1000000) {
        return "{0:F1}M" -f ($tokens / 1000000)
    }
    elseif ($tokens -ge 1000) {
        return "{0:F1}k" -f ($tokens / 1000)
    }
    else {
        return $tokens.ToString()
    }
}

function Get-MoodKaomoji {
    param([int]$remaining)

    if ($remaining -gt 50) {
        return "(°⩊°)"  # chill
    }
    elseif ($remaining -gt 20) {
        return "(>⩊<)"  # neutral
    }
    else {
        return "(×⩊×)"  # not chill
    }
}

function Get-ContextColor {
    param([int]$remaining)

    if ($remaining -gt 50) {
        return $script:C_CTX_GOOD
    }
    elseif ($remaining -gt 20) {
        return $script:C_CTX_WARN
    }
    else {
        return $script:C_CTX_BAD
    }
}

function Get-GitInfo {
    param([string]$dir)

    $result = @{
        Branch = ""
        LinesAdded = 0
        LinesRemoved = 0
        StagedAdded = 0
        StagedRemoved = 0
    }

    if (-not (Test-Path $dir)) {
        return $result
    }

    Push-Location $dir
    try {
        # Check if we're in a git repo
        $null = git rev-parse --git-dir 2>$null
        if ($LASTEXITCODE -ne 0) {
            return $result
        }

        # Get branch
        $result.Branch = git branch --show-current 2>$null

        # Unstaged changes
        $diffStats = git diff --shortstat 2>$null
        if ($diffStats) {
            if ($diffStats -match '(\d+) insertion') {
                $result.LinesAdded = [int]$Matches[1]
            }
            if ($diffStats -match '(\d+) deletion') {
                $result.LinesRemoved = [int]$Matches[1]
            }
        }

        # Staged changes
        $stagedStats = git diff --staged --shortstat 2>$null
        if ($stagedStats) {
            if ($stagedStats -match '(\d+) insertion') {
                $result.StagedAdded = [int]$Matches[1]
            }
            if ($stagedStats -match '(\d+) deletion') {
                $result.StagedRemoved = [int]$Matches[1]
            }
        }
    }
    catch {
        # Silently ignore git errors
    }
    finally {
        Pop-Location
    }

    return $result
}

# Read JSON input from stdin
try {
    $inputJson = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($inputJson)) {
        Write-Output ""
        exit 0
    }
    $data = $inputJson | ConvertFrom-Json
}
catch {
    # If reading or JSON parsing fails, output empty and exit
    Write-Output ""
    exit 0
}

# Extract data with safe defaults
$dir = if ($data.workspace.current_dir) { $data.workspace.current_dir } else { "" }
$dirName = if ($dir) { Split-Path $dir -Leaf } else { "" }
$model = if ($data.model.display_name) { $data.model.display_name }
         elseif ($data.model.id) { $data.model.id }
         else { "unknown" }
$totalInput = if ($data.context_window.total_input_tokens) { [long]$data.context_window.total_input_tokens } else { 0 }
$totalOutput = if ($data.context_window.total_output_tokens) { [long]$data.context_window.total_output_tokens } else { 0 }

# Get git info
$gitInfo = Get-GitInfo -dir $dir

# Context window calculation
$ctx = ""
$ctxColor = ""
$kaomoji = ""

if ($data.context_window.current_usage) {
    $usage = $data.context_window.current_usage
    $inputTokens = if ($usage.input_tokens) { [long]$usage.input_tokens } else { 0 }
    $cacheCreation = if ($usage.cache_creation_input_tokens) { [long]$usage.cache_creation_input_tokens } else { 0 }
    $cacheRead = if ($usage.cache_read_input_tokens) { [long]$usage.cache_read_input_tokens } else { 0 }
    $current = $inputTokens + $cacheCreation + $cacheRead

    $size = if ($data.context_window.context_window_size) { [long]$data.context_window.context_window_size } else { 1 }
    if ($size -eq 0) { $size = 1 }

    $remaining = 100 - [int]($current * 100 / $size)

    # Normalize against auto-compact threshold
    $effectiveRemaining = [int](($remaining - $script:AUTOCOMPACT_THRESHOLD) * 100 / (100 - $script:AUTOCOMPACT_THRESHOLD))
    if ($effectiveRemaining -lt 0) { $effectiveRemaining = 0 }

    $ctxColor = Get-ContextColor -remaining $effectiveRemaining
    $ctx = "$remaining%"
    $kaomoji = Get-MoodKaomoji -remaining $effectiveRemaining
}

# Format tokens
$inputFmt = Format-Tokens -tokens $totalInput
$outputFmt = Format-Tokens -tokens $totalOutput

# Build Line 1: Repo/Code
$line1 = "$($script:C_DIR)$dirName$($script:C_RESET)"

if ($gitInfo.Branch) {
    $line1 += " $($script:C_DIM)>$($script:C_RESET) $($script:C_BRANCH)$($gitInfo.Branch)$($script:C_RESET)"
}

if ($gitInfo.StagedAdded -ne 0 -or $gitInfo.StagedRemoved -ne 0) {
    $line1 += " $($script:C_DIM)|$($script:C_RESET) $($script:C_STAGED)●+$($gitInfo.StagedAdded) -$($gitInfo.StagedRemoved)$($script:C_RESET)"
}

if ($gitInfo.LinesAdded -ne 0 -or $gitInfo.LinesRemoved -ne 0) {
    $line1 += " $($script:C_DIM)|$($script:C_RESET) $($script:C_ADD)+$($gitInfo.LinesAdded)$($script:C_RESET) $($script:C_DEL)-$($gitInfo.LinesRemoved)$($script:C_RESET)"
}

# Build Line 2: Context/Session
$line2 = "$($script:C_MODEL)$model$($script:C_RESET)"

if ($ctx) {
    $line2 += " $($script:C_DIM)|$($script:C_RESET) $ctxColor$kaomoji $ctx$($script:C_RESET)"
}

if ($totalInput -ne 0 -or $totalOutput -ne 0) {
    $line2 += " $($script:C_DIM)|$($script:C_RESET) $($script:C_TOKENS)↓$inputFmt$($script:C_RESET) $($script:C_DIM)/$($script:C_RESET) $($script:C_TOKENS)↑$outputFmt$($script:C_RESET)"
}

# Output with blank line separator
Write-Output "$line1`n`n$line2"
