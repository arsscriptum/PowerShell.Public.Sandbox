
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $True, Position = 0, HelpMessage="Run for x seconds")] 
    [int]$Seconds,
    [Parameter(Mandatory = $false)] 
    [switch]$AutoStart
)


function Test-NativeProgressModuleDependencies{

    [CmdletBinding(SupportsShouldProcess)]
    param() 
      
    Write-Host "================================================================" -f DarkYellow
    Write-Host "                      Checking Dependencies                     " -f DarkRed
    Write-Host "================================================================" -f DarkYellow

    $FunctionDependencies = @( 'Register-NativeProgressBar', 'Unregister-NativeProgressBar', 'Write-NativeProgressBar' )

    try{
        Write-Host "[TEST] " -f Blue -NoNewLine
        Write-Host "CHECKING FUNCTION DEPENDENCIES..."
        $FunctionDependencies.ForEach({
            $Function=$_
            $FunctionPtr = Get-Command "$Function" -ErrorAction Ignore
            if($FunctionPtr -eq $null){
                throw "ERROR: MISSING $Function function. Please import the required dependencies"
            }else{
                Write-Host "`t[OK]`t" -f DarkGreen -NoNewLine
                Write-Host "$Function"
            }
        })
        Write-Host "================================================================" -f DarkYellow
        Write-Host "[SUCCESS]" -f DarkGreen -NoNewLine
        Write-Host " All Functions Dependencies are validated"
        Write-Host "================================================================" -f DarkYellow
    }catch [Exception]{
        Write-Error $_ 
        $Script:FatalError = $True
    }
}


function Start-NativeProgressTest{

    [CmdletBinding(SupportsShouldProcess)]
    param() 

    try{
       
        Write-Host "================================================================" -f DarkYellow
        Write-Host "                        Starting TestJobs                       " -f DarkRed
        Write-Host "================================================================" -f DarkYellow


        $JobCount = (Get-Job).Count

        Get-Job | % { $n = $_.Name ;  Write-Host "$n " -n -f Red;Remove-Job $_ -Force ; }

        Write-Host "TEST 1 - Progress Indicator"
        Invoke-DummyJob $Seconds $Seconds 40 50
        Write-Host "`n"

    }catch [Exception]{
        Write-Error $_ 
        $Script:FatalError = $True
    }
}





Write-Host "================================================================" -f DarkYellow
Write-Host "                        IMPORTING SCRIPTS                       " -f DarkRed
Write-Host "================================================================" -f DarkYellow

$FatalError = $False
try{
    $InitScript = "$PSScriptRoot\Initialize-Test.ps1"
    $JobScript  = "$PSScriptRoot\JobScriptDefinition.ps1"
    if(Test-Path $InitScript){
        . "$InitScript"
        Write-Host "`t[OK]`t" -f DarkGreen -NoNewLine
        Write-Host "Initialization Script from `"$InitScript`""
    }else{
        throw "No such file `"$InitScript`""
    }
    if(Test-Path $JobScript){
        . "$JobScript"
        Write-Host "`t[OK]`t" -f DarkGreen -NoNewLine
        Write-Host "Job Definition Script from `"$JobScript`""

    }else{
        throw "No such file `"$JobScript`""
    }
}catch{
    Write-Error "Initialization Error. $_"
    $Script:FatalError = $True
}

if($Script:FatalError){
    Write-Host "Fatal Error: Exiting." -f Red
    return
}



if($AutoStart){
    Test-NativeProgressModuleDependencies
    if($Script:FatalError){
        Write-Host "Fatal Error: Exiting." -f Red
        return
    }

    Write-Host "`n`n"
    Write-Host "================================================================" -f DarkYellow
    Write-Host "                      PRESS A KEY TO START                      " -f DarkRed
    Write-Host "================================================================" -f DarkYellow

    Read-Host " . "
    cls
    Start-NativeProgressTest
}
