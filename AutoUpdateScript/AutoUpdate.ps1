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
        $HeadRev1 = & "$GitExe" 'log' '-n' '1' '--pretty=format:%H' '--' "$ScriptPath"
        $HeadRev2 = & "$GitExe"  'rev-parse' '@{u}'
        $HeadRev3 = & "$GitExe" 'log' '--format=%H' '-1' | select -Last 1
        $LastRev = & "$GitExe" 'log' '--format=%H' '-2' | select -Last 1

        Write-Host "Head Rev1: `"$HeadRev1`""
        Write-Host "Head Rev2: `"$HeadRev2`""
        Write-Host "Head Rev3: `"$HeadRev3`""
        Write-Host "Last Rev: `"$LastRev`""
      }catch{
        write-error "$_"
      }
    }
}

 Invoke-AutoUpdate