#requires -Version 5.1
<# Created by Dewald Pretorius #>
param([string]$OutputPath,[string]$ComputerName)
if(-not $OutputPath){$OutputPath="$([Environment]::GetFolderPath('Desktop'))\Remote_Desktop_Reports"};New-Item $OutputPath -ItemType Directory -Force|Out-Null
$rdp=Get-Process mstsc -ErrorAction SilentlyContinue;$cred=cmdkey /list 2>$null;$net=$null;if($ComputerName){$net=Test-NetConnection $ComputerName -Port 3389 -WarningAction SilentlyContinue}
$events=Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TerminalServices-ClientActiveXCore/Operational';StartTime=(Get-Date).AddDays(-7)} -ErrorAction SilentlyContinue|Select-Object -First 60 TimeCreated,Id,LevelDisplayName,Message
@('MICROSOFT REMOTE DESKTOP CLIENT TROUBLESHOOTER','Created by Dewald Pretorius',"Generated: $(Get-Date)","mstsc running: $([bool]$rdp)",'Target connectivity:',($net|Format-List|Out-String -Width 220),'Saved credentials:',($cred|Out-String),'Events:',($events|Format-List|Out-String -Width 220),'Guidance: verify DNS, TCP 3389 or gateway access, credentials, certificates, NLA, display redirection, audio redirection, and local policy.')|Set-Content (Join-Path $OutputPath 'Report.txt') -Encoding UTF8