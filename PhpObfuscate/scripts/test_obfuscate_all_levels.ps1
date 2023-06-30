<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param()

$Src = "$PSScriptRoot\..\index.php"
$ObfuscatedPath = "$PSScriptRoot\..\obfuscated"
$Dst = "$PSScriptRoot\..\obfuscated\index.php"
$Src = (Resolve-Path "$Src").Path
$Dst = (Resolve-Path "$Dst").Path
$ObfuscatedPath = (Resolve-Path "$ObfuscatedPath").Path
New-Item -Path "$ObfuscatedPath\test" -ItemType Directory -Force -ErrorAction Ignore | Out-Null

$OutDir = (Resolve-Path "$ObfuscatedPath\test").Path

$ObfuscateScripts = "$PSScriptRoot\obfuscate.ps1"
$ObfuscateScripts = (Resolve-Path "$ObfuscateScripts").Path

. "$ObfuscateScripts"

$Cmd = Get-Command "Invoke-AraxisCompare"
$FileClear = (Resolve-Path "..\index.php").Path

$Dst = Join-Path "$OutDir" "Level1.php"

$Out = Invoke-PhpObfuscator $Src $Dst -RemoveComments -ObfuscateVariables 

Write-Host "[OBFUSCATION] " -f DarkYellow -n 
Write-Host "Operation Completed. `"$Out`"" -f DarkGray

$FileCoded = (Resolve-Path "$Out").Path

if($Cmd -ne $Null){
    Invoke-AraxisCompare -FileA "$FileClear" -FileB "$Out"
}

Read-Host "Press a Key to Test Level 2"


$Dst = Join-Path "$OutDir" "Level2.php"

$Out = Invoke-PhpObfuscator $Src $Dst -RemoveComments -ObfuscateVariables -EncodeStrings 
Write-Host "[OBFUSCATION] " -f DarkYellow -n 
Write-Host "Operation Completed. `"$Out`"" -f DarkGray

$FileCoded = (Resolve-Path "$Out").Path

if($Cmd -ne $Null){
    Invoke-AraxisCompare -FileA "$FileClear" -FileB "$Out"
}

Read-Host "Press a Key to Test Level 3"


$Dst = Join-Path "$OutDir" "Level3.php"

$Out = Invoke-PhpObfuscator $Src $Dst -RemoveComments -ObfuscateVariables -EncodeStrings -UseHexValuesForNames -RemoveWhitespaces
Write-Host "[OBFUSCATION] " -f DarkYellow -n 
Write-Host "Operation Completed. `"$Out`"" -f DarkGray

$FileCoded = (Resolve-Path "$Out").Path

if($Cmd -ne $Null){
    Invoke-AraxisCompare -FileA "$FileClear" -FileB "$Out"
}

Read-Host "Press a Key to Test Level 4"
$Dst = Join-Path "$OutDir" "Level4.php"

$Out = Invoke-PhpObfuscator $Src $Dst -RemoveComments -ObfuscateVariables -EncodeStrings -UseHexValuesForNames -RemoveWhitespaces -RenameFunctions -RenamingMethod "MD5" -Md5Length 24 -PrefixLength 8
Write-Host "[OBFUSCATION] " -f DarkYellow -n 
Write-Host "Operation Completed. `"$Out`"" -f DarkGray

$FileCoded = (Resolve-Path "$Out").Path

if($Cmd -ne $Null){
    Invoke-AraxisCompare -FileA "$FileClear" -FileB "$Out"
}
