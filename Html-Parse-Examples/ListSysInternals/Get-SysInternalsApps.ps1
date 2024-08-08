


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



      }
    }
}

function Expand-UtilityInformation {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$htmlString
    )

    # Create an HtmlDocument and load the HTML string
    $htmlLinkInstance = New-Object HtmlAgilityPack.HtmlDocument
    $htmlLinkInstance.LoadHtml($htmlString)

    # Extract the link URL, title, and description
    $linkUrl = $htmlLinkInstance.DocumentNode.SelectSingleNode("//a").GetAttributeValue("href", "")
    $title = $htmlLinkInstance.DocumentNode.SelectSingleNode("//a").InnerText

    # Create a custom object to hold the extracted information
    [PSCustomObject]@{
        LinkUrl     = $linkUrl
        Title       = $title
    }
}

function Get-SysInternalsUtilities{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    try{

        Add-Type -AssemblyName System.Web  

        $Null = Register-HtmlAgilityPack 

        $Ret = $False
        $Url = "https://learn.microsoft.com/en-us/sysinternals/downloads/" -f $Page
       
        $Results = Invoke-WebRequest -UseBasicParsing -Uri $Url
        $Data = $Results.Content 
        if($Results.StatusCode -eq 200){
            $Ret = $True
        }
        
        $HtmlContent = $Results.Content 

        [HtmlAgilityPack.HtmlDocument]$HtmlDoc = @{}
        $HtmlDoc.LoadHtml($HtmlContent)
        
        $HtmlNode = $HtmlDoc.DocumentNode
        [System.Collections.ArrayList]$ObjList = [System.Collections.ArrayList]::new()
        For($i=1;$i -lt 5;$i++){
            $full_xpath = "/html/body/div[2]/div/section/div/div[1]/main/div[3]/p[{0}]" -f $i
            try{
                $ResultNode = $HtmlNode.SelectNodes($full_xpath)
                if( ($ResultNode -ne $Null) -And ( ! [string]::IsNullOrEmpty("$($ResultNode.InnerHtml)") ) ) {
                    $o = Expand-UtilityInformation "$($ResultNode.InnerHtml)"
                    [void]$ObjList.Add($o)
                }
               
            }catch{
                break;
            }

        }

        return $ObjList
        
    }catch{
        Write-Verbose "$_"
        Write-Host "Error Occured." -f DarkRed
    }
    return $Null
}



function Get-AllSysInternalsUtilities {

    [CmdletBinding(SupportsShouldProcess)]
    param()
    try{
        

        $AllUtilities = Get-SysInternalsUtilities 
        ForEach($util in $AllUtilities){
            $title  = $util.Title
            $link  = $util.LinkUrl
            Write-Host "downloading `"$title`" " -f DarkYellow 


            [Uri]$u = $link 
            $Filename = $u.Segments[$u.Segments.Count -1]

            $LocalPath = (Resolve-Path -Path "$PSScriptRoot").Path
            $dlPath  = Join-Path $LocalPath 'downloads'
            if(-not(Test-Path -Path $dlPath -PathType Container)){
                New-Item -Path "$dlPath" -ItemType Directory -Force -ErrorAction Ignore | Out-Null
            }
            $SavedFilePath = Join-Path "$dlPath" $Filename
            Invoke-WebRequest -UseBasicParsing -Uri $link -OutFile SavedFilePath
            Expand-Archive -Path  "$dlPath" -DestinationPath "$ENV:TEMP\$Filename" -Force
        }

    
    }
    catch{
        Write-Error $_
    }
}

Get-AllSysInternalsUtilities