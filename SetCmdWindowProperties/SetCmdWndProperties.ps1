<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

function Get-CurrentDisplayResolution{
   [CmdletBinding(SupportsShouldProcess)]
   param()

    Add-Type -AssemblyName  System.Windows.Forms
    $CurrentRes=[System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $Resolution = [PsCustomObject]@{
         Width = $CurrentRes.Width
         Height = $CurrentRes.Height
       
    }
    $Resolution
}


function Get-DisplayResolutionList{
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



function Get-ConvertedCoordValue{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [int32]$PosX,
        [Parameter(Mandatory=$True, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [int32]$PosY,
        [Parameter(Mandatory=$false)]
        [switch]$Hex
    )

       $HexWidth = ([System.Convert]::ToString($PosX,16).PadLeft(4,'0'))
       $HexHeight = ([System.Convert]::ToString($PosY,16).PadLeft(4,'0'))

       $FinalHexVal = '0x{0}{1}' -f $HexHeight,$HexWidth
       Write-Verbose "Final Hex Value   $FinalHexVal"
       
       if($Hex){
          return $FinalHexVal
       }
       $NumValue = [Int32]"$FinalHexVal"
       
       return $NumValue
}


function Set-AppConsoleProperties {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory=$True, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [int32]$PosX,
        [Parameter(Mandatory=$True, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [int32]$PosY,
        [Parameter(Mandatory=$True, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [int32]$SizeX,
        [Parameter(Mandatory=$True, Position = 4)]
        [ValidateNotNullOrEmpty()]
        [int32]$SizeY
    )
    try{
        if(-not(Test-Path "$Path")){ throw "no such file"}
        $ModPath = $Path.Replace("\","_")
        $RegPath = "HKCU:\Console\{0}" -f $ModPath
        $Null = New-Item -Path "$RegPath" -Force -ErrorAction Ignore

        [int32]$SizeValue = Get-ConvertedCoordValue $SizeX $SizeY
        $Null = New-ItemProperty -Path "$RegPath" -Name "WindowSize" -PropertyType DWORD -Value $SizeValue

        [int32]$PositionValue = Get-ConvertedCoordValue $PosX $PosY
        $Null = New-ItemProperty -Path "$RegPath" -Name "WindowPosition" -PropertyType DWORD -Value $PositionValue
    }catch{
        Write-Error "$_"
    }
}



function Set-AppConsoleProperties {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory=$True, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [int32]$PosX,
        [Parameter(Mandatory=$True, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [int32]$PosY,
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



function Get-FarPositionValueFromResolution{
       [CmdletBinding(SupportsShouldProcess)]
       param()

       $Width = (Get-CurrentDisplayResolution).Width
       $Height = (Get-CurrentDisplayResolution).Height
       Write-Verbose "From Resolution: Width $Width"
       Write-Verbose "From Resolution: Height $Height"
       $Width = $Width - 4 
       $Height = $Height - 4
       $HexWidth = ([System.Convert]::ToString($Width,16).PadLeft(4,'0'))
       $HexHeight = ([System.Convert]::ToString($Height,16).PadLeft(4,'0'))
       Write-Verbose "Width $Width. $HexWidth"
       Write-Verbose "Height $Height. $HexHeight"

       $FinalHexVal = '0x{0}{1}' -f $HexHeight,$HexWidth
       Write-Verbose "Final Hex Value   $FinalHexVal"
       
       $NumValue = [Int32]"$FinalHexVal"
       Write-Verbose "Decimal Value     $NumValue"
       $NumValue
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
