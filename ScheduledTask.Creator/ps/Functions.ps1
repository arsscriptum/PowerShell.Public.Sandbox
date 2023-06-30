
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

function Remove-ScriptTask {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TaskName
    )


    Stop-ScheduledTask -TaskName $TaskName -ErrorAction Ignore | Write-Verbose
    Disable-ScheduledTask -TaskName $TaskName  -ErrorAction Ignore |  Write-Verbose
    Unregister-ScheduledTask -TaskName $TaskName  -Confirm:$False  -ErrorAction Ignore | Write-Verbose
}


Function New-ScheduledTaskFolder{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$TaskPath
    )
    $BackupEA = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    Write-Host "New-ScheduledTaskFolder called with path $TaskPath"


    $scheduleObject = New-Object -ComObject schedule.service
    $scheduleObject.connect()
    $rootFolder = $scheduleObject.GetFolder("\")
    Try 
    {
        $null = $scheduleObject.GetFolder($TaskPath)
    }
    Catch { 
        $null = $rootFolder.CreateFolder($TaskPath) 
        $ErrorActionPreference = $BackupEA
    }
    Finally { 
        $ErrorActionPreference = $BackupEA
    } 
}

function Install-NormalScriptTask {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TaskName,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$CmdLine,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$CmdLineArguments,
        [Parameter(Mandatory=$False)]
        [switch ]$Admin,
        [Parameter(Mandatory=$False)]
        [int]$IntervalMinutes=0
    )

    $action = New-ScheduledTaskAction -Execute "$CmdLine" -Argument "$CmdLineArguments"
    
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(5)
    
    $settings = New-ScheduledTaskSettingsSet -MultipleInstances Parallel -Hidden -Priority 3
    
    if($Admin -eq $False){
        
        Write-Host "######################################################################" -f DarkRed
        Write-Host "                          ENTER CREDENTIALS                           " -f DarkYellow
        Write-Host "######################################################################`n" -f DarkRed
        $msg = "Enter the username and password that will run the task"; 
        $credential = $Host.UI.PromptForCredential("Task username and password",$msg,$env:username,$env:userdomain)
        $username = $credential.UserName
        $password = $credential.GetNetworkCredential().Password
       
        $principal = New-ScheduledTaskPrincipal -UserID "$env:userdomain\$username" -LogonType Password 
        $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
        $Res=Register-ScheduledTask $TaskName -InputObject $task -User $username -Password $password
        Write-Host ($Res | Out-String)
    }else{
        $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
        $Res=Register-ScheduledTask $TaskName -InputObject $task
        Write-Host ($Res | Out-String)
    }
    

    
    $Res=Start-ScheduledTask -TaskName $TaskName | Out-String | Write-Host
    Write-Host ($Res | Out-String)
}

function Install-EncodedScriptTask {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TaskName,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [int]$IntervalDays,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$EncodedTask,
        [Parameter(Mandatory=$False)]
        [switch ]$Admin,
        [Parameter(Mandatory=$False)]
        [int]$IntervalMinutes=0
    )

    $EncodedTaskLen=$EncodedTask.Length
    Write-Host "Install-EncodedScriptTask called with taskname $TaskName. Code: EncodedTask ($EncodedTaskLen chars)"
 $PwExe = (Get-Command 'pwsh.exe').Source
    $action = New-ScheduledTaskAction -Execute "$PwExe" -Argument "-ExecutionPolicy Unrestricted -WindowStyle Hidden -EncodedCommand `"$EncodedTask`""
    #$action = New-ScheduledTaskAction -Execute "C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-ExecutionPolicy Unrestricted -NoProfile -WindowStyle Hidden -EncodedCommand `"$EncodedTask`""
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Days $IntervalDays)
    if($IntervalMinutes -gt 0){
        Write-Host "RUNNING INTERVAL: $IntervalMinutes Minutes" -f DarkYellow
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes)
    }else{
        Write-Host "RUNNING INTERVAL: $IntervalDays DAYS" -f DarkYellow
    }
    
    
    $settings = New-ScheduledTaskSettingsSet -MultipleInstances Parallel -Hidden -Priority 3
    
    if($Admin -eq $False){
        
        Write-Host "######################################################################" -f DarkRed
        Write-Host "                          ENTER CREDENTIALS                           " -f DarkYellow
        Write-Host "######################################################################`n" -f DarkRed
        $msg = "Enter the username and password that will run the task"; 
        $credential = $Host.UI.PromptForCredential("Task username and password",$msg,$env:username,$env:userdomain)
        $username = $credential.UserName
        $password = $credential.GetNetworkCredential().Password
       
        $principal = New-ScheduledTaskPrincipal -UserID "$env:userdomain\$username" -LogonType Password 
        $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
        $Res=Register-ScheduledTask $TaskName -InputObject $task -User $username -Password $password
        Write-Host ($Res | Out-String)
    }else{
        $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
        $Res=Register-ScheduledTask $TaskName -InputObject $task
        Write-Host ($Res | Out-String)
    }
    

    
    $Res=Start-ScheduledTask -TaskName $TaskName | Out-String | Write-Host
    Write-Host ($Res | Out-String)
}



function Install-BatchFileScriptTask {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$BatchFile,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$UserName,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TaskName
    )

    $action = New-ScheduledTaskAction -Execute "$BatchFile"
    $TaskName = "Run {0} Interactive" -f ((Get-Item $BatchFile).Name)
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    
    $settings = New-ScheduledTaskSettingsSet -Priority 10
    
    $principal = New-ScheduledTaskPrincipal -UserID "$env:userdomain\$UserName" -LogonType Interactive -RunLevel Highest
    $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
    $Res=Register-ScheduledTask $TaskName -InputObject $task -User $username 
}

function Get-EncodedCommand
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true, Position=0)]
        [String]$Script,
        [Parameter(Mandatory = $false)]
        [switch]$Test
    )

    try {
        if($Test){

            [scriptblock]$sb=[scriptblock]::create($Script)
            Invoke-Command -scriptblock $sb
        }
        $PWSHEXE = (Get-Command 'pwsh.exe').Source
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($Script)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        $arg = @("`"{0}`"" -f $encodedCommand)
        
        $Ret = "$arg"
        return $Ret
        
    }

    catch {
        return $false
    }
}

function Get-PwshCommandLine
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true, Position=0)]
        [String]$Script,
        [Parameter(Mandatory = $false)]
        [switch]$Test
    )

    try {
        if($Test){

            [scriptblock]$sb=[scriptblock]::create($Script)
            Invoke-Command -scriptblock $sb
        }
        $PWSHEXE = (Get-Command 'pwsh.exe').Source
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($Script)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        $arg = @("-NoProfile -ExecutionPolicy Bypass -encodedcommand `"{0}`"" -f $encodedCommand)
        
        $Ret = "`"$PWSHEXE`" $arg"
        return $Ret
        
    }

    catch {
        return $false
    }
}

