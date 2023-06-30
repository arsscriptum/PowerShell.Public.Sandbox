
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $True, Position = 0, HelpMessage="Run for x seconds")] 
    [string]$Path
)

function Set-DeployError {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0)] 
        [string]$Message
    )
    Write-Output "================================================================"
    Write-Output "                             ERROR                              "
    Write-Output "================================================================"
    Write-Output "$Message"
    Write-Output "================================================================"
    exit -1
}
New-Alias -Name "logerr" -Value "Set-DeployError" -Force -ErrorAction Ignore | Out-Null


function Get-RootDirectory {
    Split-Path -Parent (Split-Path -Parent $PSCommandPath)
}

function Get-ScriptDirectory {
    Split-Path -Parent $PSCommandPath
}

$Script:ScriptsDirectory = Get-ScriptDirectory
$Script:RootDirectory = Get-RootDirectory
$Script:DllDirectory = Join-Path $Script:RootDirectory $Path
$Script:TestDirectory = Join-Path $Script:RootDirectory "test"
$Script:TestLibDirectory = Join-Path $Script:TestDirectory "lib"
$Script:TestLoadingDirectories = Join-Path $Script:TestDirectory "loading"

Remove-Item "$Script:TestLoadingDirectories" -Recurse -Force -ErrorAction Ignore | Out-Null


Write-Output "================================================================"
Write-Output "                            Deploy                              "
Write-Output "================================================================"


Write-Output "ScriptsDirectory $Script:ScriptsDirectory"
Write-Output "RootDirectory    $Script:RootDirectory"
Write-Output "DllDirectory     $Script:DllDirectory"

if(-not(Test-Path -Path "$Script:DllDirectory" -PathType Container)){
    logerr "Invalid Dll Path `"$Script:DllDirectory`""
}

Remove-Item "$Script:TestLibDirectory" -Recurse -Force -ErrorAction Ignore | Out-Null
New-Item "$Script:TestLibDirectory" -ItemType directory -Force -ErrorAction Ignore | Out-Null

ForEach($files in (gci "$Script:DllDirectory" -File -Filter "*.dll")){
    $fn = $files.Fullname
    $Copied = Copy-Item "$fn" "$Script:TestLibDirectory" -Force -Passthru
    Write-Output "Copied `"$fn`" => `"$Copied`""
}

exit 0