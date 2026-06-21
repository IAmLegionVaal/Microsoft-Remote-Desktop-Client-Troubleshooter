# Microsoft Remote Desktop Client Troubleshooter

Created by **Dewald Pretorius**.

The repository includes the original connectivity, credential, certificate, display, audio, and gateway diagnostics plus a guarded `Repair.ps1` helper.

Supported actions are `Diagnose`, `ResetClientCache`, and `FlushDns`.

```powershell
.\Repair.ps1 -Action Diagnose
.\Repair.ps1 -Action ResetClientCache -WhatIf
.\Repair.ps1 -Action ResetClientCache -Confirm
```

Close Remote Desktop client processes before cache repair. Existing cache data is preserved in a timestamped backup. Each run saves pre-change evidence and a log. Source-reviewed for PowerShell 5.1; not runtime-tested on every client or gateway environment.
