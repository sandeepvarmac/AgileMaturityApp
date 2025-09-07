# Temp script to decode GUIDs
Add-Type -AssemblyName System.Web

$encodedGuids = @{
    'AssessmentHistory' = '%7Bd2a4100f-33b2-4c54-8bc0-fc0534b7cf66%7D'
    'Dimensions' = '%7Bd4746dba-1eab-4fa1-8521-c1800bd48af9%7D'
    'SubDimensions' = '%7B31e9f8a5-7b31-431a-97d9-e007e1facd26%7D'
    'Verticals' = '%7B53a4187d-572d-47f7-a1f3-efa4340264c6%7D'
    'Statements' = '%7B9b24ec75-a120-4ff0-83cb-fc696ff28902%7D'
    'Teams' = '%7B036f502b-9ef8-4a52-bbf5-e0662c227b7d%7D'
    'Assessments' = '%7B4d7ff8af-4730-4a05-822b-3f43ae83b0d6%7D'
    'AssessmentRatings' = '%7Bb6fa709f-8751-4350-9ffc-4b63678f6b6e%7D'
}

$decodedGuids = @{}
Write-Host "Decoded SharePoint List GUIDs:" -ForegroundColor Green
foreach($item in $encodedGuids.GetEnumerator()) {
    $decoded = [System.Web.HttpUtility]::UrlDecode($item.Value)
    $cleanGuid = $decoded -replace '[{}]', ''
    $decodedGuids[$item.Key] = $cleanGuid
    Write-Host "$($item.Key): $cleanGuid" -ForegroundColor Cyan
}


$decodedGuids