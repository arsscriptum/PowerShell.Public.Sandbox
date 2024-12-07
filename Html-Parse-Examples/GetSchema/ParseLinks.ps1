
[CmdletBinding(SupportsShouldProcess)]
param()

# Load HtmlAgilityPack
$Path = "{0}\lib\{1}\HtmlAgilityPack.dll" -f "$PWD", "$($PSVersionTable.PSEdition)"
Add-Type -Path $Path


function Get-ManualXPath {
    param (
    	[Parameter(Mandatory=$True, Position = 0)]
        [HtmlAgilityPack.HtmlNode]$Node
    )

    $current = $Node
    $path = ""

    while ($current -ne $null -and $current.NodeType -ne "Document") {
        $index = 1
        $sibling = $current.PreviousSibling

        # Calculate the position of the current node among its siblings
        while ($sibling -ne $null) {
            if ($sibling.Name -eq $current.Name) {
                $index++
            }
            $sibling = $sibling.PreviousSibling
        }

        # Build the XPath segment for this node
        $path = "/$($current.Name)[$index]$path"

        # Move up to the parent node
        $current = $current.ParentNode
    }

    return $path
}

# Example usage
$HtmlFile = "{0}\test2.html" -f "$PWD"
$JsonFile = "{0}\out.json" -f "$PWD"

[System.Collections.ArrayList]$Links = [System.Collections.ArrayList]::new()
[System.Collections.ArrayList]$Directories = [System.Collections.ArrayList]::new()



$htmlDoc = New-Object HtmlAgilityPack.HtmlDocument
$htmlDoc.Load($HtmlFile)

$dlNode = $htmlDoc.DocumentNode.SelectSingleNode("//dl")

# Create an XPathNavigator for the node
$navigator = $dlNode.CreateNavigator()

# Query descendants of the <dl> node
$link_nodes = $navigator.Select("descendant::a")

while ($link_nodes.MoveNext()) {
    $current = $link_nodes.Current
    [HtmlAgilityPack.HtmlDocument]$currentDocument = $current.CurrentDocument
    [HtmlAgilityPack.HtmlNode]$currentNode = $current.CurrentNode
    $TypeCurrent = $current.GetType()
    $TypeCurrentNode = $currentNode.GetType()
    $TypeCurrentDoc = $currentDocument.GetType()
    $TypeCurrentNode.Depth
    [PsCustomObject]$LinkObject = @{
        href = $current.GetAttribute("href", "")
        text = $current.Value
        path = Get-ManualXPath $currentNode
    }
    [void]$Links.Add($LinkObject)
}
$Links


