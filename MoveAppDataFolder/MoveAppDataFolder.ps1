
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param()



function Set-NewAppDataValues{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory=$false)]
        [string]$ReplaceString = 'E:\Users\gp\AppData',
        [Parameter(Mandatory=$false)]
        [switch]$TestOnly
    )
    
    $Props = Get-Item "$RegPath"

    $AllProperties = $Props.Property

    [System.Collections.ArrayList]$ToChange = [System.Collections.ArrayList]::new()
    ForEach($p in $AllProperties){
        $Value = Get-ItemPropertyValue -Path $RegPath -Name "$p"
        $ValueSmall = $Value.ToLower()
        if($ValueSmall.Contains('f:\users\gp\appdata')){
            [void]$ToChange.Add($p)
        }
    }

    $ToChangeCount = $ToChange.Count
    if($ToChangeCount -eq 0){
        Write-Host "Found ZERO items to change." -f DarkGreen
        return;
    }
    Write-Host "Found $ToChangeCount items to change." -f DarkYellow
    Write-Host "$RegPath" -f DarkRed
    ForEach($p in $ToChange){
        [string]$Value = Get-ItemPropertyValue -Path $RegPath -Name "$p"
        [string]$ValToChange = $Value.Substring(0,19)
        
        $NewValue = $Value.Replace($ValToChange, $ReplaceString)
        try{
            if($TestOnly){
                Write-Host "  -> [$p]" -f DarkCyan -n 
                Write-Host " `"$NewValue`"" -f DarkGray
            }else{
                Set-ItemProperty -Path $RegPath -Name "$p" -Value "$NewValue" -Force -ErrorAction Stop 
                Write-Host "  -> [$p]"
                Write-Host " DONE " -f DarkRed
            }
        }catch{
            Write-Warning "ERROR $_"
        }
    }
}


$RegPath1 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
$RegPath2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
Set-NewAppDataValues $RegPath1 -TestOnly 
Set-NewAppDataValues $RegPath2 -TestOnly 

Read-Host "READY?"
Set-NewAppDataValues $RegPath1  
Set-NewAppDataValues $RegPath2  