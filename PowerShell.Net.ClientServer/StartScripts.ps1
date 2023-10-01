<#
#̷𝓍    𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍    Platform Invoke (P/Invoke) for 🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 
#̷𝓍    🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



function Register-NetServ{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $CsSource = (Join-Path "$PSScriptRoot" "serv.cs")  
    
    if (!("SimpleNet.NetServ" -as [type])) {
        Write-Verbose "Registering $CsSource... " 
        Add-Type -Path "$CsSource"
    }else{
        Write-Verbose "SimpleNet.NetServ already registered: $CsSource... " 
    }
}


function Register-NetCli{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $CsSource = (Join-Path "$PSScriptRoot" "clnt.cs")  
    
    if (!("SimpleNet.NetServ" -as [type])) {
        Write-Verbose "Registering $CsSource... " 
        Add-Type -Path "$CsSource"
    }else{
        Write-Verbose "SimpleNet.NetServ already registered: $CsSource... " 
    }
}


function Start-NetClient{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory = $True)]
        [string]$IpAddress,
        [Parameter(Position = 1, Mandatory = $True)]
        [uint32]$Port
    )
    Register-NetCli
    [SimpleNet.NetServ]::StartCli($IpAddress,$Port)
}


function Start-NetServer{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory = $True)]
        [uint32]$Port 
    )
    Register-NetServ
    [SimpleNet.NetServ]::StartServer("127.0.0.1",$Port)
}

