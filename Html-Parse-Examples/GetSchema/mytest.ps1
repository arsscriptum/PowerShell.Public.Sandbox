function Process-Node {
    param (
        [HtmlAgilityPack.HtmlNode]$Node
    )

    # Initialize the structure for the current node
    $currentNode = @{
        Name        = $null
        AddDate     = $null
        Bookmarks   = @()
        ChildGroups = @()
    }

    # Process <DT> with <H3> (Group Names)
    $h3Node = $Node.SelectSingleNode("h3")
    if ($h3Node -ne $null) {
        $currentNode.Name = $h3Node.InnerText.Trim()
        $currentNode.AddDate = $h3Node.GetAttributeValue("add_date", 0)
    }

    # Process <DT> with <A> (Bookmarks)
    $anchorNodes = $Node.SelectNodes("a")
    if ($anchorNodes -ne $null) {
        foreach ($anchor in $anchorNodes) {
            $bookmark = @{
                Name    = $anchor.InnerText.Trim()
                Href    = $anchor.GetAttributeValue("href", "")
                AddDate = $anchor.GetAttributeValue("add_date", 0)
            }
            $currentNode.Bookmarks += $bookmark
        }
    }

    # Process child <DL> nodes recursively
    $childDlNodes = $Node.SelectNodes("dl")
    if ($childDlNodes -ne $null) {
        foreach ($childDl in $childDlNodes) {
            $childGroup = Process-Node -Node $childDl
            $currentNode.ChildGroups += $childGroup
        }
    }

    return $currentNode
}

$HtmlFile = "{0}\test2.html" -f "$PWD"
$JsonFile = "{0}\out.json" -f "$PWD"

$htmlDoc = New-Object HtmlAgilityPack.HtmlDocument
$htmlDoc.Load($HtmlFile)

$dlNode = $htmlDoc.DocumentNode.SelectSingleNode("/dl/p")
$n =  $dlNode.ChildNodes[1].ChildNodes[2]
# Process the root <DL> node
$RootGroup = Process-Node -Node $n

# Convert to JSON and save
$JsonOutput = $RootGroup | ConvertTo-Json -Depth 100 -Compress
$JsonOutput | Out-File -FilePath "$JsonFile" -Encoding utf8

Write-Host "JSON saved to $JsonFile"
