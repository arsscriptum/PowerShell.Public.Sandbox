


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


function Get-MassoList{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [int]$Page = 1
    )

    try{

        Add-Type -AssemblyName System.Web  

        $Null = Register-HtmlAgilityPack 

        $Ret = $False
        $Url = "https://rmpq.ca/repertoire-des-membres/ville/ville-de-levis/page/{0}/" -f $Page
        $HeadersData = @{
            "authority"="rmpq.ca"
            "method"="GET"
            "path"="/repertoire-des-membres/ville/ville-de-levis/page/$Page/"
            "scheme"="https"
            "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
            "accept-encoding"="gzip, deflate, br, zstd"
            "accept-language"="fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"
            "priority"="u=0, i"
            "referer"="https://rmpq.ca/repertoire-des-membres/ville/ville-de-levis/"
            "sec-ch-ua"="`"Not/A)Brand`";v=`"8`", `"Chromium`";v=`"126`", `"Google Chrome`";v=`"126`""
            "sec-ch-ua-mobile"="?0"
            "sec-ch-ua-platform"="`"Windows`""
            "sec-fetch-dest"="document"
            "sec-fetch-mode"="navigate"
            "sec-fetch-site"="same-origin"
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
        $XNodeAddr1 = "//*[@id=`"resultMembre`"]/div[3]"
        $MassoHashTable = @{}
        For($i=1;$i -lt 20;$i++){
            $XNodeAddr2 = "//*[@id=`"resultMembre`"]/div[{0}]/p/a" -f $i
            try{
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



function Search-Masso{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Name
    )

    process{
      try{
        $AllResults = @{}
        $PageId = 1
        $Succeeded = $True
        while($Succeeded){
            $r = Get-MassoList -Page $PageId
            $PageId++
            if($r -eq $Null){ 
                $Succeeded=$False 
            }else{
                $AllResults += $r
            }
        }

        $AllResults

        ForEach ($info in $AllResults.Keys) {
            $PersonName = $info
            $WebSite = $($AllResults["$info"])
            if($PersonName -match "$Name"){
                Write-Host "Found!"
                Write-Host "$Name"
                Write-Host "$WebSite"
                &(Get-ChromePath) "$WebSite"
                continue;
            }
        }
      }catch{
        throw $_
      }
    }
}



function Test-SearchMasso{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    # Lets find the masso who left me a message on voice mail: Adrianna Duquette
    Search-Masso -Name "Duquette"
}