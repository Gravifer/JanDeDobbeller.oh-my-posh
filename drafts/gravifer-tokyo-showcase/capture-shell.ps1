[CmdletBinding()]
param(
    [string]$ThemePath = "$env:USERPROFILE\.config\oh-my-posh\gravifer-tokyo.omp.json",
    [string]$HelperPath = "$env:USERPROFILE\.config\oh-my-posh\gravifer-tokyo.context.ps1"
)

$ErrorActionPreference = 'Stop'

foreach ($requiredFile in @($ThemePath, $HelperPath)) {
    if (-not [System.IO.File]::Exists($requiredFile)) {
        throw "Required showcase file not found: $requiredFile"
    }
}

# This script is intended to run in a disposable `pwsh -NoLogo -NoProfile`
# child process. Every environment change below is process-scoped.
$cleanPath = @(
    "$env:LOCALAPPDATA\Programs\oh-my-posh\bin"
    "$env:ProgramFiles\Git\cmd"
    "$env:USERPROFILE\.cargo\bin"
    "$env:SystemRoot\System32"
    $env:SystemRoot
) | Where-Object { [System.IO.Directory]::Exists($_) } | Select-Object -Unique

$env:PATH = $cleanPath -join ';'
$env:USER = 'user'
$env:USERNAME = 'user'
$env:GRAVIFER_CAPTURE_USER = 'user'
$env:GRAVIFER_CAPTURE_HOST = 'MACHINE'

$captureConfig = Join-Path $PSScriptRoot 'capture.omp.json'
$showcaseRoot = 'D:\tests\vsc_repos\gravifer-tokyo-showcase'
$captureRoot = Join-Path $showcaseRoot 'captures'
$env:OMP_CACHE_DIR = Join-Path $showcaseRoot '.omp-cache'
New-Item -ItemType Directory -Path $env:OMP_CACHE_DIR -Force | Out-Null

$global:GraviferShowcasePaths = [ordered]@{
    'git-only' = Join-Path $showcaseRoot '01-git-only\atlas-repository\packages\platform\services\authentication'
    'jj-only' = Join-Path $showcaseRoot '02-jj-only\nebula-workspace\components\prompt\renderer'
    'git-and-jj' = Join-Path $showcaseRoot '03-git-and-jj\orion-monorepo\packages\shell\windows\integration'
    'linked-worktree' = Join-Path $showcaseRoot '04-linked-worktree\feature-worktree\src\prompt\segments\path'
}

function global:Enter-GraviferShowcase {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('git-only', 'jj-only', 'git-and-jj', 'linked-worktree')]
        [string]$Scenario
    )

    Set-Location -LiteralPath $global:GraviferShowcasePaths[$Scenario]
    Set-PoshContext $true
}

function global:Export-GraviferShowcase {
    New-Item -ItemType Directory -Path $captureRoot -Force | Out-Null

    foreach ($scenario in $global:GraviferShowcasePaths.GetEnumerator()) {
        Enter-GraviferShowcase -Scenario $scenario.Key

        $dataPath = Join-Path $captureRoot "$($scenario.Key).data.json"
        $imagePath = Join-Path $captureRoot "$($scenario.Key).png"

        oh-my-posh config export data `
            --config $captureConfig `
            --output $dataPath
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to record template data for $($scenario.Key)"
        }

        oh-my-posh config export image `
            --config $captureConfig `
            --data $dataPath `
            --terminal-width 120 `
            --output $imagePath
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to export image for $($scenario.Key)"
        }
    }
}

oh-my-posh init pwsh --config $captureConfig | Invoke-Expression
. $HelperPath

Enter-GraviferShowcase -Scenario 'git-and-jj'

Write-Host ''
Write-Host 'Sanitized Gravifer Tokyo capture shell is ready.'
Write-Host 'Account/host display: user :: MACHINE'
Write-Host 'Available paths:'
$global:GraviferShowcasePaths.GetEnumerator() |
    ForEach-Object { Write-Host "  $($_.Key): $($_.Value)" }
Write-Host ''
Write-Host 'Use Enter-GraviferShowcase <name> for manual screenshots.'
Write-Host 'Use Export-GraviferShowcase to record data and export all four PNGs.'
