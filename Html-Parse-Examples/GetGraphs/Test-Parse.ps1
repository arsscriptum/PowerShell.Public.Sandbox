#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   Test-Parse.ps1                                                               ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


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





function Get-Charts{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    try{

        Add-Type -AssemblyName System.Web  

        $Null = Register-HtmlAgilityPack 

        $Ret = $False
        $HtmlContent = Get-Content -Path "$PSScriptRoot\charts.html" -Raw


        [HtmlAgilityPack.HtmlDocument]$HtmlDoc = @{}
        $HtmlDoc.LoadHtml($HtmlContent)
        
        $HtmlNode = $HtmlDoc.DocumentNode
        [System.Collections.ArrayList]$List = [System.Collections.ArrayList]::new()
        $HashTable = @{}
        For($i=1;$i -lt 99;$i++){
            $XNodeAddr = "/html/body/div[2]/div[2]/div/div[2]/div/div/div[1]/article/div[3]/h3[{0}]/span" -f $i
            try{
                $ResultNode = $HtmlNode.SelectNodes($XNodeAddr)
                if($Null -eq $ResultNode){
                    break;
                }
                [string]$Name = $ResultNode.InnerText
                $Name
                $i++
            }catch{
                break;
            }

        }

        return;
        
    }catch{
        Write-Verbose "$_"
        Write-Host "Error Occured. Probably Invalid Page Id" -f DarkRed
    }
    return $Null
}


Get-Charts
