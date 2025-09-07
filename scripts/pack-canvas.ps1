param(
  [ValidateSet('pack','unpack')]
  [string]$Action = 'pack',
  [string]$MsApp = "$PSScriptRoot/../dist/AgileMaturityApp.msapp",
  [string]$Stage = "$PSScriptRoot/../stage-pack",
  [string]$UnpackTarget = "$PSScriptRoot/../"
)

$ErrorActionPreference = 'Stop'

function Assert-Pac {
  if (-not (Get-Command pac -ErrorAction SilentlyContinue)) {
    throw "'pac' CLI not found. Install via: winget install Microsoft.PowerApps.CLI or MSI from https://aka.ms/PowerAppsCLI"
  }
}

function New-EmptyDir([string]$Path) {
  if (Test-Path -LiteralPath $Path) {
    Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
  }
  New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

function Copy-IfExists([string]$From, [string]$To) {
  if (Test-Path -LiteralPath $From) {
    $parent = Split-Path -Parent $To
    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    Copy-Item -LiteralPath $From -Destination $To -Recurse -Force
  }
}

Write-Host "Power Platform CLI canvas $Action" -ForegroundColor Cyan
Assert-Pac

switch ($Action) {
  'pack' {
    # Prepare clean stage directory
    Write-Host "Preparing stage: $Stage" -ForegroundColor Yellow
    New-EmptyDir -Path $Stage

    # Copy only the minimal, canonical sources
    $root = Resolve-Path "$PSScriptRoot/.." | Select-Object -ExpandProperty Path
    Copy-IfExists -From (Join-Path $root 'Src') -To (Join-Path $Stage 'Src')
    Copy-IfExists -From (Join-Path $root 'Assets') -To (Join-Path $Stage 'Assets')
    Copy-IfExists -From (Join-Path $root 'pkgs') -To (Join-Path $Stage 'pkgs')
    Copy-IfExists -From (Join-Path $root 'CanvasManifest.json') -To (Join-Path $Stage 'CanvasManifest.json')
    Copy-IfExists -From (Join-Path $root 'ComponentReferences.json') -To (Join-Path $Stage 'ComponentReferences.json')
    Copy-IfExists -From (Join-Path $root 'ControlTemplates.json') -To (Join-Path $Stage 'ControlTemplates.json')

    # Optional: include legacy PA YAML sources if available (can help packer)
    $otherCandidates = @()
    $otherCandidates += (Join-Path $root 'Other')
    $archDir = Join-Path $root 'archive'
    if (Test-Path -LiteralPath $archDir) {
      $latestArch = Get-ChildItem $archDir -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
      if ($latestArch) { $otherCandidates += (Join-Path $latestArch.FullName 'Other') }
    }
    foreach ($cand in $otherCandidates) {
      if (Test-Path -LiteralPath $cand) {
        Copy-IfExists -From $cand -To (Join-Path $Stage 'Other')
        break
      }
    }

    # Ensure output directory exists (avoid Resolve-Path on non-existing dirs)
    $msappDir = Split-Path -Path $MsApp -Parent
    if (-not [string]::IsNullOrWhiteSpace($msappDir) -and -not (Test-Path -LiteralPath $msappDir)) {
      New-Item -ItemType Directory -Path $msappDir -Force | Out-Null
    }

    Write-Host "Packing from: $Stage" -ForegroundColor Yellow
    pac canvas pack --sources $Stage --msapp $MsApp
    if (Test-Path -LiteralPath $MsApp) {
      Write-Host "Created: $MsApp" -ForegroundColor Green
      exit 0
    } else {
      Write-Host "Pack failed: msapp not created at $MsApp" -ForegroundColor Red
      Write-Host "Check pac log: $env:LOCALAPPDATA\Microsoft\PowerAppsCli\*\tools\logs\pac-log.txt" -ForegroundColor DarkYellow
      exit 1
    }
  }
  'unpack' {
    if (-not (Test-Path -LiteralPath $MsApp)) {
      throw "MSApp not found: $MsApp"
    }
    if (-not (Test-Path -LiteralPath $UnpackTarget)) {
      New-Item -ItemType Directory -Path $UnpackTarget -Force | Out-Null
    }
    Write-Host "Unpacking: $MsApp -> $UnpackTarget" -ForegroundColor Yellow
    pac canvas unpack --msapp $MsApp --sources $UnpackTarget
    Write-Host "Unpacked to: $UnpackTarget" -ForegroundColor Green
  }
}
