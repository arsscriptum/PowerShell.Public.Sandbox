<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Request-PortDescription{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True, Position = 0)]
        [int]$Port,
        [Parameter(Mandatory=$false)]
        [switch]$DumpHtml
    )
    Add-Type -AssemblyName System.Web  

    $HeadersData = @{
      "Accept-Encoding"="gzip, deflate, br"
      "Referer"="https://www.grc.com/PortDataHelp.htm"
    }

    $Uri = "https://www.grc.com/port?1={0}&2.x=39&2.y=9" -f $Port

    $Results = Invoke-WebRequest -Method Get -Uri $Uri -MaximumRedirection 2 -Headers $HeadersData -UseBasicParsing -ErrorAction Stop

    Write-Verbose "Loading URL `"$Url`" "

    $StatusCode = $Results.StatusCode 
    if(200 -ne $StatusCode){
        Write-Error "Request Failed"
        return
    }

    $HtmlContent = $Results.Content 

    if($DumpHtml){
        $CurrentDir = (Get-Location).Path 
        $FilePath = Join-Path $CurrentDir "grc_com-getportinfo-$Port.html"
        Set-Content -Path "$FilePath" -Value "$HtmlContent" -Force
        Write-Verbose "Dumping Html data in `"$FilePath`" "
    }
    [HtmlAgilityPack.HtmlDocument]$doc = @{}
    $doc.LoadHtml($HtmlContent)

    $PortInformation = $doc.DocumentNode.SelectNodes("/html[1]/body[1]/center[1]/form[1]/table[2]").InnerText
    $AdditionalInfos = $doc.DocumentNode.SelectNodes("/html[1]/body[1]/center[1]/form[1]/table[3]").InnerText

    $PortInformation = [System.Web.HttpUtility]::HtmlDecode($PortInformation)
    $AdditionalInfos = [System.Web.HttpUtility]::HtmlDecode($AdditionalInfos)

    $PortInfoObject = [PsCustomObject]@{}

    $PortInfoObject | Add-Member -MemberType NoteProperty -Name "PortInformation" -Value "$PortInformation" 
    $PortInfoObject | Add-Member -MemberType NoteProperty -Name "AdditionalInfos" -Value "$AdditionalInfos"
    $PortInfoObject
}

function Test-RequestPortDescription{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$DumpHtml
    )

    $r = Request-PortDescription 8080 -DumpHtml

    $r 
}