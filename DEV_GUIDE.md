Developer Guide: Build, Pack, and Sync

Prereqs
- Windows 10/11
- Power Platform CLI (pac)
  - Install via Winget: winget install Microsoft.PowerApps.CLI
  - Or MSI: https://aka.ms/PowerAppsCLI

Authenticate
- pac auth create --url https://make.powerapps.com
  - Select your tenant/environment when prompted
- pac auth list (verify the active profile)

Pack Canvas App (create .msapp from this repo)
- From repo root:
  - pwsh scripts/pack-canvas.ps1 -Action pack -MsApp dist/AgileMaturityApp.msapp
- Result: dist/AgileMaturityApp.msapp

Import into Power Apps
- Go to https://make.powerapps.com
- Apps > Canvas app > Upload (or Create app from .msapp) > choose dist/AgileMaturityApp.msapp
- Save the app; publish when ready

Round‑trip (sync changes)
- Edit in Power Apps Studio, then export .msapp
- Unpack back into this repo structure:
  - pwsh scripts/pack-canvas.ps1 -Action unpack -MsApp path/to/exported.msapp -Source .
- Commit changes to git as usual

Notes
- This repo already has a valid CanvasManifest.json and Src/ files; packing from repo root works.
- For full ALM (solutions, pipelines, environments), consider Solutions and pac solution commands later.

Create the AppRoles list (for Admin/Assessor roles)
- Requires SharePoint site URL and PnP.PowerShell
- Run: pwsh scripts/Create-AppRoles.ps1 -SiteUrl https://yourtenant.sharepoint.com/sites/yoursite
- In Power Apps Studio, refresh data and add the AppRoles connector if not present.
