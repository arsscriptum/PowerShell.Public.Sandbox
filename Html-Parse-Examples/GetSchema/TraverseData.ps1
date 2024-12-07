[CmdletBinding(SupportsShouldProcess)]
param()

# Load HtmlAgilityPack
$Path = "{0}\lib\{1}\HtmlAgilityPack.dll" -f "$PWD", "$($PSVersionTable.PSEdition)"
Add-Type -Path $Path

function Traverse-Html {
    param (
        [HtmlAgilityPack.HtmlNodeNavigator]$Navigator
    )

    # Process all <DL> tags
    while ($Navigator.MoveToFollowing("dl", "")) {
        Write-Output "Found <DL> tag"
        
        # Process all <DT> tags inside the current <DL>
        if ($Navigator.MoveToFirstChild()) {
            do {
                if ($Navigator.LocalName -eq "dt") {
                    Write-Output "Found <dt> tag: $($Navigator.InnerXml)"
                }

                # Recursively process nested <DL> tags
                if ($Navigator.LocalName -eq "dl") {
                    Traverse-Html -Navigator $Navigator.Clone()
                }
            } while ($Navigator.MoveToNext())
            # Return to the parent level to continue processing siblings
            $Navigator.MoveToParent() | Out-Null
        }
    }
}
# Load your HTML file
$htmlDoc = New-Object HtmlAgilityPack.HtmlDocument
$HtmlFile = "{0}\test2.html" -f "$PWD"
$htmlDoc.Load($HtmlFile)

# Start traversing from the document root
$navigator = $htmlDoc.CreateNavigator()
$nav_it = $navigator.SelectSingleNode('/dl')
Traverse-Html -Navigator $nav_it

