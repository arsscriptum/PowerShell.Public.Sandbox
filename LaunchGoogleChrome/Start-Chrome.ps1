
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

	[CmdletBinding(SupportsShouldProcess)]
    param (
        [parameter(Mandatory=$false)]
        [switch]$Test,
        [parameter(Mandatory=$false)]
        [switch]$Kill,
        [parameter(Mandatory=$false)]
        [string]$SslKeyLogFile
    )

try{
	$TaskKill = (Get-Command 'taskkill.exe').Source
	$ChromePath = Get-ChromePath
	$DumpSslKeys = ([string]::IsNullOrEmpty($SslKeyLogFile) -eq $False)
    $TestMode = $False        
    if ( ($PSBoundParameters.ContainsKey('WhatIf') -Or $Test) ){         
        $TestMode = $True
    }

    if(( $Kill ) -Or ( $DumpSslKeys )){
    	$list = Invoke-PsList "chrome"
    	if($list -ne $Null){
        	Write-Host "[WARNING] " -n -f DarkRed; 
        	Write-Host "Will Kill $($list.Count) Chrome processes. OK ?" -n -f DarkYellow;
        	$a = Read-Host "?"
        	if($a -ne 'y'){
        		Write-Host "Cancelled" -f Red 
        		return; 
        	} 
        	$KilledPs = &"$TaskKill" "/IM" "chrome.exe" "/F"
    	}
    }
    if($DumpSslKeys){
        Write-Host "[WARNING] " -n -f DarkRed; 
        Write-Host "Enabling SSL Keys Dump at location `"$SslKeyLogFile`" " -f DarkYellow; 
    	New-Item -Path "$SslKeyLogFile" -ItemType 'File' -Force  -ErrorAction Ignore | Out-null
    	$Null = Set-EnvironmentVariable -Name "SSLKEYLOGFILE" -Value "$SslKeyLogFile" -Scope Session
    }else{
    	$Null = Set-EnvironmentVariable -Name "SSLKEYLOGFILE" -Value "$Null" -Scope Session
    }

    &"$ChromePath" "--force-dark-mode"
    
}catch{
    Write-Error "$_"
}

