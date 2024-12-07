#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   Test-Parse.ps1                                                               ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding(SupportsShouldProcess)]
param()


function Register-HtmlAgilityPack{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$False)]
        [string]$Path
    )
    begin{
        if([string]::IsNullOrEmpty($Path)){
            $Path = "{0}\lib\{1}\HtmlAgilityPack.dll" -f "$PSScriptRoot", "$($PSVersionTable.PSEdition)"
        }
    }
    process{
      try{
        if(-not(Test-Path -Path "$Path" -PathType Leaf)){ throw "no such file `"$Path`"" }
        if (!("HtmlAgilityPack.HtmlDocument" -as [type])) {
            Write-Verbose "Registering HtmlAgilityPack... " 
            add-type -Path "$Path"
        }else{
            Write-Verbose "HtmlAgilityPack already registered " 
        }
      }catch{
        throw $_
      }
    }
}






function Test-Parse{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$DumpHtml
    )

   try{
        Add-Type -AssemblyName System.Web  

        $Null = Register-HtmlAgilityPack 
      
        $Url = "https://www.coles.com.au/product/coles-red-capsicum-approx.-250g-each-4580208"
    
        $Results = Invoke-WebRequest -Uri $Url -Method Get
        Write-Verbose "Loading URL `"$Url`" "

        $StatusCode = $Results.StatusCode 
        if(200 -ne $StatusCode){
            Write-Error "Request Failed"
            return
        }

        $HtmlContent = $Results.Content 

        if($DumpHtml){
            $CurrentDir = (Get-Location).Path 
            $FilePath = Join-Path $CurrentDir "testparse.html"
            Set-Content -Path "$FilePath" -Value "$HtmlContent" -Force
            Write-Verbose "Dumping Html data in `"$FilePath`" "
        }
        [HtmlAgilityPack.HtmlDocument]$HtmlDoc = @{}
        $HtmlDoc.LoadHtml($HtmlContent)
        
        $HtmlNode = $HtmlDoc.DocumentNode
        $PriceValues = $HtmlNode.SelectNodes("//span[@class='price__value']")
        $PriceValues.InnerText

    }catch{
        Write-Error "$_"
    }
}


Test-Parse
