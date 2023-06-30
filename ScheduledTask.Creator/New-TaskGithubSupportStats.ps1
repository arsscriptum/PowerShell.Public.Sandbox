

function New-CustomScheduledTask{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, HelpMessage="TaskName", Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String]$TaskName,
        [Parameter(Mandatory=$true, HelpMessage="Command", Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]$Command,
        [Parameter(Mandatory=$false, HelpMessage="Description")]
        [String]$Description
    )    
    try{
	  	$bytes = [System.Text.Encoding]::Unicode.GetBytes($Command)
	  	$encodedCommand = [Convert]::ToBase64String($bytes)
		#Create the even trigger like so:

		$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(5) -RepetitionInterval (New-TimeSpan -Hour 1)

		$taskAction = New-ScheduledTaskAction -Execute 'C:\Programs\PowerShell\7\pwsh.exe' -Argument "-nop -noni -w hidden -encodedcommand $encodedCommand"

		# Register the scheduled task
		Register-ScheduledTask -TaskName $TaskName -Action $taskAction -Trigger $trigger -Description $Description

    }catch{
        Write-Error "$_"
    }
}


$Command = @"
 Import-Module "PowerShell.Module.Core"
 Import-Module "PowerShell.Module.Github"
 Save-GithubSupportStats
"@

$TaskPath = "\DevelopmentTasks\"
$TaskName = "GitHubStats"
$FullTaskId = "{0}{1}" -f $TaskPath, $TaskName 
# Describe the scheduled task.
$Description = "GitHubStats Event: save stats from repo"

UnRegister-ScheduledTask -TaskName $TaskName
New-CustomScheduledTask $FullTaskId $Command -Description $Description