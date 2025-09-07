# Update-ListGUIDs.ps1
# Script to update SharePoint List GUIDs in all configuration files

param(
    [Parameter(Mandatory=$true)]
    [hashtable]$ListGUIDs
)

Write-Host "=== Updating SharePoint List GUIDs ===" -ForegroundColor Green
Write-Host ""

# Validate that we have all required lists
$requiredLists = @('AssessmentHistory', 'AssessmentRatings', 'Assessments', 'Dimensions', 'Statements', 'SubDimensions', 'Teams', 'Verticals', 'AppRoles')
$missingLists = @()

foreach ($listName in $requiredLists) {
    if (-not $ListGUIDs.ContainsKey($listName)) {
        $missingLists += $listName
    }
}

if ($missingLists.Count -gt 0) {
    Write-Error "Missing GUIDs for lists: $($missingLists -join ', ')"
    Write-Host "Please provide GUIDs for all required lists." -ForegroundColor Red
    exit 1
}

Write-Host "Updating GUIDs for:" -ForegroundColor Yellow
foreach ($list in $ListGUIDs.GetEnumerator()) {
    Write-Host "  $($list.Key): $($list.Value)" -ForegroundColor Cyan
}
Write-Host ""

# Update deployment-config.json
Write-Host "Updating deployment-config.json..." -ForegroundColor Yellow
$configPath = "deployment-config.json"
$config = Get-Content $configPath | ConvertFrom-Json

foreach ($list in $ListGUIDs.GetEnumerator()) {
    $config.dataSourceTableIds.$($list.Key) = $list.Value
}

$config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
Write-Host "✓ Updated deployment-config.json" -ForegroundColor Green

# Update Connections.json
Write-Host "Updating Connections.json..." -ForegroundColor Yellow
$connectionsPath = "Connections\Connections.json"
$connections = Get-Content $connectionsPath | ConvertFrom-Json

# Find the SharePoint dataset
$sharePointKey = $connections.'633c5160-5190-4e88-bf51-8fd7b33cfbeb'.datasets.PSObject.Properties.Name | Where-Object { $_ -like "*sharepoint*" }
if ($sharePointKey) {
    foreach ($list in $ListGUIDs.GetEnumerator()) {
        if ($connections.'633c5160-5190-4e88-bf51-8fd7b33cfbeb'.datasets.$sharePointKey.dataSources.$($list.Key)) {
            $connections.'633c5160-5190-4e88-bf51-8fd7b33cfbeb'.datasets.$sharePointKey.dataSources.$($list.Key).tableName = $list.Value
        }
    }
}

$connections | ConvertTo-Json -Depth 10 | Set-Content $connectionsPath -Encoding UTF8
Write-Host "✓ Updated Connections.json" -ForegroundColor Green

# Update DataSource files
Write-Host "Updating DataSource files..." -ForegroundColor Yellow
$dataSourceFiles = Get-ChildItem "DataSources\*.json"
$updatedCount = 0

foreach ($file in $dataSourceFiles) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    if ($ListGUIDs.ContainsKey($baseName)) {
        $content = Get-Content $file.FullName | ConvertFrom-Json
        
        # Update TableName in the data source
        if ($content[0].TableName) {
            $content[0].TableName = $ListGUIDs[$baseName]
            $updatedCount++
        }
        
        $content | ConvertTo-Json -Depth 10 | Set-Content $file.FullName -Encoding UTF8
    }
}
Write-Host "✓ Updated $updatedCount DataSource files" -ForegroundColor Green

# Update TableDefinitions
Write-Host "Updating TableDefinitions..." -ForegroundColor Yellow  
$tableDefFiles = Get-ChildItem "pkgs\TableDefinitions\*.json"
$updatedTableCount = 0

foreach ($file in $tableDefFiles) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    if ($ListGUIDs.ContainsKey($baseName)) {
        $content = Get-Content $file.FullName -Raw
        # Update any GUID references in the table definitions
        $oldGuid = [regex]::Match($content, '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}').Value
        if ($oldGuid) {
            $content = $content -replace $oldGuid, $ListGUIDs[$baseName]
            Set-Content $file.FullName $content -Encoding UTF8
            $updatedTableCount++
        }
    }
}
Write-Host "✓ Updated $updatedTableCount TableDefinition files" -ForegroundColor Green

Write-Host ""
Write-Host "=== GUID Update Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Package the app: pac canvas pack --sources . --msapp AgileMaturityApp.msapp" -ForegroundColor White
Write-Host "2. Import the app into Power Apps" -ForegroundColor White  
Write-Host "3. Test the SharePoint connections" -ForegroundColor White
Write-Host ""
