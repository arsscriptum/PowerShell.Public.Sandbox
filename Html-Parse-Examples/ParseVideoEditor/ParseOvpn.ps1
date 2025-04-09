


[CmdletBinding(SupportsShouldProcess)]
param()


function Register-HtmlAgilityPack {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $False)]
        [string]$Path
    )
    begin {
        if ([string]::IsNullOrEmpty($Path)) {
            $Path = "{0}\lib\{1}\HtmlAgilityPack.dll" -f "$PSScriptRoot", "$($PSVersionTable.PSEdition)"
        }
    }
    process {
        try {
            if (-not (Test-Path -Path "$Path" -PathType Leaf)) { throw "no such file `"$Path`"" }
            if (!("HtmlAgilityPack.HtmlDocument" -as [type])) {
                Write-Verbose "Registering HtmlAgilityPack... "
                add-type -Path "$Path"
            } else {
                Write-Verbose "HtmlAgilityPack already registered "
            }
        } catch {
            Show-ExceptionDetails $_ -ShowStack
        }
    }
}

function Test-UriValid {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position = 0)]
        [uri]$Uri
    )

    if (-not $Uri.IsAbsoluteUri) {
        return $false
    }

    if ([string]::IsNullOrEmpty($Uri.Scheme) -or [string]::IsNullOrEmpty($Uri.Host)) {
        return $false
    }

    # Optional: Validate acceptable schemes (http, https)
    if ($Uri.Scheme -notmatch '^(http|https)$') {
        return $false
    }

    return $true
}


function Get-HtmlContent {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $False)]
        [string]$SearchFor = $Null
    )

    try {

        $HtmlFilePath = (Resolve-Path "$PWD\ovpn.html").Path

        [string]$HtmlContentRaw = Get-Content -Path "$HtmlFilePath" -Raw

        return $HtmlContentRaw

    } catch {
        Show-ExceptionDetails $_ -ShowStack
    }
    return $Null
}
#Select LineLenght,NumLines,SearchFor,Found,LineNumber,SubString

function Start-LoadHtmlAgilityPack {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    try {


        Add-Type -AssemblyName System.Web

        $Null = Register-HtmlAgilityPack
        return $True

    } catch {
        Show-ExceptionDetails $_ -ShowStack
    }
    return $Null
}




function Get-OvpnSyntax {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    try {

        $res = Start-LoadHtmlAgilityPack
        $HtmlContent = Get-HtmlContent

        [HtmlAgilityPack.HtmlDocument]$HtmlDoc = @{}
        $res = $HtmlDoc.LoadHtml($HtmlContent)

        $HtmlNode = $HtmlDoc.DocumentNode

        $videoUrl = ''

        1..55 | % {
            $id = $_
            $XNodeAddr = "/html/body/main/div/div/div[2]/article/section[2]/dl[2]/dt[{0}]/b" -f $id




            $Text = $HtmlNode.SelectNodes($XNodeAddr).OuterHtml
            $ResultNode = $HtmlNode.SelectNodes($XNodeAddr)

            $Syntax = [System.Net.WebUtility]::HtmlDecode($HtmlNode.SelectNodes($XNodeAddr).InnerText)
            $Syntax

        }



    } catch {
        return $Null
    }
    return $Null
}





$res = Start-LoadHtmlAgilityPack
$HtmlContent = Get-HtmlContent

[HtmlAgilityPack.HtmlDocument]$HtmlDoc = @{}
$res = $HtmlDoc.LoadHtml($HtmlContent)
$HtmlNode = $HtmlDoc.DocumentNode
$XNodeAddr = "/html/body/main/div/div/div[2]/article/section[2]/dl[2]/dt[{0}]/b" -f 4
