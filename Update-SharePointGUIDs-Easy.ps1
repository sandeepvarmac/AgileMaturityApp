# Update-SharePointGUIDs-Easy.ps1
# Simplified script for updating SharePoint List GUIDs during migration

param(
    [Parameter(Mandatory=$false)]
    [string]$NewOrganizationSite = "",
    [Parameter(Mandatory=$false)]
    [hashtable]$ListGUIDs = @{},
    [Parameter(Mandatory=$false)]
    [switch]$Interactive
)

Write-Host "=== Easy SharePoint GUID Updater for Migration ===" -ForegroundColor Green
Write-Host ""

if ($Interactive -or $ListGUIDs.Count -eq 0) {
    Write-Host "INTERACTIVE MODE: Enter your SharePoint List GUIDs" -ForegroundColor Yellow
    Write-Host "You can get these from SharePoint List Settings → copy GUID from URL after 'List='" -ForegroundColor Cyan
    Write-Host "Or use the REST API URLs provided in the documentation." -ForegroundColor Cyan
    Write-Host ""
    
    $requiredLists = @('AssessmentHistory', 'AssessmentRatings', 'Assessments', 'Dimensions', 'Statements', 'SubDimensions', 'Teams', 'Verticals')
    $ListGUIDs = @{}
    
    foreach ($listName in $requiredLists) {
        do {
            $guid = Read-Host "Enter GUID for '$listName' list (without curly braces)"
            if ($guid -match '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') {
                $ListGUIDs[$listName] = $guid.ToLower()
                Write-Host "✓ Valid GUID for $listName" -ForegroundColor Green
                break
            } else {
                Write-Host "❌ Invalid GUID format. Please enter in format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -ForegroundColor Red
            }
        } while ($true)
    }
}

if ($NewOrganizationSite -ne "") {
    Write-Host "Updating SharePoint site URL to: $NewOrganizationSite" -ForegroundColor Yellow
    
    # Update deployment config
    $configPath = "deployment-config.json"
    $config = Get-Content $configPath | ConvertFrom-Json
    $config.organization.sharePointSiteUrl = $NewOrganizationSite
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
    
    # Run connection update script
    .\Update-Connections.ps1
}

if ($ListGUIDs.Count -gt 0) {
    Write-Host "Updating SharePoint List GUIDs..." -ForegroundColor Yellow
    .\Update-ListGUIDs.ps1 -ListGUIDs $ListGUIDs
}

Write-Host ""
Write-Host "=== Migration Update Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Summary of current configuration:" -ForegroundColor Yellow

# Show current config
$currentConfig = Get-Content "deployment-config.json" | ConvertFrom-Json
Write-Host "Organization: $($currentConfig.organization.name)" -ForegroundColor Cyan
Write-Host "SharePoint Site: $($currentConfig.organization.sharePointSiteUrl)" -ForegroundColor Cyan
Write-Host "Admin Emails: $($currentConfig.organization.adminEmails -join ', ')" -ForegroundColor Cyan
Write-Host ""
Write-Host "SharePoint List GUIDs:" -ForegroundColor Cyan
foreach($listGuid in $currentConfig.dataSourceTableIds.PSObject.Properties) {
    $status = if ($listGuid.Value -eq "00000000-0000-0000-0000-000000000000") { "(⚠️  PLACEHOLDER)" } else { "✅" }
    Write-Host "  $($listGuid.Name): $($listGuid.Value) $status" -ForegroundColor White
}

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Verify all GUIDs are correct (no placeholders)" -ForegroundColor White
Write-Host "2. Package: pac canvas pack --sources . --msapp AgileMaturityApp.msapp" -ForegroundColor White
Write-Host "3. Import into Power Apps and test connections" -ForegroundColor White

# Check for placeholders
$hasPlaceholders = $false
foreach($listGuid in $currentConfig.dataSourceTableIds.PSObject.Properties) {
    if ($listGuid.Value -eq "00000000-0000-0000-0000-000000000000") {
        $hasPlaceholders = $true
        break
    }
}

if ($hasPlaceholders) {
    Write-Host ""
    Write-Host "⚠️  WARNING: Some lists still have placeholder GUIDs!" -ForegroundColor Red
    Write-Host "   Run this script again with -Interactive to update them." -ForegroundColor Red
}

# Clean up temp files
Remove-Item "temp-decode-guids.ps1" -ErrorAction SilentlyContinue