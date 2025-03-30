#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   LoadBgInfo.ps1                                                               ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <guillaume.plante@luminator.com>                            ║
#║   Copyright (C) Luminator Technology Group.  All rights reserved.              ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function Load-BgInfo {
    [CmdletBinding(SupportsShouldProcess)]
    param (
      [Parameter(Mandatory = $False, Position=0)]
      [ValidateScript({ Test-Path -Path "$_" -PathType Leaf })]
      [string]$Destination = "$PSScriptRoot\MyBgInfo.bgi",
      [Parameter(Mandatory = $false)]
      [switch]$Popup,
      [Parameter(Mandatory = $false)]
      [switch]$Silent,
      [Parameter(Mandatory = $false)]
      [string]$LogFile,
      [Parameter(Mandatory = $false)]
      [ValidateRange(0,60)]
      [int]$Timer = 0
    )

    begin{
        [string]$Bginfo64Path = (Get-Command -Name "Bginfo64.exe").Source
        [string]$BginfoPath = (Get-Command -Name "Bginfo.exe").Source
    }
    process{
      try{
        [system.collections.arraylist]$arguments = [system.collections.arraylist]::new()

        [void]$arguments.Add($Destination)

        if(-not([string]::IsNullOrEmpty($LogFile)) ){
          $LogArg = "/LOG:`"{0}`"" -f $LogFile
          [void]$arguments.Add($LogArg)
        }
        
        $TimerArg = "/TIMER:{0}" -f $Timer
        [void]$arguments.Add($TimerArg)
        
        if($Silent){
          [void]$arguments.Add("/SILENT")
        }
        if($Popup){
          [void]$arguments.Add("/POPUP")
        }
        
        Write-Host "$Bginfo64Path $arguments" -f Cyan
        Start-Process $Bginfo64Path -ArgumentList $arguments -Verbose
      }catch{
        Show-ExceptionDetails ($_) -ShowStack
      }
    }
}

