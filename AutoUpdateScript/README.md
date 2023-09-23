# Auto Update for PowerShell scripts

This script will check the remote repository to se if there's a new version of he current script file, if so, it will update it and re-run it.

Initializaton, get the git exe path and the current script path

```
  $GitCmd = (Get-Command "git.exe")
  if($Null -eq $GitCmd){ throw "git.exe not found" }
  $GitExe = $GitCmd.Source
  $ScriptPath = "$PSCommandPath"
```

Get the branches names for the local and the remote branch...


``
  $RemoteBranch = & "$GitExe" 'for-each-ref' '--format=%(upstream:short)' "`"$(git symbolic-ref -q HEAD)`""
  $LocalBranch  = & "$GitExe" 'branch' '--show-current'
``


Get the current number of new revisions available, 0 if we are up to date

```
  [uint32]$NewVers = & "$GitExe" 'diff' "$RemoteBranch..$LocalBranch"  "$ScriptPath" | Measure-Object -Line | Select -ExpandProperty Lines
```

## How to test

1. Clone the repo at 2 different locations
2. Update the AutoUpdate.ps1 script in one location (location 1) and ```commit/push```
3. Go to location #2, and run ```. .\AutoUpdate.ps1```

You will get this:

```
  > . .\AutoUpdate.ps1

  This script was updated and will restart.
  Hello World
```