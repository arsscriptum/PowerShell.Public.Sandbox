<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>




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
        & "$GitExe" 'fetch'
        $LastRev = & "$GitExe" 'log' '-n' '1' '--pretty=format:%H' '--' "$ScriptPath"
        $HeadRev = & "$GitExe"  'rev-parse' '@{u}' '--' "$ScriptPath"
        $HeadRev2 = & "$GitExe"  'log' '-n' '1' '--no-decorate' '--pretty=format:%H'  "$ScriptPath"
        Write-Host "Head Rev: `"$HeadRev`""
        Write-Host "Last Rev: `"$LastRev`""
      }catch{
        write-error "$_"
      }
    }
}

 Invoke-AutoUpdate