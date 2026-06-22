# Windows BSOD Analyzer

> **Testing note:** This was tested by me to be working. User experience may vary.

## One-click use

1. Download and extract the repository.
2. Double-click `Run-OneClick.bat`.
3. The crash-evidence report runs directly—there is no menu and dump files are not copied by default.
4. Review the exit code and reports under `C:\Users\Public\Documents\WindowsBSODReports`.

Included: `Analyze-WindowsBSOD.ps1`

## PowerShell usage

```powershell
.\Analyze-WindowsBSOD.ps1
.\Analyze-WindowsBSOD.ps1 -CopyMinidumps
.\Analyze-WindowsBSOD.ps1 -CopyMinidumps -WhatIf
```

Creates read-only reports for crash-dump inventory, bugcheck events, Windows Error Reporting and installed drivers. Optional dump copying supports `-WhatIf`.

Exit codes: `0` success, `1` fatal error, `2` warnings.

Crash dumps can contain memory fragments. Review them before sharing. Detailed root-cause analysis may still require WinDbg.

MIT License.
