[CmdletBinding(SupportsShouldProcess)]
param()

# Load HtmlAgilityPack
$Path = "{0}\lib\{1}\HtmlAgilityPack.dll" -f "$PSScriptRoot", "$($PSVersionTable.PSEdition)"
Add-Type -Path $Path

function Parse-HtmlBookmarksToJson {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Load the HTML document
    $htmlDoc = New-Object HtmlAgilityPack.HtmlDocument
    $htmlDoc.Load($FilePath)

    # Recursive function to process nodes
    function Process-Node {
        param (
            [HtmlAgilityPack.HtmlNode]$Node
        )

        # Initialize the structure for the current group
        $currentGroup = @{
            Name       = $null
            AddDate    = $null
            LastModified = $null
            Bookmarks  = @()
            ChildGroups = @()
        }

        # Debug: Print the current node being processed
        #Write-Host "Processing Node: $($Node.Name) - $($Node.InnerHtml.Trim())"

        # Process <DT> with <H3> (Groups)
        $h3Node = $Node.SelectSingleNode("h3")
        if ($h3Node -ne $null) {
            Write-Host "Found Group: $($h3Node.InnerText)"
            $currentGroup.Name = $h3Node.InnerText.Trim()
            $currentGroup.AddDate = $h3Node.GetAttributeValue("add_date", 0)
            $currentGroup.LastModified = $h3Node.GetAttributeValue("last_modified", 0)
        }

        # Process <DT> with <A> (Bookmarks)
        $anchorNodes = $Node.SelectNodes("a")
        if ($anchorNodes -ne $null) {
            foreach ($anchor in $anchorNodes) {
                Write-Host "Found Bookmark: $($anchor.InnerText)"
                $bookmark = @{
                    Name    = $anchor.InnerText.Trim()
                    Href    = $anchor.GetAttributeValue("href", "")
                    AddDate = $anchor.GetAttributeValue("add_date", 0)
                }
                $currentGroup.Bookmarks += $bookmark
            }
        }

        # Process child <DL> nodes
        $nextChildList = $child.SelectSingleNode("/dl")
        if ($nextChildList -ne $null) {
            Process-Node $nextChildList
        }

        return $currentGroup
    }

    # Find the root <DL> node
    $rootDlNode = $htmlDoc.DocumentNode.SelectSingleNode("/dl")
    if ($rootDlNode -eq $null) {
        Write-Error "No <DL> node found in the HTML file."
        return
    }

    Write-Host "Found Root <DL> Node"

    # Parse the root node
    $parsedTree = Process-Node -Node $rootDlNode

    # Convert to JSON and return
    $json = $parsedTree | ConvertTo-Json -Depth 100 -Compress
    return $json
}

# Example usage
$HtmlFile = "{0}\test2.html" -f "$PSScriptRoot"
$JsonFile = "{0}\out.json" -f "$PSScriptRoot"

$jsonOutput = Parse-HtmlBookmarksToJson -FilePath $HtmlFile

# Save JSON to a file
$jsonOutput | Out-File -FilePath "$JsonFile" -Encoding utf8

# Print the JSON
Write-Output $jsonOutput
