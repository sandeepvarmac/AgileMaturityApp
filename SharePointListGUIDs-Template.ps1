# SharePoint List GUIDs Template
# Copy your actual GUIDs here and then run Update-ListGUIDs.ps1

$ListGUIDs = @{
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
# .\Update-ListGUIDs.ps1 -ListGUIDs $ListGUIDs
