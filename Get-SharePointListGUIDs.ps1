# Get-SharePointListGUIDs.ps1
# Script to retrieve SharePoint List GUIDs from your personal SharePoint site

param(
    [Parameter(Mandatory=$false)]
    [string]$SiteUrl = "https://speridiantec-my.sharepoint.com/personal/sandeep_varma_speridian_com"
)

Write-Host "=== SharePoint List GUID Extractor ===" -ForegroundColor Green
Write-Host "Site: $SiteUrl" -ForegroundColor Cyan
Write-Host ""

$listNames = @(
    "AssessmentHistory",
    "AssessmentRatings", 
    "Assessments",
    "Dimensions",
    "Statements",
    "SubDimensions",
    "Teams",
    "Verticals",
    "AppRoles"
)

Write-Host "Expected SharePoint Lists:" -ForegroundColor Yellow
foreach ($listName in $listNames) {
    Write-Host "  - $listName" -ForegroundColor White
}
Write-Host ""

Write-Host "To get the List GUIDs, you have several options:" -ForegroundColor Yellow
Write-Host ""

Write-Host "OPTION 1 - Manual Method (Recommended):" -ForegroundColor Cyan
Write-Host "1. Go to your SharePoint site: $SiteUrl" -ForegroundColor White
Write-Host "2. For each list above:" -ForegroundColor White
Write-Host "   a. Click on the list name" -ForegroundColor White
Write-Host "   b. Click the Settings gear → List settings" -ForegroundColor White
Write-Host "   c. Look at the URL in the browser address bar" -ForegroundColor White
Write-Host "   d. Copy the GUID after 'List=' (it looks like: 12345678-1234-1234-1234-123456789abc)" -ForegroundColor White
Write-Host "   e. Note it down for each list" -ForegroundColor White
Write-Host ""

Write-Host "OPTION 2 - PowerShell with PnP (if you have PnP PowerShell installed):" -ForegroundColor Cyan
Write-Host "Run these commands:" -ForegroundColor White
Write-Host "Install-Module -Name PnP.PowerShell -Scope CurrentUser" -ForegroundColor Gray
Write-Host "Connect-PnPOnline -Url '$SiteUrl' -Interactive" -ForegroundColor Gray
foreach ($listName in $listNames) {
    Write-Host "Get-PnPList -Identity '$listName' | Select Title, Id" -ForegroundColor Gray
}
Write-Host ""

Write-Host "OPTION 3 - REST API Method:" -ForegroundColor Cyan
Write-Host "Visit these URLs in your browser (you'll need to be logged into SharePoint):" -ForegroundColor White
foreach ($listName in $listNames) {
    Write-Host "$SiteUrl/_api/web/lists/getbytitle('$listName')?`$select=Id,Title" -ForegroundColor Gray
}
Write-Host ""

Write-Host "After you get the GUIDs, update the deployment-config.json file:" -ForegroundColor Yellow
Write-Host "Or run: .\Update-ListGUIDs.ps1 -ListGUIDs @{'ListName'='GUID'; ...}" -ForegroundColor White
Write-Host ""

# Create a template file for easy copying
$templateContent = @"
# SharePoint List GUIDs Template
# Copy your actual GUIDs here and then run Update-ListGUIDs.ps1

`$ListGUIDs = @{
    'AssessmentHistory' = 'YOUR-GUID-HERE'
    'AssessmentRatings' = 'YOUR-GUID-HERE'
    'Assessments' = 'YOUR-GUID-HERE'
    'Dimensions' = 'YOUR-GUID-HERE'
    'Statements' = 'YOUR-GUID-HERE'
    'SubDimensions' = 'YOUR-GUID-HERE'
    'Teams' = 'YOUR-GUID-HERE'
    'Verticals' = 'YOUR-GUID-HERE'
}

# Then run:
# .\Update-ListGUIDs.ps1 -ListGUIDs `$ListGUIDs
"@

Set-Content -Path "SharePointListGUIDs-Template.ps1" -Value $templateContent -Encoding UTF8
Write-Host "Created 'SharePointListGUIDs-Template.ps1' for your convenience!" -ForegroundColor Green
