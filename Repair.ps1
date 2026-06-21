#requires -Version 5.1
<# Created by Dewald Pretorius. #>
[CmdletBinding(SupportsShouldProcess=$true)]
param([ValidateSet('Diagnose','ResetClientCache','FlushDns')][string]$Action='Diagnose',[string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'Remote_Desktop_Client_Repair'))
$ErrorActionPreference='Stop'
$cachePath="$env:LOCALAPPDATA\Packages\Microsoft.RemoteDesktop_8wekyb3d8bbwe\LocalCache"
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss';$logPath=Join-Path $OutputPath "Repair_$stamp.log"
function Log([string]$Message){$line='{0:u} {1}' -f (Get-Date),$Message;Write-Host $line;Add-Content -LiteralPath $logPath -Value $line}
[ordered]@{Action=$Action;Processes=@(Get-Process msrdc,mstsc -ErrorAction SilentlyContinue|Select-Object Name,Id);CacheExists=(Test-Path -LiteralPath $cachePath);Service=(Get-Service TermService -ErrorAction SilentlyContinue|Select-Object Name,Status,StartType);CloudEndpoint=(Test-NetConnection 'rdweb.wvd.microsoft.com' -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue)}|ConvertTo-Json -Depth 5|Set-Content -LiteralPath (Join-Path $OutputPath "PreRepair_$stamp.json")
if($Action -eq 'Diagnose'){Log '[COMPLETE] Read-only snapshot saved.';exit 0}
try{
  if($Action -eq 'ResetClientCache' -and $PSCmdlet.ShouldProcess($cachePath,'Back up and reset client cache')){
    if(Get-Process msrdc,mstsc -ErrorAction SilentlyContinue){throw 'Close Remote Desktop clients before resetting the cache.'}
    if(Test-Path -LiteralPath $cachePath){$backup="$cachePath.backup-$stamp";Move-Item -LiteralPath $cachePath -Destination $backup -Force;New-Item -ItemType Directory -Path $cachePath -Force|Out-Null;Log "[BACKUP] $backup"}
  }
  elseif($Action -eq 'FlushDns' -and $PSCmdlet.ShouldProcess('Windows DNS client cache','Clear')){Clear-DnsClientCache}
}catch{Log "[FAILED] $($_.Exception.Message)";exit 5}
Log '[COMPLETE] Repair completed.'
exit 0
