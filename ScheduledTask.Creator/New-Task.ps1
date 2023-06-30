
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding(SupportsShouldProcess)]
param (
        [Parameter(Mandatory = $false, Position=0)]
        [String]$Path="$PSScriptRoot\Script_BlueScreen.ps1",
        [Parameter(Mandatory = $false)]
        [switch]$Test
    )


if(-not(Test-Path $Path)){
    throw "invalid script path"
}

. "$PSScriptRoot\ps\Functions.ps1"

[string]$Cmd = Get-Content -Path $Path -Raw

if($Test){
    $EncodedCommand= Get-PwshCommandLine -Script $Cmd
    "`&$EncodedCommand"
    return
}

#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
    Start-Sleep 1
    Write-Host " Launching in Admin mode" -f DarkRed
    Start-Process pwsh.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}



New-ScheduledTaskFolder -TaskPath 'DevelopmentTasks'
[string]$TaskName = "DevelopmentTasks\MsgBox"

$EncodedCommand= Get-EncodedCommand -Script $Cmd

[int]$IntervalDays = 2
[int]$IntervalMinutes = 30


Remove-ScriptTask -TaskName 'BLUESCREEN' -Verbose;
Start-Sleep 2
Install-EncodedScriptTask -TaskName $TaskName -IntervalDays $IntervalDays -EncodedTask $EncodedCommand -IntervalMinutes $IntervalMinutes


Write-Host "DONE" -f DarkGreen
Start-Sleep 3