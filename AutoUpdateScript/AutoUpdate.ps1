<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

$test=0
function Invoke-AutoUpdate{
    [CmdletBinding(SupportsShouldProcess)]
    param() 

    begin{
      try{
        $GitCmd = (Get-Command "git.exe")
        if($Null -eq $GitCmd){ throw "git.exe not found" }
        $GitExe = $GitCmd.Source
        $ScriptPath = "$PSCommandPAth"
        if(-not(Test-Path -Path "$ScriptPath")){ throw "file not found" }
      }catch{
        write-error "$_"
      }
    }
    process{
      try{
        $Output = & "$GitExe" 'fetch' | Out-Null
        $HeadRev = & "$GitExe"  'log' '-n' '1' '--no-decorate' '--pretty=format:%H'  "$ScriptPath"
        
        [uint32]$NewVers = & "$GitExe" 'diff' 'remotes/origin/master..master'  "$ScriptPath" | Measure-Object -Line | Select -ExpandProperty Lines
        if($NewVers -gt 0){
            Write-Host "A new version is available for `"$ScriptPath`"" -f Cyan
            Write-Host "Head Rev: `"$HeadRev`"" -f Yellow
        }else{
             Write-Host "No updates for `"$ScriptPath`"" -f Yellow
             Write-Host "Head Rev: `"$HeadRev`"" -f Yellow
        }


      }catch{
        write-error "$_"
      }
    }
}

 Invoke-AutoUpdate