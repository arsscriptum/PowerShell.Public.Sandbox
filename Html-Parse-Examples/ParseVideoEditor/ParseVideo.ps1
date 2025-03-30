


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
        Show-ExceptionDetails $_ -ShowStack
      }
    }
}

function Test-UriValid {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position=0)]
        [Uri]$Uri
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


function Get-HtmlContent{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$False)]
        [string]$SearchFor=$Null
    )

    try{

        $RootPath = (Resolve-Path "$PSScriptRoot\..").Path
        $HtmlFilePath = (Resolve-Path "$RootPath\page.html").Path
        [string]$HtmlContentRaw = Get-Content -Path "$HtmlFilePath" -Raw
        [string[]]$HtmlContentLines = Get-Content -Path "$HtmlFilePath"
        $HtmlContentLinesCount = $HtmlContentLines.Count
        $i = 0
        [PsCustomObject]$obj = [PsCustomObject]@{
            LineLenght = 0
            NumLines = $HtmlContentLinesCount 
            SearchFor = "$SearchFor"
            Found = $False 
            LineNumber = 0 
            SubString = ""
            Lines = $Null
            Line = ""
            Raw = $HtmlContentRaw
        }

        [system.Collections.ArrayList]$List = [system.Collections.ArrayList]::new()
        $HtmlContentLines | % { [void]$List.Add($_) }
        $obj.Lines = $List

        if($SearchFor){
            [string[]]$HtmlContentLines = $HtmlContentRaw -split [System.Environment]::NewLine
            
            ForEach($line in $HtmlContentLines){
                $lineLen = $line.Length
                if($line.Contains("$SearchFor")){
                    $index_end = $line.IndexOf("`"",$line.IndexOf("$SearchFor"))
                    $index_begin = $line.LastIndexOf("https",$index_end)
                    $obj.LineLenght = $lineLen
                    $obj.Line = $line
                    $obj.LineNumber = $i
                    $obj.Found = $True
                    $num = $index_end - $index_begin
                    $obj.SubString = $line.SubString($index_begin,$num)
                    break;
                }
                $i++
            }
        }
        return $obj

    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
    return $Null
}
#Select LineLenght,NumLines,SearchFor,Found,LineNumber,SubString

function Start-LoadHtmlAgilityPack{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    try{


        Add-Type -AssemblyName System.Web  

        $Null = Register-HtmlAgilityPack 
        return $True

    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
    return $Null
}

function Get-HtmlNodeXPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [HtmlAgilityPack.HtmlNode]$Node
    )

    # Initialize XPath string
    $xpath = ""

    # Traverse the node's ancestors to build the XPath
    while ($Node -ne $null -and $Node.NodeType -eq 'Element') {
        $index = 1
        $sibling = $Node.PreviousSibling
        while ($sibling -ne $null) {
            if ($sibling.NodeType -eq 'Element' -and $sibling.Name -eq $Node.Name) {
                $index++
            }
            $sibling = $sibling.PreviousSibling
        }

        # Prepend the current node to the XPath
        $nodeSegment = if ($index -gt 1 -or $Node.NextSibling -and $Node.NextSibling.Name -eq $Node.Name) {
            "/$($Node.Name)[$index]"
        }
        else {
            "/$($Node.Name)"
        }

        $xpath = $nodeSegment + $xpath
        $Node = $Node.ParentNode
    }

    return $xpath
}


function Invoke-WgetDownload {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Url,
        [Parameter(Mandatory=$False)]
        [switch]$Force,
        [Parameter(Mandatory=$False)]
        [switch]$Load
    )
    $NoQueryUrl = $u.AbsoluteUri.TrimEnd($u.Query)

    $Verb = 'GET'
    $Redirects = 5
    $TimeoutSec = 5
    [Uri]$u = $Url
    $OutFile = Join-Path -Path (Get-Location) -ChildPath ([IO.Path]::GetFileName($NoQueryUrl))

    $ColorYellow = 'Yellow'
    $ColorRed = 'Red'
    $ColorGreen = 'Green'

    Write-Host "[wget] " -ForegroundColor $ColorRed -NoNewline
    Write-Host "downloading $Url." -ForegroundColor $ColorYellow

    Write-Host "[wget] " -ForegroundColor $ColorRed -NoNewline
    Write-Host "out file $OutFile." -ForegroundColor $ColorYellow

    if ([string]::IsNullOrEmpty($Url)) {
        Write-Host "[wget] " -ForegroundColor $ColorRed -NoNewline
        Write-Host "invalid URL" -ForegroundColor $ColorYellow
        return
    }

    if (Test-Path -Path $OutFile) {
        Write-Host "[wget] " -ForegroundColor $ColorRed -NoNewline
        Write-Host "$OutFile exists!" -ForegroundColor $ColorYellow
        if($Force){
            Remove-Item -Path $OutFile -Force -EA Ignore | Out-Null
        }
        
    }

    try {
        Invoke-WebRequest -Uri $Url -Method $Verb -MaximumRedirection $Redirects -TimeoutSec $TimeoutSec -OutFile $OutFile -SkipCertificateCheck -UseBasicParsing

        Write-Host "[wget] " -ForegroundColor $ColorRed -NoNewline
        Write-Host "SUCCESS." -ForegroundColor $ColorGreen

        if (Test-Path $OutFile) {
            $data = (Get-Item $OutFile).Length / 1MB
            $size = "{0:N2} MB" -f $data

            Write-Host "[wget] " -ForegroundColor $ColorRed -NoNewline
            Write-Host "$OutFile $size" -ForegroundColor $ColorGreen

            if($Load){
                start "$OutFile"
            }
        }


    }
    catch {
        Show-ExceptionDetails $_ -ShowStack
    }
}




function Get-videoUrl{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    try{

        $res = Start-LoadHtmlAgilityPack
        $HtmlContent = Get-HtmlContent

        [HtmlAgilityPack.HtmlDocument]$HtmlDoc = @{}
        $res = $HtmlDoc.LoadHtml($HtmlContent)
        
        $HtmlNode = $HtmlDoc.DocumentNode
        
        $videoUrl=''
        
        $XNodeAddr = "/html/body/div[1]/div/div/main/div/div/div[3]/div/div/div[2]/div/div[1]/div[2]/div[2]/div[2]/img" 
     
        $Text = $HtmlNode.SelectNodes($XNodeAddr).OuterHtml
        $ResultNode = $HtmlNode.SelectNodes($XNodeAddr)
        $innerHtml = $ResultNode.InnerHtml
            

        # Extract the URL using regex
        if ($innerHtml -match 'src="([^"]+)"') {
           $videoUrl = $matches[1]

            if(-not(Test-UriValid -Uri $videoUrl)){
                write-host "Invalid Url $videoUrl"
            }
        } else {
            return $Null
        }
        

        $videoUrl
        
    }catch{
        return $Null
    }
    return $Null
}



$NodeFinderScript = $Null

$NodeFinderScript = {
    param([string]$Pattern, [System.Xml.XPath.XPathNavigator]$Navigator,[int]$Depth)
    try{
        $c_nav = $Navigator.Clone()
        $c_node=$c_nav.CurrentNode
        $hasChilds = $c_node.HasChildNodes
        $Sep1 = [string]::new(' ',$Depth*2)
        
        $Str = "[{0}]{1}{2}" -f $Depth, $Sep1, $c_node.Name
        if ($c_node.InnerHtml -and $c_node.InnerHtml.Contains($Pattern)) {
            Write-Verbose "Searching InnerHtml `"$($c_node.InnerHtml)`""
            return $c_node
        }
        if ($c_node.InnerText -and $c_node.InnerText.Contains($Pattern)) {
            Write-Verbose "Searching InnerText `"$($c_node.InnerHtml)`""
            return $c_node
        }
        Write-Host "$Str"
        if($hasChilds){
            if ($c_nav.MoveToFirstChild()) {
                do {
                    $c_node = &$NodeFinderScript $Pattern $c_nav ($depth + 1)  # recursive call for each child
                    if($c_node){
                        Write-Verbose "found!"
                        return $c_node
                    }
                } while ($c_nav.MoveToNext())
                $Navigator.MoveToParent() | Out-Null
            }
        }
        return $Null 
    }catch{
        return $Null 
    }
}.GetNewClosure()




function Search-HtmlNodeContent {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true, Position=0, HelpMessage="HtmlDocument")]
        [HtmlAgilityPack.HtmlDocument]$HtmlDocument,
        [Parameter(Mandatory=$true, Position=1, HelpMessage="Pattern")]
        [string]$Pattern
    )

    # Create a navigator
    $Navigator = $HtmlDocument.CreateNavigator()
    
    $Node = &$NodeFinderScript $Pattern $Navigator 0
    if($Node){
        Write-Host "Found Node!"
        return $Node
    }
    return $Null
}







var node = htmlDoc.DocumentNode.SelectSingleNode("//body");

foreach (var nNode in node.Descendants("h2"))
{
    if (nNode.NodeType == HtmlNodeType.Element)
    {
        Console.WriteLine(nNode.Name);
    }
}










$res = Start-LoadHtmlAgilityPack
$HtmlContent = Get-HtmlContent | select -expandproperty Raw

[HtmlAgilityPack.HtmlDocument]$HtmlDoc = @{}
$res = $HtmlDoc.LoadHtml($HtmlContent)

$r=Search-HtmlNodeContent $HtmlDoc "guill"
#[string]$Url = (Get-videoUrl) -as  [string]
#Invoke-WgetDownload $Url -Force -Load
