
function Get-CurrentResolution{
   [CmdletBinding(SupportsShouldProcess)]
   param()

   $WmicExe = (Get-Command 'wmic.exe').Source

   [string[]]$Data = &"$WmicExe" 'path' 'Win32_VideoController' 'get' 'CurrentHorizontalResolution,CurrentVerticalResolution,DeviceID'

   $hindex = 0
   $vindex = 0
   [System.Collections.ArrayList]$ResolutionList = [System.Collections.ArrayList]::new()
   ForEach($line in $Data){
      if($line -match "CurrentHorizontalResolution"){
            $hindex = $line.IndexOf('CurrentHorizontalResolution')
            $vindex = $line.IndexOf('CurrentVerticalResolution')
            $deviceid_index = $line.IndexOf('DeviceID')
         continue;
      }
      if([string]::IsNullOrEmpty($line)){
         continue;
      }
      $Hres = $line.Substring($hindex,$vindex).Trim()
      $Vres = $line.Substring($vindex,$deviceid_index-$vindex).Trim()
      $DeviceId = $line.Substring($deviceid_index,$line.Length-$deviceid_index).Trim()

      $o = [PsCustomObject]@{
         DeviceId = $DeviceId
         Horizontal = $Hres
         Vertical = $Vres
      }
      [void]$ResolutionList.Add($o)
   } 

   $ResolutionList
}

function Get-PositionValueFromResolution{
   [CmdletBinding(SupportsShouldProcess)]
   param()

   $MaxHRes = (Get-CurrentResolution | Select -ExpandProperty Horizontal | Measure-Object -Maximum).Maximum
   $MaxVRes = (Get-CurrentResolution | Select -ExpandProperty Vertical | Measure-Object -Maximum).Maximum
   $MaxHRes = $MaxHRes - 4 
   $MaxVRes = $MaxVRes - 4
   $HexVal = '0x{0}{1}' -f ([System.Convert]::ToString($MaxVRes,16).PadLeft(4,'0')),([System.Convert]::ToString($MaxHRes,16).PadLeft(4,'0'))
   $NumValue = [Int32]"$HexVal"
   $NumValue
}

function Set-AppConsoleProperties {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    try{
        if(-not(Test-Path "$Path")){ throw "no such file"}
        $ModPath = $Path.Replace("\","_")
        $RegPath = "HKCU:\Console\{0}" -f $ModPath
        $Null = New-Item -Path "$RegPath" -Force -ErrorAction Ignore

        [int]$SizeValue = [int32]"0x00010001"
        $Null = New-ItemProperty -Path "$RegPath" -Name "WindowSize" -PropertyType DWORD -Value $SizeValue

        [BigInt]$Val = Get-PositionValueFromResolution
        $Null = New-ItemProperty -Path "$RegPath" -Name "WindowPosition" -PropertyType DWORD -Value $Val
    }catch{
        Write-Error "$_"
    }
}

function Set-AppConsolePropertiesForAllUsers {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    try{
        if(-not(Test-Path "$Path")){ throw "no such file"}
        $ModPath = $Path.Replace("\","_")
        New-PSDrive HKU Registry HKEY_USERS
        $UserNames = Get-LocalUser | Where Enabled -eq $True | Select -ExpandProperty Name
        ForEach($user in $UserNames){
            $Sid =  (Get-UserSID $user).SID
            $RegPathRoot = "HKU:\{0}\Console" -f $Sid
            if(Test-Path $RegPathRoot){
                Write-Host "Found `"$RegPathRoot`""
                
                $RegPath = "{0}\{1}" -f $RegPathRoot, $ModPath
                $Null = New-Item -Path "$RegPath" -Force -ErrorAction Ignore

                [int]$SizeValue = [int32]"0x00010001"
                $Null = New-ItemProperty -Path "$RegPath" -Name "WindowSize" -PropertyType DWORD -Value $SizeValue

                [BigInt]$Val = Get-PositionValueFromResolution
                $Null = New-ItemProperty -Path "$RegPath" -Name "WindowPosition" -PropertyType DWORD -Value $Val
            }
        }
      

        Remove-PSDrive HKU
    }catch{
        Write-Error "$_"
    }
}



function Install-BatchFileScriptTask {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RunFile,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$UserName
    )

    $action = New-ScheduledTaskAction -Execute "$RunFile"
    $TaskName = "Run {0} for {1} - Interactive" -f ((Get-Item $RunFile).Name), $UserName
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    
    $settings = New-ScheduledTaskSettingsSet -Priority 10
    
    $principal = New-ScheduledTaskPrincipal -UserID "$env:userdomain\$UserName" -LogonType Interactive -RunLevel Highest
    $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
    $Res=Register-ScheduledTask $TaskName -InputObject $task -User $username 

    Set-AppConsolePropertiesForAllUsers -Path "$RunFile"

    return "$TaskName"
}



function Install-EncodedScriptTask {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$EncodedTask,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$UserName
    )

    $EncodedTaskLen=$EncodedTask.Length
    Write-Host "Install-EncodedScriptTask called with taskname $TaskName. Code: EncodedTask ($EncodedTaskLen chars)"
    $PwExe = (Get-Command 'pwsh.exe').Source
    $action = New-ScheduledTaskAction -Execute "$PwExe" -Argument "-ExecutionPolicy Unrestricted -WindowStyle Hidden -EncodedCommand `"$EncodedTask`""
    $TaskName = "Run {0} for {1} - Interactive" -f ((Get-Item $RunFile).Name), $UserName
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    
    $settings = New-ScheduledTaskSettingsSet -Priority 10
    
    $principal = New-ScheduledTaskPrincipal -UserID "$env:userdomain\$UserName" -LogonType Interactive -RunLevel Highest
    $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
    $Res=Register-ScheduledTask $TaskName -InputObject $task -User $username 
    return "$TaskName"
}


function Execute {
    [CmdletBinding(SupportsShouldProcess)]
    param ()


    $XamppRoot = [Environment]::GetEnvironmentVariable('XAMPP_ROOT',  [EnvironmentVariableTarget]::Machine)
    if([string]::IsNullOrEmpty($XamppRoot)){
        if("$ENV:COMPUTERNAME" -match "DESKTOP"){ 
            $XamppRoot = "c:\xampp"
        }else{
            $XamppRoot = "e:\xampp"
        }
    }

    Get-ScheduledTask | Where TaskName -match "apache" | % {
        $tname = $_.TaskName 
        Write-Host "Deleting task `"$tname`"" -f Red
        $_ | Unregister-ScheduledTask -Confirm:$False
    }

    $RunFile="$XamppRoot\apache_start.exe"
    Write-Host "XamppRoot is `"$XamppRoot`""
    Write-Host "RunFile is `"$RunFile`""

    $AllLocalAcounts = Get-LocalUser | Where Enabled -eq $True | Select -ExpandProperty Name

    ForEach($user in $AllLocalAcounts){
        Write-Host "Create Scheduled Task for user `"$user`"" -f DarkYellow
        $TaskName = Install-BatchFileScriptTask -RunFile $RunFile -UserName "$user"
        #Start-ScheduledTask -TaskName "$TaskName"
    }

    <#
    $encodedTask="JABYAGEAbQBwAHAAUgBvAG8AdAAgAD0AIABbAEUAbgB2AGkAcgBvAG4AbQBlAG4AdABdADoAOgBHAGUAdABFAG4AdgBpAHIAbwBuAG0AZQBuAHQAVgBhAHIAaQBhAGIAbABlACgAJwBYAEEATQBQAFAAXwBSAE8ATwBUACcALAAgACAAWwBFAG4AdgBpAHIAbwBuAG0AZQBuAHQAVgBhAHIAaQBhAGIAbABlAFQAYQByAGcAZQB0AF0AOgA6AE0AYQBjAGgAaQBuAGUAKQANAAoAaQBmACgAWwBzAHQAcgBpAG4AZwBdADoAOgBJAHMATgB1AGwAbABPAHIARQBtAHAAdAB5ACgAJABYAGEAbQBwAHAAUgBvAG8AdAApACkAewANAAoAIAAgACAAIABpAGYAKAAiACQARQBOAFYAOgBDAE8ATQBQAFUAVABFAFIATgBBAE0ARQAiACAALQBtAGEAdABjAGgAIAAiAEQARQBTAEsAVABPAFAAIgApAHsAIAANAAoAIAAgACAAIAAgACAAIAAgACQAWABhAG0AcABwAFIAbwBvAHQAIAA9ACAAIgBjADoAXAB4AGEAbQBwAHAAIgANAAoAIAAgACAAIAB9AGUAbABzAGUAewANAAoAIAAgACAAIAAgACAAIAAgACQAWABhAG0AcABwAFIAbwBvAHQAIAA9ACAAIgBlADoAXAB4AGEAbQBwAHAAIgANAAoAIAAgACAAIAB9AA0ACgB9AA0ACgANAAoAJABIAHQAdABwAGQAUABhAHQAaAAgAD0AIAAiAHsAMAB9AFwAYQBwAGEAYwBoAGUAXABiAGkAbgBcAGgAdAB0AHAAZAAuAGUAeABlACIAIAAtAGYAIAAkAFgAYQBtAHAAcABSAG8AbwB0AA0ACgBpAGYAKAAtAG4AbwB0ACgAVABlAHMAdAAtAFAAYQB0AGgAIAAkAEgAdAB0AHAAZABQAGEAdABoACkAKQB7ACAAVwByAGkAdABlAC0ARQByAHIAbwByACAAIgBuAG8AdAAgAGYAbwB1AG4AZAAiACAAOwAgAHIAZQB0AHUAcgBuACAALQAxACAAOwAgAH0ADQAKAA0ACgBTAHQAYQByAHQALQBQAHIAbwBjAGUAcwBzACAALQBGAGkAbABlAFAAYQB0AGgAIAAiACQASAB0AHQAcABkAFAAYQB0AGgAIgAgAC0AVwBpAG4AZABvAHcAUwB0AHkAbABlACAASABpAGQAZABlAG4ADQAKAA0ACgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAIgBTAHQAYQByAHQAaQBuAGcAIABgACIAJABIAHQAdABwAGQAUABhAHQAaABgACIAIAAuAC4ALgAiACAALQBuAA0ACgA0ACAALgAuACAAMAAgAHwAIAAlACAAewAgAA0ACgAgACAAIAAgAFMAdABhAHIAdAAtAFMAbABlAGUAcAAgADEADQAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACIALgAiACAALQBuACAADQAKAH0A"

    ForEach($user in $AllLocalAcounts){
        Write-Host "Create Scheduled Task for user `"$user`"" -f DarkYellow
        $TaskName = Install-EncodedScriptTask -EncodedTask $encodedTask -UserName "$user"
        Start-ScheduledTask -TaskName "$TaskName"
    }

    #>

}
