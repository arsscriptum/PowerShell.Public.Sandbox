#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   GetArticleScripts.ps1                                                        ║
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


function Get-ScriptsList{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [int]$Page = 1
    )

    try{

        Add-Type -AssemblyName System.Web  

        $Null = Register-HtmlAgilityPack 

        $Ret = $False
        $Url = "http://www.theatomheart.net/post/rubber-ducky-payloads/"
       
        $Results = Invoke-WebRequest -UseBasicParsing -Uri $Url
        $Data = $Results.Content 
        if($Results.StatusCode -eq 200){
            $Ret = $True
        }
        
        $HtmlContent = $Results.Content 

        [HtmlAgilityPack.HtmlDocument]$HtmlDoc = @{}
        $HtmlDoc.LoadHtml($HtmlContent)
        
        $HtmlNode = $HtmlDoc.DocumentNode

        [System.Collections.Arraylist]$List = [System.Collections.Arraylist]::new()
        $Counter = 1
        $Articles = $True
        While($Articles){
            $XpathTitle = "/html/body/main/article/h3[{0}]" -f $Counter
            $XpathDesc = "/html/body/main/article/p[{0}]" -f $Counter
            $XpathCode = "/html/body/main/article/pre[{0}]/code" -f $Counter
            $Counter++

            try{
                $NodeTitle = $HtmlNode.SelectNodes($XpathTitle)
                $NodeDesc = $HtmlNode.SelectNodes($XpathDesc)
                $NodeCode = $HtmlNode.SelectNodes($XpathCode)
                if( ($NodeTitle -eq $Null) -And ($NodeDesc -eq $Null) -And ($NodeCode -eq $Null)){
                    $Articles = $False
                }                
                [PsCustomObject]$o = @{
                    Id = $Counter
                    Title = $NodeTitle.InnerText
                    Description = $NodeDesc.InnerText
                    Code = $NodeCode.InnerText
                }
                [void]$List.Add($o)
            }catch{
                break;
            }

        }

        return $List
        
    }catch{
        Write-Verbose "$_"
        Write-Host "Error Occured. Probably Invalid Page Id" -f DarkRed
    }
    return $Null
}

Get-ScriptsList










