
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



$DummyJobScript = {
      param($RunForSeconds)
  
    try{
        Write-Output "=============== JOB STARTED ==============="
        [Datetime]$StopTime = [Datetime]::Now.AddSeconds($RunForSeconds)
        $Running = $True
        While($Running){
            $tspan = new-timespan ([Datetime]::Now) ($StopTime)
            $RemainingSeconds = $tspan.Seconds
            [int]$PercentComplete = [math]::Round( 100 * ( $RemainingSeconds /  $RunForSeconds) )
            $strout = "[{0:d2} %] .... .... .... .... .... .... [{1:d2} %]" -f $PercentComplete,$PercentComplete
            Write-Output $strout
            Start-Sleep 1
            if([Datetime]::Now -gt $StopTime){
                Write-Output "============== JOB COMPLETED =============="
                $Running = $False
            }
        }
    }catch{
        Write-Error $_ 
    }finally{
        Write-Verbose "============== JOB COMPLETED =============="
}}.GetNewClosure()

[scriptblock]$DummyJobScriptBlock = [scriptblock]::create($DummyJobScript) 



function Invoke-DummyJob{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0, HelpMessage="Run for x seconds")] 
        [int]$Seconds,
        [Parameter(Mandatory = $false,Position=1, HelpMessage="The estimated time the process will take")]
        [int]$EstimatedSeconds=0,
        [Parameter(Mandatory = $False,Position=2, HelpMessage="The size of the progress bar")] 
        [int]$Size=30,
        [Parameter(Mandatory = $False,Position=3, HelpMessage="Update delay")] 
        [int]$Update=100,
        [Parameter(Mandatory = $False,Position=4)] 
        [switch]$ProgressIndicator
    )
    try{

        Register-NativeProgressBar -Size $Size
        
        $Script:LatestPercentage = 0
        [regex]$pattern = [regex]::new('([\[]+)(?<percent>[\d]+)([\%\ \]]+)')
        $JobName = "DummyJob"
        $Working = $True
        $jobby = Start-Job -Name $JobName -ScriptBlock $DummyJobScriptBlock -ArgumentList ($Seconds)
        while($Working){
            try{
            
                    $Data = Receive-Job -Name $JobName | Select -Last 1
                    if($Data -match $pattern){
                        [int]$percent = $Matches.percent
                        [int]$percent = 100 -$percent
                        $Script:LatestPercentage = $percent
                    }
                     $ProgressMessage = "Completed {0} %" -f $percent
                     Write-NativeProgressBar $Script:LatestPercentage $ProgressMessage 50 2 "White" "DarkGray"
                

                $JobState = (Get-Job -Name $JobName).State

                Write-verbose "JobState: $JobState"
                if($JobState -eq 'Completed'){
                    $Working = $False
                }

            }catch{
                Write-Error $_
            }
        }
        
        $Data = Receive-Job -Name $JobName
        Get-Job $JobName | Remove-Job
        #$Data 
     }catch{
        Show-ExceptionDetails $_ -ShowStack 
    }
}

