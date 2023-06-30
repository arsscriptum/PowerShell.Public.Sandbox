
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param()


function Get-RootDirectory {
    Split-Path -Parent (Split-Path -Parent $PSCommandPath)
}

function Get-ScriptDirectory {
    Split-Path -Parent $PSCommandPath
}


function Install-PSKill{
    $psKillPath = Join-Path "$ENV:Temp\sysinternals" "pskill.exe"
    if(Test-Path $psKillPath){
        return $psKillPath
    }
    if(Test-Path "$ENV:PsKillPath"){
        return "$ENV:PsKillPath"
    }
    Invoke-WebRequest -Uri "https://download.sysinternals.com/files/PSTools.zip" -OutFile "$ENV:Temp\PSTools.zip"
    Expand-Archive "$ENV:Temp\PSTools.zip" "$ENV:Temp\sysinternals"
    if(Test-Path $psKillPath){
        [System.Environment]::SetEnvironmentVariable('PsKillPath',$psKillPath,[System.EnvironmentVariableTarget]::User)
        return $psKillPath
    }
    return ""
}

function Get-PSKillPath{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
        [switch]$Install        
    )
    $psKillPath = Join-Path "$ENV:Temp\sysinternals" "pskill.exe"

    if($Install){
        $psKillPath = Install-PSKill
    }
    
    if(Test-Path $psKillPath){
        return $psKillPath
    }
    if(Test-Path "$ENV:PsKillPath"){
        return "$ENV:PsKillPath"
    }
    $PsKillCmd=Get-Command 'pskill.exe'
    if($PsKillCmd){
        return "$($PsKillCmd.Source)"
    } 
    return ""
}


function Stop-PowerShellProcesses{

    [CmdletBinding(SupportsShouldProcess)]
    param()

    $PkCmd=Get-Command 'pk.exe'
    $TkCmd=Get-Command 'taskkill.exe'
    $PSKillPath=Get-PSKillPath -Install
    if($TkCmd){
        # instead, let's try and kill powershell using these lines
        $taskkill_path = (Get-command 'taskkill.exe').Source
        $taskkill_arguments = [system.collections.arraylist]::new()
        $log = "$taskkill_path "
        if(Test-PAth $taskkill_path){
            $PwshProcesses = get-process | Where Name -match "pwsh"
            ForEach($id in $PwshProcesses.Id){
                [void]$taskkill_arguments.Add("/PID")
                [void]$taskkill_arguments.Add("$id")
                $log += "/PID $id "
            }
            [void]$taskkill_arguments.Add("/T")
            $log += "/T"
        }
        Write-Host "Runnning: `n`"$log`"" -f Red
        Start-Process -FilePath $taskkill_path -ArgumentList $taskkill_arguments -NoNewWindow -Wait
    }

    if([string]::IsNullOrEmpty($PSKillPath) -eq $False){
        Write-Host "`"$PSKillPath`" `"pwsh`"" -f Red
        & "$PSKillPath" "pwsh"
    }    
    if($PkCmd){
        Write-Host "`"$($PkCmd.Source)`" `"pwsh`"" -f Red
        & "$($PkCmd.Source)" "pwsh"
    }
}

$Script:ScriptsDirectory = Get-ScriptDirectory
$Script:RootDirectory = Get-RootDirectory
$Script:DllDirectory = Join-Path $Script:RootDirectory $Path
$Script:ToolsDirectory = Join-Path $Script:RootDirectory "tools"
$Script:TestDirectory = Join-Path $Script:RootDirectory "test"
$Script:TestLoadingDirectories = Join-Path $Script:TestDirectory "loading"


#Stop-PowerShellProcesses

Remove-Item "$Script:TestLoadingDirectories" -Recurse -Force -ErrorAction Ignore | Out-Null

exit 0