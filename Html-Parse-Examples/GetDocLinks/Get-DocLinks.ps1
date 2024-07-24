


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


function Get-DocLinks{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [int]$Page = 1
    )

    try{

        Add-Type -AssemblyName System.Web  

        $Null = Register-HtmlAgilityPack 

        $Ret = $False
               
        $Url = "https://www.nxp.com/design/design-center/development-boards-and-designs/design-studio-integrated-development-environment-ide:KDS_IDE"
        $HeadersData = @{
          "authority"="www.nxp.com"
          "method"="GET"
          "path"="/design/design-center/development-boards-and-designs/design-studio-integrated-development-environment-ide:KDS_IDE"
          "scheme"="https"
          "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
          "accept-encoding"="gzip, deflate, br, zstd"
          "accept-language"="fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"
          "cache-control"="max-age=0"
          "if-modified-since"="Tue, 18 Jun 2024 20:30:33 GMT"
          "if-none-match"="`"6671ee69-1e549`""
          "priority"="u=0, i"
          "sec-ch-ua"="`"Not/A)Brand`";v=`"8`", `"Chromium`";v=`"126`", `"Google Chrome`";v=`"126`""
          "sec-ch-ua-mobile"="?0"
          "sec-ch-ua-platform"="`"Windows`""
          "sec-fetch-dest"="document"
          "sec-fetch-mode"="navigate"
          "sec-fetch-site"="none"
          "sec-fetch-user"="?1"
          "upgrade-insecure-requests"="1"
        }

        $Results = Invoke-WebRequest -UseBasicParsing -Uri $Url -Headers $HeadersData
        $Data = $Results.Content 
        if($Results.StatusCode -eq 200){
            $Ret = $True
        }
        
        $HtmlContent = $Results.Content 

        [HtmlAgilityPack.HtmlDocument]$HtmlDoc = @{}
        $HtmlDoc.LoadHtml($HtmlContent)
        
        $HtmlNode = $HtmlDoc.DocumentNode
        
        $MassoHashTable = @{}
        For($i=1;$i -lt 20;$i++){
            $XNodeAddr2 = "/html[1]/body[1]/div[1]/div[5]/div[1]/div[1]/div[12]/div[1]/div[1]/div[2]/div[2]/ul[1]/li[{0}]/#text[3]" -f $i
            $XNodeAddr2 = "/html/body/div[1]/div[5]/div/div/div[12]/div[1]/div/div[2]/div[2]/ul/li[{0}]" -f $i
            try{
                $Text = $HtmlNode.SelectNodes($XNodeAddr2).OuterHtml
                $ResultNode = $HtmlNode.SelectNodes($XNodeAddr2)
                [string]$Link = $ResultNode.Attributes[0].Value
                [string]$Name = $ResultNode.Attributes[1].Value
                $Name = $Name.Replace(' - Voir la fiche complète','')
                

                $MassoHashTable.Add("$Name", "$Link")
            }catch{
                break;
            }

        }

        return $MassoHashTable
        
    }catch{
        Write-Verbose "$_"
        Write-Host "Error Occured. Probably Invalid Page Id" -f DarkRed
    }
    return $Null
}

