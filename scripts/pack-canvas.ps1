param(
  [ValidateSet('pack','unpack')]
  [string]$Action = 'pack',
  [string]$MsApp = "$PSScriptRoot/../dist/AgileMaturityApp.msapp",
  [string]$Source = "$PSScriptRoot/../"
)

$ErrorActionPreference = 'Stop'

Write-Host "Power Platform CLI canvas $Action" -ForegroundColor Cyan

function Assert-Pac {
  if (-not (Get-Command pac -ErrorAction SilentlyContinue)) {
    throw "'pac' CLI not found. Install with: winget install Microsoft.PowerApps.CLI or see aka.ms/PowerAppsCLI"
  }
}

Assert-Pac

New-Item -ItemType Directory -Path (Split-Path -Parent $MsApp) -ErrorAction SilentlyContinue | Out-Null

switch ($Action) {
  'pack' {
    Write-Host "Packing from: $Source" -ForegroundColor Yellow
    pac canvas pack --sources $Source --msapp $MsApp
    if (Test-Path $MsApp) {
      Write-Host "Created: $MsApp" -ForegroundColor Green
    } else {
      Write-Host "Pack reported an error. No file created at: $MsApp" -ForegroundColor Red
      Write-Host "See pac log at: $env:LOCALAPPDATA\Microsoft\PowerAppsCli\*\tools\logs\pac-log.txt" -ForegroundColor Yellow
      exit 1
    }
  }
  'unpack' {
    Write-Host "Unpacking: $MsApp" -ForegroundColor Yellow
    pac canvas unpack --msapp $MsApp --sources $Source
    Write-Host "Wrote sources to: $Source" -ForegroundColor Green
  }
}
