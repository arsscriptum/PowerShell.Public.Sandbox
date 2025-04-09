


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
            throw $_
        }
    }
}

function Resolve-AnyPath {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, HelpMessage = 'Path')]
        [string]$Path,
        [Parameter(Mandatory = $False, HelpMessage = 'Recursive')]
        [switch]$CreateIfMissing
    )

    process {
        try {
            [string]$ReturnValue = ''
            [System.Management.Automation.PathInfo]$FullDestinationPathInfo = Resolve-Path -Path "$Path" -ErrorAction Stop
            $ReturnValue = $FullDestinationPathInfo.Path
        } catch {
            [System.Management.Automation.ErrorCategoryInfo]$CatInfo = $_.CategoryInfo
            if ($CatInfo.Category -eq 'ObjectNotFound') {
                $MissingPath = $CatInfo.TargetName
                [string]$ReturnValue = $MissingPath
                if ($CreateIfMissing) {
                    $null = New-Item -ItemType Directory -Path $MissingPath -Force -ErrorAction Ignore
                }
            }
        }
        return $MissingPath
    }
}

function Get-MachinTechImages {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$Path = "$PWD\MachinTech.html",
        [Parameter(Mandatory = $False, HelpMessage = 'Recursive')]
        [int]$MaxImages = 150
    )

    try {

        Add-Type -AssemblyName System.Web

        $Null = Register-HtmlAgilityPack

        $Ret = $False
        $HtmlContent = Get-Content -Path "$PWD\MachinTech.html" -Raw


        [HtmlAgilityPack.HtmlDocument]$HtmlDoc = @{}
        $HtmlDoc.LoadHtml($HtmlContent)

        $HtmlNode = $HtmlDoc.DocumentNode
        [System.Collections.ArrayList]$List = [System.Collections.ArrayList]::new()
        $HashTable = @{}
        [int]$i = 1
        $Proceed = $True
        while ($Proceed) {
            $XNodeAddr = "/html/body/div[7]/div[3]/div/div[2]/div/div[2]/main/div[2]/div/div/div[2]/div[3]/div/div[1]/div[{0}]/div/div/div/div/div/div/div[1]/div[3]/div/div/button/div/div/img" -f $i
            if ($i -gt $MaxImages) {
                $Proceed = $False
            } else {
                $i++
            }

            try {
                $ResultNode = $HtmlNode.SelectNodes($XNodeAddr)
                if (!$ResultNode) {
                    continue;
                }
                [string]$u = $ResultNode.Attributes[1].Value
                [string]$value = $u.Replace('&amp;', '&')
                [void]$List.Add($value)

            } catch {
                break;
            }

        }

        return $List

    } catch {
        Write-Verbose "$_"
        Write-Host "Error Occured. Probably Invalid Page Id" -f DarkRed
    }
    return $Null
}



function Save-BrowseLinkedInPage {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$CompanyName = "machitech-automation-inc-"
    )
    try {


        # Start a Firefox browser and go to the LinkedIn page
        $Url = "https://www.linkedin.com/company/{0}/posts/?feedView=all" -f $CompanyName
        $Driver = Start-SeFirefox -StartURL "$Url"

        # Optional: give time to login manually (or use saved profile with cookies)
        Read-Host "Log in manually and press Enter to continue scrolling..."

        # Scroll loop: simulate user scrolling down multiple times
        for ($i = 0; $i -lt 20; $i++) {
            $Driver.ExecuteScript("window.scrollTo(0, document.body.scrollHeight);")
            Start-Sleep -Seconds 2
        }

        # Once done, extract full HTML
        $Html = $Driver.PageSource

        # Save to file or parse it directly
        $Html | Out-File "$env:TEMP\linkedin_full.html"

        return "$env:TEMP\linkedin_full.html"


    } catch {
        Write-Error "$_"
    }

}
function Save-LinkedInImage {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Url,
        [Parameter(Mandatory = $false, Position = 1)]
        [string]$DestinationPath = "newpics"
    )
    try {

        $FilePath = $Url.Replace('https://media.licdn.com', '')


        if (!$FilePath.StartsWith('/dms')) {
            Write-Error "bad url `"$Url`" $FilePath"
        }

        $OutFileDir = Join-Path "$PSSCriptRoot" "$DestinationPath"
        New-Item -Path "$OutFileDir" -ItemType Directory -Force | Out-Null
        $OutFilePath = Join-Path "$OutFileDir" "$(Get-Random).jfif"

        $Headers = @{
            "authority" = "media.licdn.com"
            "method" = "GET"
            "path" = "$FilePath"
            "scheme" = "https"
            "accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8"
            "accept-encoding" = "gzip, deflate, br, zstd"
            "accept-language" = "en-US,en;q=0.7"
            "cache-control" = "no-cache"
            "pragma" = "no-cache"
            "priority" = "u=0, i"
            "referer" = "https://www.linkedin.com/"
            "sec-ch-ua" = "`"Brave`";v=`"135`", `"Not-A.Brand`";v=`"8`", `"Chromium`";v=`"135`""
            "sec-ch-ua-mobile" = "?0"
            "sec-ch-ua-platform" = "`"Windows`""
            "sec-fetch-dest" = "document"
            "sec-fetch-mode" = "navigate"
            "sec-fetch-site" = "cross-site"
            "sec-fetch-user" = "?1"
            "sec-gpc" = "1"
            "upgrade-insecure-requests" = "1"
        }
        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36"
        Write-Host "downloading file to `"$OutFilePath`""
        Invoke-WebRequest -UseBasicParsing -Uri "$Url" -WebSession $session -Headers $Headers -OutFile "$OutFilePath"

    } catch {
        Write-Error "$_"
    }

}

$FilePath = Save-BrowseLinkedInPage
$MachinTechImages = Get-MachinTechImages "$FilePath"
$MachinTechImagesCount = $MachinTechImages.Count
Write-Host "Found $MachinTechImagesCount image!"
foreach ($img in $MachinTechImages) {
    Save-LinkedInImage "$img"
}
