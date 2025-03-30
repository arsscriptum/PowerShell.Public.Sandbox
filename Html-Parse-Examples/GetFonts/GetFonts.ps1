


[CmdletBinding(SupportsShouldProcess)]
param()


function Get-DaFonts {
    [CmdletBinding(SupportsShouldProcess)]
    param (
      [Parameter(Mandatory = $True, Position=0)]
      [string]$FontName    
    )

    process{

      try{

        $fname = $FontName.Replace('.font','')


        $outfile = "$PSScriptRoot\{0}.zip" -f  $fname
        $u = "https://dl.dafont.com/dl/?f={0}" -f $fname
        Write-Host "download $fname from $u"
        Invoke-WebRequest -UseBasicParsing -Uri "$u" -OutFile "$outfile"
     
        Expand-Archive "$outfile" "$PSScriptRoot\NewFonts" -Force
      }catch{
        Write-Error "$_"
      }
    }
}


function Get-GoogleFont {
    [CmdletBinding(SupportsShouldProcess)]
    param (
      [Parameter(Mandatory = $True, Position=0)]
      [string]$FontName    
    )

    process{

      try{


        $outfile = "$PSScriptRoot\{0}.zip" -f  $FontName
        $p = "/download/list?family={0}" -f $FontName
        $u = "https://fonts.google.com/download/list?family={0}" -f $FontName
        Write-Host "download $fname from $u"
        Invoke-WebRequest -UseBasicParsing -Uri "$u" -OutFile "$outfile"


        #Expand-Archive "$outfile" "$PSScriptRoot\NewFonts" -Force

      }catch{
        Write-Error "$_"
      }
    }
}



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

function Get-FontsList{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [int]$OlValue = 1
    )

    try{

        Add-Type -AssemblyName System.Web  

        $Null = Register-HtmlAgilityPack 

        $Ret = $False
        $Url = "https://freebies.fluxes.com/blog/52-best-free-sci-fi-and-tech-fonts/"
       
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
        $Counter = 0
       
        
        While($True){
            $Counter++
            $XpathLink = "/html/body/div[3]/div[2]/div/div[3]/ol[{1}]/li[{0}]/p[2]/a" -f $Counter, $OlValue
            $XpathName = "/html/body/div[3]/div[2]/div/div[3]/ol[{1}]/li[{0}]/h3" -f $Counter, $OlValue
            

            try{
                $NodeTitle = $HtmlNode.SelectNodes($XpathName)
                
                $NodeLink = $HtmlNode.SelectNodes($XpathLink)

                if(($Null -eq $NodeTitle) -And ($Null -eq $NodeLink)){
                    write-host "null link"
                    break;
                }
                 $name = $NodeTitle.InnerText

                try{
                    [Uri]$u = $NodeLink.GetAttributeValue("href","")
                    $bad = $u.IsAbsoluteUri -eq $False
                    if($bad -eq $True){throw "bad"}
                    $FullUrl = $u.AbsoluteUri
                    $NameHost = $u.Host
                }catch{
                    Write-Warning "cannot get link for $name"
                    continue;;
                }
               
                if($NameHost -eq 'fonts.google.com'){
                    Write-Host "Google" -f Green
                    
                    $fname = $FullUrl.Replace('https://fonts.google.com/specimen/','').Replace('.font','')
                    Get-GoogleFont $fname
                }elseif($NameHost.Contains('dafont')){
                    Write-Host "dafonts" -f Yellow
                    $fname = $FullUrl.Replace('https://www.dafont.com/','').Replace('.font','')
                    Get-DaFonts $fname
                }else{
                    Write-Host "other $NameHost" -f Red
                }

              
                [PsCustomObject]$o = @{
                    Id = $Counter
                    Name = $name
                    Link = $FullUrl
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


#Get-FontsList 1
Get-FontsList 2
