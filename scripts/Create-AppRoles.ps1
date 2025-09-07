param(
  [Parameter(Mandatory=$true)]
  [string]$SiteUrl
)

$ErrorActionPreference = 'Stop'

Write-Host "=== Create AppRoles list ===" -ForegroundColor Green
Write-Host "Site: $SiteUrl" -ForegroundColor Cyan

if (-not (Get-Command Connect-PnPOnline -ErrorAction SilentlyContinue)) {
  Write-Host "Installing PnP.PowerShell (current user)..." -ForegroundColor Yellow
  Install-Module PnP.PowerShell -Scope CurrentUser -Force
}

Connect-PnPOnline -Url $SiteUrl -Interactive

# Create list if missing
$list = Get-PnPList -Identity 'AppRoles' -ErrorAction SilentlyContinue
if (-not $list) {
  Write-Host "Creating list 'AppRoles'..." -ForegroundColor Yellow
  New-PnPList -Title 'AppRoles' -Template GenericList -OnQuickLaunch:$true | Out-Null
}

# Ensure columns
Write-Host "Ensuring columns..." -ForegroundColor Yellow

# User (Person)
if (-not (Get-PnPField -List 'AppRoles' -Identity 'User' -ErrorAction SilentlyContinue)) {
  Add-PnPField -List 'AppRoles' -DisplayName 'User' -InternalName 'User' -Type User -AddToDefaultView | Out-Null
}

# Role (Choice)
if (-not (Get-PnPField -List 'AppRoles' -Identity 'Role' -ErrorAction SilentlyContinue)) {
  Add-PnPField -List 'AppRoles' -DisplayName 'Role' -InternalName 'Role' -Type Choice -Choices @('Admin','Assessor') -AddToDefaultView | Out-Null
}

Write-Host "AppRoles ready." -ForegroundColor Green

Write-Host "Optionally add a role example:" -ForegroundColor Yellow
Write-Host "Add-PnPListItem -List AppRoles -Values @{ Title='admin@contoso.com'; Role='Admin'; User='admin@contoso.com' }" -ForegroundColor Gray

