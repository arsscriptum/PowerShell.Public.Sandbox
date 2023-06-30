[CmdletBinding(SupportsShouldProcess)]
param()

Set-Content "$PSScriptRoot\..\obfuscated\coded.php" -Value "placeholder" -Force
$Src = "$PSScriptRoot\..\php\index.php"
$Dst = "$PSScriptRoot\..\obfuscated\coded.php"

$Src = (Resolve-Path "$Src").Path
$Dst = (Resolve-Path "$Dst").Path
$OutDir = (Get-Item $Dst).DirectoryName

$ObfuscateScript = "$PSScriptRoot\obfuscate.ps1"
$ObfuscateScript = (Resolve-Path "$ObfuscateScript").Path

. "$ObfuscateScript"

$Out = Invoke-PhpObfuscator $Src $Dst -RenameFunctions -RemoveComments -RenamingMethod "MD5" -ObfuscateVariables -EncodeStrings -UseHexValuesForNames -RemoveWhitespaces -Md5Length 24 -PrefixLength 8

Write-Host "[OBFUSCATION] " -f DarkYellow -n 
Write-Host "Operation Completed. `"$Out`"" -f DarkGray

Copy-Item $Src "..\index.php" -Force
Copy-Item $Out "..\coded.php" -Force

$FileClear = (Resolve-Path "..\index.php").Path
$FileCoded = (Resolve-Path "..\coded.php").Path


$Cmd = Get-Command "Invoke-AraxisCompare"
if($Cmd -ne $Null){
    Invoke-AraxisCompare -FileA "$FileClear" -FileB "$FileCoded"
}
