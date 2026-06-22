# Windows BSOD Analyzer

> **Testing note:** This was tested by me to be working. User experience may vary.

Included: `Analyze-WindowsBSOD.ps1`

```powershell
.\Analyze-WindowsBSOD.ps1
.\Analyze-WindowsBSOD.ps1 -CopyMinidumps
```

Creates read-only reports for crash-dump inventory, bugcheck events, Windows Error Reporting and installed drivers. Optional dump copying supports `-WhatIf`.

Reports: `C:\Users\Public\Documents\WindowsBSODReports`

Exit codes: `0` success, `1` fatal error, `2` warnings.

Crash dumps can contain memory fragments. Review them before sharing. Detailed root-cause analysis may still require WinDbg.

MIT License.
