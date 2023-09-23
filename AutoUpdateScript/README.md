# Auto Update for PowerShell scripts

This script will check the remote repository to se if there's a new version of he current script file, if so, it will update it and re-run it.

Initializaton, get the git exe path and the current script path

```powershell
  $GitCmd = (Get-Command "git.exe")
  if($Null -eq $GitCmd){ throw "git.exe not found" }
  $GitExe = $GitCmd.Source
  $ScriptPath = "$PSCommandPath"
```

Get the branches names for the local and the remote branch...


```powershell
  $RemoteBranch = & "$GitExe" 'for-each-ref' '--format=%(upstream:short)' "`"$(git symbolic-ref -q HEAD)`""
  $LocalBranch  = & "$GitExe" 'branch' '--show-current'
```


Check if a new revision is available. Do this by diffing the local branch with the remote branch.


```powershell
  [uint32]$NewVers = & "$GitExe" 'diff' "$RemoteBranch..$LocalBranch"  "$ScriptPath" | Measure-Object -Line | Select -ExpandProperty Lines
```

## How to test

1. Fork the repo
1. Clone the forked repo at 2 different locations on your drive
2. Update the AutoUpdate.ps1 script in one location (location 1) and ```commit/push```
3. Go to location #2, and run ```. .\AutoUpdate.ps1```

You will get this:

```powershell
  > . .\AutoUpdate.ps1

  This script was updated and will restart.
  Hello World
```