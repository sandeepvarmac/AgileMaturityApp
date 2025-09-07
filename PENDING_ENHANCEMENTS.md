Pending Enhancements and Next Steps

This document tracks remaining work for the Agile Maturity Assessment app. It is split into Now / Next / Later, with owners and rough estimates.

Owner key
- Dev: App developer
- Admin: App admin/business owner
- SP: SharePoint admin
- PP: Power Platform admin

Now (1–2 weeks)
- Native charts binding (requires chart controls dropped in Studio)
  - Period trend → Column chart; dataset: period averages (monthly/quarterly)
  - By Team trend → Line chart; series per team, X=period, Y=AvgScore
  - By Dimension → Column chart; top N by AvgScore
  - Owner: Dev  Estimate: 2–3 days (after controls are present)
- Guard Patch calls with role checks as belt‑and‑suspenders
  - Wrap Save/Next: If(gblIsAssessor || gblIsAdmin, ...)
  - Owner: Dev  Estimate: 0.5 day
- Create SharePoint AppRoles list and wire in Studio
  - Columns: User (Person), Role (Choice: Admin, Assessor), Title (Text)
  - Refresh data sources in app
  - Owner: Admin/SP  Estimate: 0.5 day
- Lock completed assessments from edits (except admin)
  - Disable/hide rating actions when 'Status ' = "Completed" and not gblIsAdmin
  - Owner: Dev  Estimate: 0.5 day

Next (2–4 weeks)
- Report exports and print view
  - CSV/Excel export of KPI/breakdown datasets; print‑friendly screen
  - Owner: Dev  Estimate: 2 days
- Structured history
  - Add ActionType (Choice) to AssessmentHistory; update logging to use structured values
  - Owner: Dev/Admin  Estimate: 1–2 days
- SharePoint item‑level permissions (defense‑in‑depth)
  - Break inheritance on Assessments/Ratings/History; grant Admins + Scrum Master
  - Automate via Power Automate flow
  - Owner: Admin/SP  Estimate: 3–4 days
- Admin UX polish
  - Field validation, duplicate checks; paging/search improvements
  - Owner: Dev  Estimate: 2–3 days
- Performance/delegation pass
  - Review delegability; precompute/report collections; reduce nested LookUps
  - Owner: Dev  Estimate: 2–3 days

Later (4+ weeks / optional)
- Advanced analytics
  - Ceremonies/sub‑dimension charts; weighted scoring by dimension
  - Owner: Dev  Estimate: 3–5 days
- Radar/spider visuals
  - Power BI embed or PCF control
  - Owner: Dev/PP  Estimate: 5–10 days
- Notifications
  - Office365Outlook emails for milestones/overdue reminders
  - Owner: Dev/Admin  Estimate: 1–2 days
- Bulk import/export
  - CSV template for statements/dimensions; import wizard
  - Owner: Dev  Estimate: 3–4 days
- Offline/mobile improvements
  - SaveData/LoadData for limited offline entry
  - Owner: Dev  Estimate: 3–5 days
- ALM/DevEx
  - Solution packaging, env. variables, CI for pack/validate
  - Owner: Dev/PP  Estimate: 3–5 days

Recently Completed (context)
- Fixed TableDefinitions; validated JSON.
- Persist ratings, compute OverallScore; In Progress/Completed.
- History logging on save/progress/complete.
- Admin CRUD for Dimensions/SubDimensions/Statements; role gating.
- Admin‑only New Team; non‑assessor rating controls hidden/disabled; view‑only notice.
- Scoped data via gblAssessView (admin → all; non‑admin → user’s teams) across Assessments and Reports.
- Reports: KPIs, By Team/By Dimension, period breakdown (Monthly/Quarterly), filter bar (Vertical, Year, Granularity), attachments viewer.

Verification checklist (after each milestone)
- AppRoles exists; roles load; gblIsAdmin/gblIsAssessor behave for test users.
- Non‑assessors cannot see rating controls; cannot trigger Patch; can view assessments/reports for their teams.
- Ratings save compute OverallScore; completed assessments lock as expected.
- Reports reflect filters and scope; charts render with expected data.
