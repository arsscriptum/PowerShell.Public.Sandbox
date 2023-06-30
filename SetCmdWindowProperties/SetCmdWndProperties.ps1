<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



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

       $MaxResHor = (Get-CurrentResolution | Select -ExpandProperty Horizontal | Measure-Object -Maximum).Maximum
       $MaxResVer = (Get-CurrentResolution | Select -ExpandProperty Vertical | Measure-Object -Maximum).Maximum
       Write-Verbose "From Resolution: ResHor $MaxResHor"
       Write-Verbose "From Resolution: ResVer $MaxResVer"
       $MaxResHor = $MaxResHor - 4 
       $MaxResVer = $MaxResVer - 4
       $HexHor = ([System.Convert]::ToString($MaxResHor,16).PadLeft(4,'0'))
       $HexVer = ([System.Convert]::ToString($MaxResVer,16).PadLeft(4,'0'))
       Write-Verbose "MaxResHor $MaxResHor. $HexHor"
       Write-Verbose "MaxResVer $MaxResVer. $HexVer"

       $FinalHexVal = '0x{0}{1}' -f $HexVer,$HexHor
       Write-Verbose "Final Hex Value   $FinalHexVal"
       
       $NumValue = [Int32]"$FinalHexVal"
       Write-Verbose "Decimal Value     $NumValue"
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
