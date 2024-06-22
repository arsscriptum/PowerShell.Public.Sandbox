#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   Install-XamppServer.ps1                                                      ║
#║   Installer Script for XAMPP                                                   ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <guillaume.plante@luminator.com>                            ║
#║   Copyright (C) Luminator Technology Group.  All rights reserved.              ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function Get-ExportsPath{   
    $ModPath = (Get-CoreModuleInformation).ModuleScriptPath
    $ExportsPath = Join-Path $ModPath 'exports'
    return $ExportsPath
}

function Register-HtmlAgilityPack{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [Switch]$Force
    )
    $ExportsPath = Get-ExportsPath
    $LibDir = (Join-Path $ExportsPath "lib\Core")  
    $LibPath = (Join-Path $LibDir "HtmlAgilityPack.dll")  
    if (!("HtmlAgilityPack.HtmlDocument" -as [type])) {
        Write-Verbose "Registering $LibPath... " 
        Add-Type -Path "$LibPath"
    }else{
        Write-Verbose "HtmlAgilityPack already registered: $LibPath... " 
    }
}



function Get-XamppVersions{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$Force
    )

    try{
        $GetFromWeb = $Force 
        $TmpFile = "$ENV:Temp\XampVersions.json"
        if(-not(Test-Path -Path "$TmpFile" -PathType Leaf)){
            $GetFromWeb = $true
            
        }
        [system.collections.arraylist]$versionlist = [system.collections.arraylist]::new()
        if($GetFromWeb){
            Add-Type -AssemblyName System.Web  

            $Null = Register-HtmlAgilityPack 

            $Ret = $False
            $Url = "https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/"
            
            $Results = Invoke-WebRequest -UseBasicParsing -Uri $Url
            $Data = $Results.Content 
            if($Results.StatusCode -eq 200){
                $Ret = $True
            }
            
            $HtmlContent = $Results.Content 

            [HtmlAgilityPack.HtmlDocument]$HtmlDoc = @{}
            $HtmlDoc.LoadHtml($HtmlContent)
            
            $HtmlNode = $HtmlDoc.DocumentNode
            
            For($i=1;$i -lt 300;$i++){
                
                $XNodeAddr2 = "//*[@id=`"files_list`"]/tbody/tr[{0}]" -f $i
                try{
                    $ResultNode = $HtmlNode.SelectNodes($XNodeAddr2)
                    [string]$VersionString = $ResultNode.Attributes[0].Value
                    $Log = "Processing tag $i ...  Found version `"$VersionString`""
                    Write-Verbose $Log
                    $r = $versionlist.Add($VersionString)
                }catch{
                    Write-Verbose "Stopped! No more data parsed"
                    break;
                }

            }

            Write-Verbose "Saving to $TmpFile"
            $JsonData = $versionlist | ConvertTo-Json 
            $JsonData | Set-Content $TmpFile 
            $versionlist
        }else{
            Write-Verbose "Reading From $TmpFile"
            $versionlist = Get-Content -Path "$TmpFile" | ConvertFrom-Json 
        }
        return $versionlist
    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
    return $Null
}



function Install-XamppServer {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false,Position=0)]
        [string]$Version = "latest",
        [Parameter(Mandatory=$false,Position=1)]
        [string]$DestinationPath = "$ENV:ProgramsPath"
    )
    try{
        $VersionToGet = $Version
        if($Version -eq 'latest'){
            $versionlist = Get-XamppVersions -Force
            $VersionToGet = $versionlist -notmatch 'development' | sort -Descending | select -Unique | select -First 1
        }else{
            $versionlist = Get-XamppVersions
        }
        
        Write-Verbose "Getting version $VersionToGet"
        if(-not($versionlist -match $VersionToGet)){throw "no such version"}

        $u = "https://psychz.dl.sourceforge.net/project/xampp/XAMPP%20Windows/{0}/xampp-portable-windows-x64-{0}-0-VS16.zip?viasf=1" -f $VersionToGet
                
        $o = "d:\Tmp\xampp-portable-windows-x64-{0}-0-VS16.zip" -f $VersionToGet 
        $hdrs = @{
            "Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
            "Accept-Encoding"="gzip, deflate, br, zstd"
            "Accept-Language"="fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"
            "Referer"="https://sourceforge.net/"
            "Sec-Fetch-Dest"="document"
            "Sec-Fetch-Mode"="navigate"
            "Sec-Fetch-Site"="same-site"
            "Upgrade-Insecure-Requests"="1"
            "sec-ch-ua"="`"Not/A)Brand`";v=`"8`", `"Chromium`";v=`"126`", `"Google Chrome`";v=`"126`""
            "sec-ch-ua-mobile"="?0"
            "sec-ch-ua-platform"="`"Windows`""
        }


        Invoke-WebRequest -UseBasicParsing -Uri $u -Headers $hdrs -OutFile $o
        Expand-Archive -Path $o -DestinationPath $DestinationPath -Force
        Remove-Item -Path $o -Force -ErrorAction Ignore | Out-Null
    }
    catch{
        Write-Error $_
    }
}
