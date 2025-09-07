# Update-Connections.ps1
# Script to update Power Apps connections for deployment to a different organization

param(
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "deployment-config.json"
)

Write-Host "=== Agile Maturity Assessment App - Connection Updater ===" -ForegroundColor Green
Write-Host ""

# Check if config file exists
if (-not (Test-Path $ConfigFile)) {
    Write-Error "Configuration file '$ConfigFile' not found!"
    exit 1
}

# Read configuration
Write-Host "Reading configuration from $ConfigFile..." -ForegroundColor Yellow
$config = Get-Content $ConfigFile | ConvertFrom-Json

$newSharePointUrl = $config.organization.sharePointSiteUrl
$newSharePointPath = $config.organization.sharePointListsPath
$fullSharePointUrl = "$newSharePointUrl/$newSharePointPath"

Write-Host "Organization: $($config.organization.name)" -ForegroundColor Cyan
Write-Host "SharePoint Site: $newSharePointUrl" -ForegroundColor Cyan
Write-Host "Admin Emails: $($config.organization.adminEmails -join ', ')" -ForegroundColor Cyan
Write-Host ""

# Update App.fx.yaml with new configuration
Write-Host "Updating App.fx.yaml with new configuration..." -ForegroundColor Yellow
$appFilePath = "Src\App.fx.yaml"
$appContent = Get-Content $appFilePath -Raw

# Update SharePoint URL
$appContent = $appContent -replace 'Set\(gblSharePointSiteUrl, "[^"]+"\)', "Set(gblSharePointSiteUrl, `"$newSharePointUrl`")"
$appContent = $appContent -replace 'Set\(gblSharePointListsPath, "[^"]+"\)', "Set(gblSharePointListsPath, `"$newSharePointPath`")"

# Update admin emails
$adminEmailsJson = ($config.organization.adminEmails | ForEach-Object { "`"$_`"" }) -join ', '
$appContent = $appContent -replace 'Set\(gblAdminEmails, \[[^\]]+\]\)', "Set(gblAdminEmails, [$adminEmailsJson])"

Set-Content $appFilePath $appContent -Encoding UTF8
Write-Host "✓ Updated App.fx.yaml" -ForegroundColor Green

# Update Connections.json
Write-Host "Updating Connections.json..." -ForegroundColor Yellow
$connectionsPath = "Connections\Connections.json"
$connectionsContent = Get-Content $connectionsPath -Raw
$connectionsContent = $connectionsContent -replace 'https://[^/]+\.sharepoint\.com[^"]*', $fullSharePointUrl
Set-Content $connectionsPath $connectionsContent -Encoding UTF8
Write-Host "✓ Updated Connections.json" -ForegroundColor Green

# Update DataSource files
Write-Host "Updating DataSource files..." -ForegroundColor Yellow
$dataSourceFiles = Get-ChildItem "DataSources\*.json"
foreach ($file in $dataSourceFiles) {
    $content = Get-Content $file.FullName -Raw
    $content = $content -replace 'https://[^/]+\.sharepoint\.com[^"]*', $fullSharePointUrl
    Set-Content $file.FullName $content -Encoding UTF8
}
Write-Host "✓ Updated $($dataSourceFiles.Count) DataSource files" -ForegroundColor Green

# Update TableDefinitions
Write-Host "Updating TableDefinitions..." -ForegroundColor Yellow
$tableDefFiles = Get-ChildItem "pkgs\TableDefinitions\*.json"
foreach ($file in $tableDefFiles) {
    $content = Get-Content $file.FullName -Raw
    $content = $content -replace 'https://[^/]+\.sharepoint\.com[^"]*', $fullSharePointUrl
    Set-Content $file.FullName $content -Encoding UTF8
}
Write-Host "✓ Updated $($tableDefFiles.Count) TableDefinition files" -ForegroundColor Green

Write-Host ""
Write-Host "=== Connection Update Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: After making these changes, you will need to:" -ForegroundColor Yellow
Write-Host "1. Import the app into the new Power Platform environment" -ForegroundColor White
Write-Host "2. Reconnect to SharePoint (connections will need to be re-authorized)" -ForegroundColor White
Write-Host "3. Ensure the SharePoint lists exist with the same structure" -ForegroundColor White
Write-Host "4. Test the application functionality" -ForegroundColor White
Write-Host ""
Write-Host "See DEPLOYMENT-INSTRUCTIONS.md for detailed deployment steps." -ForegroundColor Cyan