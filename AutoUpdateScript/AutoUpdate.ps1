<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param() 

$test=0
function Test-NewScriptVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param() 

    begin{
      try{
        $GitCmd = (Get-Command "git.exe")
        if($Null -eq $GitCmd){ throw "git.exe not found" }
        $GitExe = $GitCmd.Source
        $ScriptPath = "$PSCommandPath"
        if(-not(Test-Path -Path "$ScriptPath")){ throw "file not found" }
      }catch{
        write-error "$_"
      }
    }
    process{
      try{
        $Output = & "$GitExe" 'fetch' *> "$ENV:Temp\gitout.txt" | Out-Null
        $HeadRev = & "$GitExe"  'log' '-n' '1' '--no-decorate' '--pretty=format:%H'  "$ScriptPath"
        $Ret = $False
        [uint32]$NewVers = & "$GitExe" 'diff' 'remotes/origin/master..master'  "$ScriptPath" | Measure-Object -Line | Select -ExpandProperty Lines
        if($NewVers -gt 0){
            Write-Verbose "A new version is available for `"$ScriptPath`"" 
            Write-Verbose "Head Rev: `"$HeadRev`""
            $Ret = $True
            
        }else{
             Write-Verbose "No updates for `"$ScriptPath`"" 
             Write-Verbose "Head Rev: `"$HeadRev`"" 
        }

        $Ret
      }catch{
        write-error "$_"
      }
    }
}


function Update-ScriptVersion{
    [CmdletBinding(SupportsShouldProcess)]
    param() 

    begin{
      try{
        $GitCmd = (Get-Command "git.exe")
        if($Null -eq $GitCmd){ throw "git.exe not found" }
        $GitExe = $GitCmd.Source
        $ScriptPath = "$PSCommandPath"
        if(-not(Test-Path -Path "$ScriptPath")){ throw "file not found" }
        $DirName = (Get-Item -PAth "$ScriptPath").DirectoryName
      }catch{
        write-error "$_"
      }
    }
    process{
      try{
        pushd "$DirName"
        $Output = & "$GitExe" 'pull' > "$ENV:Temp\gitout.txt" | Out-Null
        popd
      }catch{
        write-error "$_"
      }
    }
}


$NewVersionAvailable = Test-NewScriptVersion
if($NewVersionAvailable){
    Update-ScriptVersion

    Write-Host "This script was updated and will restart."
    Start-Sleep 1
    . "$ScriptPath"
    # Start-Process pwsh.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath)
    Exit
}


Write-Host "Hello World" -f DArkYellow