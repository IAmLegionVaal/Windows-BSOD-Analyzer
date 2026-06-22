<#
.SYNOPSIS
Collects Windows crash-dump inventory and related event evidence.
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [switch]$CopyMinidumps,
    [ValidateRange(1,50)][int]$MaximumDumps=10,
    [string]$OutputRoot="$env:PUBLIC\Documents\WindowsBSODReports"
)

Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$runPath=Join-Path $OutputRoot ("BSOD_{0}_{1}" -f $env:COMPUTERNAME,(Get-Date -Format 'yyyyMMdd_HHmmss'))
$warnings=New-Object System.Collections.Generic.List[string]

try{
    if($env:OS -ne 'Windows_NT'){throw 'Windows is required.'}
    New-Item $runPath -ItemType Directory -Force|Out-Null

    $dumps=@(
        Get-ChildItem "$env:SystemRoot\Minidump\*.dmp" -File -ErrorAction SilentlyContinue
        Get-Item "$env:SystemRoot\MEMORY.DMP" -ErrorAction SilentlyContinue
    )|Where-Object{$_}|Sort-Object LastWriteTime -Descending

    $dumps|Select-Object FullName,Length,CreationTime,LastWriteTime|
        Export-Csv (Join-Path $runPath 'CrashDumpInventory.csv') -NoTypeInformation

    try{
        Get-WinEvent -FilterHashtable @{LogName='System';Id=41,1001;StartTime=(Get-Date).AddDays(-90)} -MaxEvents 300 -ErrorAction Stop|
            Select-Object TimeCreated,Id,LevelDisplayName,ProviderName,Message|
            Export-Csv (Join-Path $runPath 'CrashEvents.csv') -NoTypeInformation
    }catch{$warnings.Add("Crash events: $($_.Exception.Message)")}

    try{
        Get-WinEvent -FilterHashtable @{LogName='Application';ProviderName='Windows Error Reporting';StartTime=(Get-Date).AddDays(-90)} -MaxEvents 300 -ErrorAction Stop|
            Select-Object TimeCreated,Id,LevelDisplayName,Message|
            Export-Csv (Join-Path $runPath 'WindowsErrorReporting.csv') -NoTypeInformation
    }catch{$warnings.Add("WER events: $($_.Exception.Message)")}

    Get-CimInstance Win32_PnPSignedDriver|
        Select-Object DeviceName,DeviceClass,Manufacturer,DriverProviderName,DriverVersion,DriverDate,InfName|
        Export-Csv (Join-Path $runPath 'InstalledDrivers.csv') -NoTypeInformation

    if($CopyMinidumps -and $PSCmdlet.ShouldProcess('Recent crash dumps','Copy into report folder')){
        $destination=Join-Path $runPath 'Minidumps'
        New-Item $destination -ItemType Directory -Force|Out-Null
        $dumps|Select-Object -First $MaximumDumps|Copy-Item -Destination $destination
        'Crash dumps can contain fragments of system memory. Review before sharing.'|
            Out-File (Join-Path $destination 'PRIVACY_NOTICE.txt')
    }

    $warnings|Out-File (Join-Path $runPath 'Warnings.txt')
    Write-Host "[OK] Crash report created: $runPath" -ForegroundColor Green
    if($warnings.Count -gt 0){exit 2}else{exit 0}
}catch{Write-Error $_.Exception.Message;exit 1}
