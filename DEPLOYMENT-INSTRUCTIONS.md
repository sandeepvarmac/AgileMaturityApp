# Agile Maturity Assessment App - Deployment Instructions

This document provides step-by-step instructions for deploying the Agile Maturity Assessment Power App to a different organization.

## Overview

The app uses the following connections that need to be reconfigured:
- **SharePoint** - For storing assessment data in SharePoint lists
- **Office 365 Users** - For user profile information (typically works across tenants)

## Prerequisites

Before deployment, ensure you have:
1. **Power Platform Administrator** access in the target organization
2. **SharePoint Administrator** access in the target organization  
3. **Power Platform CLI** installed ([Download](https://docs.microsoft.com/en-us/power-platform/developer/cli/introduction))
4. **PowerShell 5.1** or later

## Step 1: Prepare the Target Environment

### 1.1 Create SharePoint Lists

The app requires the following SharePoint lists to be created in the target organization:

| List Name | Purpose | Key Columns |
|-----------|---------|-------------|
| **Teams** | Store team information | TeamName, VerticalID, TeamSize, ScrumMaster |
| **Verticals** | Business verticals/departments | VerticalName, Description |
| **Dimensions** | Assessment dimensions | DimensionName, Description, SortOrder |
| **SubDimensions** | Assessment sub-dimensions | SubDimensionName, DimensionID, SortOrder |
| **Statements** | Assessment statements | StatementText, DimensionID, SubDimensionID, SortOrder |
| **Assessments** | Assessment instances | TeamID, AssessmentType, Status, CreatedBy, CreatedDate |
| **AssessmentRatings** | Individual ratings | AssessmentID, StatementID, Rating, Comments |
| **AssessmentHistory** | Assessment history | AssessmentID, Action, Timestamp, UserID |

> **Note**: The exact column types and configurations should match the original SharePoint site structure. Consider exporting list templates from the original site.

### 1.2 Note SharePoint Site Information

Record the following information for the target SharePoint site:
- **SharePoint Site URL**: `https://[tenant].sharepoint.com`
- **Site Path**: Usually `_layouts/15/lists.aspx` for main site, or `/sites/[sitename]/_layouts/15/lists.aspx` for team sites

## Step 2: Update Configuration

### 2.1 Quick Migration Setup

For a complete migration to a new organization, use the comprehensive migration script:

```powershell
.\Update-SharePointGUIDs-Easy.ps1 -NewOrganizationSite "https://neworg.sharepoint.com" -Interactive
```

This will:
1. Update the organization SharePoint site URL
2. Run the connection update script automatically  
3. Prompt for all SharePoint List GUIDs interactively
4. Validate all inputs and update configuration files
5. Show a summary of the migration status

### 2.2 Manual Configuration (Alternative)

#### 2.2.1 Update deployment-config.json

Edit the `deployment-config.json` file with the new organization details:

```json
{
  "organization": {
    "name": "[New Organization Name]",
    "sharePointSiteUrl": "https://[newtenant].sharepoint.com",
    "sharePointListsPath": "_layouts/15/lists.aspx", 
    "adminEmails": [
      "admin1@neworg.com",
      "admin2@neworg.com"
    ]
  },
  "dataSourceTableIds": {
    "AssessmentHistory": "00000000-0000-0000-0000-000000000000",
    "AssessmentRatings": "00000000-0000-0000-0000-000000000000",
    "Assessments": "00000000-0000-0000-0000-000000000000",
    "Dimensions": "00000000-0000-0000-0000-000000000000",
    "Statements": "00000000-0000-0000-0000-000000000000",
    "SubDimensions": "00000000-0000-0000-0000-000000000000",
    "Teams": "00000000-0000-0000-0000-000000000000",
    "Verticals": "00000000-0000-0000-0000-000000000000"
  }
}
```

> **Note**: The placeholder GUIDs (`00000000-0000-0000-0000-000000000000`) must be replaced with actual SharePoint List GUIDs before deployment.

#### 2.2.2 Run the Connection Update Script

Execute the PowerShell script to update all connection references:

```powershell
.\Update-Connections.ps1
```

This script will automatically update:
- App.fx.yaml configuration variables
- Connection definitions  
- DataSource configurations
- Table definitions

#### 2.2.3 Update SharePoint List GUIDs

After updating the base configuration, run the GUID update process as described in Step 4.2.

## Step 3: Package and Deploy the App

### 3.1 Package the App

Use Power Platform CLI to package the updated source files:

```bash
pac canvas pack --sources . --msapp AgileMaturityApp.msapp
```

### 3.2 Import to Target Environment

1. **Login to Power Platform Admin Center**
   - Go to [admin.powerplatform.microsoft.com](https://admin.powerplatform.microsoft.com)
   - Select the target environment

2. **Import the App**
   - Go to [make.powerapps.com](https://make.powerapps.com)
   - Select **Apps** → **Import canvas app**
   - Upload the `AgileMaturityApp.msapp` file
   - Choose **Import** settings

3. **Handle Connection References**
   - During import, you'll be prompted to create new connections
   - Create a new **SharePoint** connection pointing to your target SharePoint site
   - The **Office 365 Users** connection should work automatically

## Step 4: Post-Deployment Configuration

### 4.1 Verify SharePoint Connection

1. Open the imported app in **Power Apps Studio**
2. Go to **Data** → **Data sources**
3. Verify all SharePoint lists are connected properly
4. If any lists show errors, refresh or reconnect them

### 4.2 Update SharePoint List GUIDs

The SharePoint List GUIDs are critical for proper app functionality and must be updated when migrating to a new organization. The app includes automation scripts to streamline this process.

#### Method 1: Using the Easy GUID Updater (Recommended)

For a simplified interactive experience:

```powershell
.\Update-SharePointGUIDs-Easy.ps1 -Interactive
```

This script will:
- Prompt you to enter GUIDs for all required lists
- Validate GUID format automatically
- Update all configuration files in one operation
- Show a summary of current configuration
- Check for any remaining placeholder GUIDs

#### Method 2: Batch GUID Update

If you have all GUIDs ready, create a hashtable and run:

```powershell
$listGUIDs = @{
    "AssessmentHistory" = "your-guid-here"
    "AssessmentRatings" = "your-guid-here"
    "Assessments" = "your-guid-here"
    "Dimensions" = "your-guid-here"
    "Statements" = "your-guid-here"
    "SubDimensions" = "your-guid-here"
    "Teams" = "your-guid-here"
    "Verticals" = "your-guid-here"
}

.\Update-ListGUIDs.ps1 -ListGUIDs $listGUIDs
```

#### Finding SharePoint List GUIDs

**Option A: From SharePoint List Settings**
1. Navigate to your SharePoint site
2. Go to each list → **List settings** (gear icon → List settings)
3. Copy the GUID from the browser URL after `List=%7B` and before `%7D`
4. The GUID will be URL-encoded (e.g., `%7Bd2a4100f-33b2-4c54-8bc0-fc0534b7cf66%7D`)
5. Remove the `%7B` and `%7D` parts to get the clean GUID

**Option B: Using REST API**
Get list information via REST endpoint:
```
https://[tenant].sharepoint.com/[site]/_api/web/lists/getbytitle('[ListName]')/Id
```

**Option C: From List URL**
When viewing a list, the GUID appears in the URL:
```
https://[site]/_layouts/15/listedit.aspx?List=%7BGUID-HERE%7D
```

#### What Gets Updated

The GUID update scripts automatically update:
- `deployment-config.json` - Central configuration file
- `Connections\Connections.json` - SharePoint connection data sources
- `DataSources\*.json` - Individual data source table names
- `pkgs\TableDefinitions\*.json` - Table definition GUIDs

#### Verification Steps

After updating GUIDs:
1. Run the verification command:
   ```powershell
   .\Update-SharePointGUIDs-Easy.ps1
   ```
2. Check the summary output for any remaining placeholder GUIDs (`00000000-0000-0000-0000-000000000000`)
3. Ensure all required lists show ✅ status
4. Repackage the app:
   ```bash
   pac canvas pack --sources . --msapp AgileMaturityApp.msapp
   ```

#### Required SharePoint Lists

The following 9 lists must exist in your SharePoint site:

| List Name | Purpose | Required Columns |
|-----------|---------|------------------|
| **AssessmentHistory** | Track assessment changes | AssessmentID, Action, Timestamp, UserID |
| **AssessmentRatings** | Store individual statement ratings | AssessmentID, StatementID, Rating, Comments |
| **Assessments** | Main assessment records | TeamID, AssessmentType, Status, CreatedBy |
| **Dimensions** | Assessment categories | DimensionName, Description, SortOrder |
| **Statements** | Assessment questions | StatementText, DimensionID, SubDimensionID |
| **SubDimensions** | Assessment subcategories | SubDimensionName, DimensionID, SortOrder |
| **Teams** | Team information | TeamName, VerticalID, ScrumMaster, Status |
| **Verticals** | Business units/departments | VerticalName, Description |

> **Important**: All lists must be created before running the GUID update scripts. Missing lists will cause the update to fail.

### 4.3 Test Core Functionality

Test the following features:
- ✅ User authentication and admin permissions
- ✅ Team creation and management
- ✅ Assessment creation
- ✅ Assessment completion workflow
- ✅ Data saving to SharePoint lists

## Step 5: User Training and Rollout

### 5.1 Update User Permissions

Ensure users have appropriate permissions:
- **SharePoint Site**: Read/Write access to the assessment lists
- **Power Apps**: Permission to run the app
- **Admin Users**: Update the admin email list in the app configuration

### 5.2 Provide Training Materials

Create organization-specific training materials covering:
- How to access the app
- Team setup process
- Assessment workflow
- Interpreting results

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| **Connection errors** | SharePoint connection not authorized | Reconnect SharePoint data source in Power Apps Studio |
| **List not found errors** | SharePoint lists don't exist or have different names | Ensure all required lists are created with correct names |
| **Permission errors** | Users lack SharePoint access | Verify SharePoint site permissions |
| **Admin features not working** | Admin emails not updated | Update `gblAdminEmails` variable in App.fx.yaml |

### Getting Help

For deployment issues:
1. Check the **Power Platform Admin Center** for environment health
2. Verify **SharePoint permissions** and list configurations
3. Review **Power Apps connection** status in the maker portal
4. Consult **Power Platform documentation** for environment-specific issues

## Files Modified During Deployment

The following files are automatically updated by the deployment and migration scripts:

### Updated by Update-Connections.ps1:
- `Src\App.fx.yaml` - App configuration and global variables
- `Connections\Connections.json` - Connection definitions and SharePoint site URLs
- `DataSources\*.json` - SharePoint data source configurations
- `pkgs\TableDefinitions\*.json` - SharePoint list table definitions

### Updated by Update-ListGUIDs.ps1 and Update-SharePointGUIDs-Easy.ps1:
- `deployment-config.json` - Central configuration file with all GUIDs
- `Connections\Connections.json` - SharePoint data source table names (GUIDs)
- `DataSources\*.json` - Individual data source TableName properties
- `pkgs\TableDefinitions\*.json` - Table definition GUID references

### Configuration Files Overview:

| File | Purpose | When Updated |
|------|---------|--------------|
| `deployment-config.json` | Master configuration for migrations | Site URL and GUID updates |
| `Src\App.fx.yaml` | Power Apps global variables | Site URL and admin email updates |
| `Connections\Connections.json` | Power Platform connection definitions | Site URL and GUID updates |
| `DataSources\*.json` | Individual SharePoint list connections | GUID updates only |
| `pkgs\TableDefinitions\*.json` | SharePoint list schema definitions | GUID updates only |

### Automation Scripts:

| Script | Purpose | Usage |
|--------|---------|--------|
| `Update-SharePointGUIDs-Easy.ps1` | Complete migration automation | `.\Update-SharePointGUIDs-Easy.ps1 -Interactive` |
| `Update-Connections.ps1` | Update site URLs and connections | Automatically called by easy script |
| `Update-ListGUIDs.ps1` | Update SharePoint List GUIDs only | `.\Update-ListGUIDs.ps1 -ListGUIDs $hashtable` |

## Security Considerations

- **Admin Permissions**: Only add trusted users to the admin email list
- **SharePoint Access**: Follow principle of least privilege for SharePoint permissions
- **Connection Security**: Regularly review and audit Power Platform connections
- **Data Privacy**: Ensure compliance with organization data privacy policies

---

**Need Help?** Contact the development team or refer to the [Power Platform documentation](https://docs.microsoft.com/en-us/power-platform/).