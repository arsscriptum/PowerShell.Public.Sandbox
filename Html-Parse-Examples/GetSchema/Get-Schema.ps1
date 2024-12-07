
[CmdletBinding(SupportsShouldProcess)]
param()

function Add-JsonBookmark {
    param (
        [Parameter(Mandatory=$False)]
        [string]$Name='n/a',
        
        [Parameter(Mandatory=$False)]
        [string]$Url='https://empty.com',
        
        [Parameter(Mandatory=$False)]
        [uint64]$AddedDate=0
    )
        
    [PsCustomObject]$bookmark = @{
        Name      = $Name
        Url       = $Url
        AddedDate = $AddedDate
    }
    
    $bookmark
}

function Add-JsonDirectory {
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        
        [Parameter(Mandatory)]
        [uint64]$AddedDate,
        
        [Parameter()]
        [System.Collections.ArrayList]$Bookmarks
    )
    
    [PsCustomObject]$directory = @{
        Name       = $Name
        AddedDate  = $AddedDate
        Bookmarks  = $Bookmarks
    }
    
    $JsonData = $directory | ConvertTo-Json
    $JsonData
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


function Get-HtmlSchema2 {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )


   try{
        Add-Type -AssemblyName System.Web  

        $Null = Register-HtmlAgilityPack 
      
        # Load HTML content
        $htmlDoc = New-Object HtmlAgilityPack.HtmlDocument
        $htmlDoc.Load($FilePath)

        function Write-HtmlNode {
            param ($Node, $Indent = 0)

            # Print current node
            Write-Output (" " * $Indent + "<" + $Node.Name + ">")

            # Recursively print child nodes
            foreach ($Child in $Node.ChildNodes) {
                if ($Child.NodeType -eq "Element") {
                    Write-HtmlNode $Child ($Indent + 2)
                }
            }
        }

        # Start with the document's root node
        Write-HtmlNode $htmlDoc.DocumentNode
    }catch{
        Write-Error "$_"
    }
}

function Get-HtmlSchema {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    try {
        # Load HtmlAgilityPack
        $Path = "{0}\lib\{1}\HtmlAgilityPack.dll" -f "$PSScriptRoot", "$($PSVersionTable.PSEdition)"
        Add-Type -Path "$Path"

        # Load the HTML document
        $htmlDoc = New-Object HtmlAgilityPack.HtmlDocument
        $htmlDoc.Load($FilePath)

        function Write-HtmlNode {
            param ($Node, $Indent = 0)

            # Skip #text and #comment nodes
            if ($Node.Name -ne "#text" -and $Node.Name -ne "#comment") {
                # Print the current node with attributes
                $attributes = ($Node.Attributes | ForEach-Object { "$($_.Name)='$($_.Value)'" }) -join " "
                Write-Output (" " * $Indent + "<" + $Node.Name + " " + $attributes + ">")
                
                # Print the node's text content if it has any
                if ($Node.InnerText.Trim() -and $Node.ChildNodes.Count -eq 0) {
                    Write-Output (" " * ($Indent + 2) + $Node.InnerText.Trim())
                }
            }

            # Recursively print child nodes
            foreach ($Child in $Node.ChildNodes) {
                Write-HtmlNode $Child ($Indent + 2)
            }
        }

        # Start printing the schema
        Write-HtmlNode $htmlDoc.DocumentNode

    } catch {
        Write-Error "An error occurred: $_"
    }
}





function Get-HtmlBookmarks {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )


    # Define BookmarkItem class
    class BookmarkItem {
        [string]$Name
        [int]$AddDate
        [string]$Href
        [string]$Guid 
        [string]$ParentGuid
        BookmarkItem([string]$pguid) {
            $this.Guid = (New-Guid).Guid
            $this.ParentGuid = $pguid
        }

        BookmarkItem([string]$pguid, [string]$name, [int]$addDate, [string]$href) {
            $this.Name = $name
            $this.AddDate = $addDate
            $this.Href = $href
            $this.Guid = (New-Guid).Guid
            $this.ParentGuid = $pguid
        }
    }

    # Define BookmarkGroup class
    class BookmarkGroup {
        [string]$Name
        [int]$LastModified
        [int]$AddDate
        [string]$Guid 
        [string]$ParentGuid
        [System.Collections.Generic.List[BookmarkGroup]]$ChildGroups
        [System.Collections.Generic.List[BookmarkItem]]$Bookmarks

        BookmarkGroup( [string]$pguid ) {
            $this.ChildGroups = [System.Collections.Generic.List[BookmarkGroup]]::new()
            $this.Bookmarks = [System.Collections.Generic.List[BookmarkItem]]::new()
            $this.Guid = (New-Guid).Guid
            $this.ParentGuid = ''
        }

        BookmarkGroup([string]$pguid, [string]$name, [int]$lastModified, [int]$addDate) {
            $this.Name = $name
            $this.LastModified = $lastModified
            $this.AddDate = $addDate
            $this.ChildGroups = [System.Collections.Generic.List[BookmarkGroup]]::new()
            $this.Bookmarks = [System.Collections.Generic.List[BookmarkItem]]::new()
            $this.Guid = (New-Guid).Guid
            $this.ParentGuid = ''  
        }

        [void]AddChildGroup([BookmarkGroup]$childGroup) {
            $childGroup.ParentGuid = $this.Guid
            $this.ChildGroups.Add($childGroup)
        }

        [void]AddBookmark([BookmarkItem]$bookmark) {
            $this.Bookmarks.Add($bookmark)
        }
    }

    $JsonFile = "$PSScriptRoot\bm.json"
    Remove-Item -Path "$JsonFile" -Force -ErrorAction Ignore | Out-Null
    New-Item -Path "$JsonFile" -ItemType File -Force -ErrorAction Ignore | Out-Null
    try {
        # Load HtmlAgilityPack
        $Path = "{0}\lib\{1}\HtmlAgilityPack.dll" -f "$PSScriptRoot", "$($PSVersionTable.PSEdition)"
        Add-Type -Path "$Path"

        # Load the HTML document
        $htmlDoc = New-Object HtmlAgilityPack.HtmlDocument
        $htmlDoc.Load($FilePath)
        function Process-Node {
            param (
                [HtmlAgilityPack.HtmlNode]$Node,
                [BookmarkGroup]$ParentGroup,
                [int]$Depth = 0
            )
            $Indent = 2 * $Depth
            $IndentString = ''
            if($Indent -gt 2){
                $IndentSpaces = $Indent - 2
                $IndentString = [string]::new(" ",$IndentSpaces)
                $IndentString += '|-'
            }
      

            # Check if the current node is a DT or DL
            if ($Node.Name -eq "dt" -or $Node.Name -eq "dl") {
                $newGroup = [BookmarkGroup]::new($ParentGroup.Guid)

                if($Node.Name -eq "dt"){
                    $tag_info = $Node.SelectSingleNode('h3') 
                    
                    if($tag_info){
                        $tagname = $tag_info.InnerText
                        $last_modified = $tag_info.GetAttributeValue('last_modified',0)
                        $hr_lastModifiedDate = [DateTimeOffset]::FromUnixTimeSeconds($last_modified).DateTime
                        $add_date = $tag_info.GetAttributeValue('add_date',0)
                        $hr_addDate = [DateTimeOffset]::FromUnixTimeSeconds($add_date).DateTime

                        $GroupDate = $add_date
                        $GroupName = $tagname
                        $newGroup.LastModified = $last_modified
                        $newGroup.AddDate = $add_date
                       
                        
                        $parentGroupName = $ParentGroup.Name
                        $groupName = $newGroup.Name


                        $ParentGroup.AddChildGroup($newGroup)
                        #Write-Host "$parentGroupName add child $groupName"
                        
                    }   
                    
                    $achilds = $Node.SelectSingleNode('a')
                    [System.Collections.ArrayList]$ChildBookmarksJson = [System.Collections.ArrayList]::new()
                    foreach ($ac in $achilds) {
                        $link_name = $ac.InnerText
                        $link_url = $ac.GetAttributeValue('href','')
                        $add_date = $ac.GetAttributeValue('add_date',0)
                        $hr_addDate = [DateTimeOffset]::FromUnixTimeSeconds($add_date).DateTime
                        #Write-Host "$IndentString link $link_name"
                        # Create and add a new bookmark item
                        $bookmarkItem = [BookmarkItem]::new($newGroup.Guid,$link_name, $add_date, $link_url)
                        $newGroup.AddBookmark($bookmarkItem)

                        #$child_bm = Add-JsonBookmark -Name "$link_name" -Url "$link_url" -AddedDate $add_date
                        [void]$ChildBookmarksJson.Add($child_bm)
                        #Write-Output "$child_bm"
                    }
                 
                   
                       # $directoryJson = Add-JsonDirectory -Name $GroupName -AddedDate $GroupDate -Bookmarks $ChildBookmarksJson
                       # Write-Output "$directoryJson"
                       # Add-Content -Path "$JsonFile" -Value "$directoryJson"
                    
                    
                    $ParentGroup.AddChildGroup($newGroup)
                }
            }
            
            foreach ($Child in $Node.ChildNodes) {
                Process-Node -Node $Child -ParentGroup $ParentGroup -Depth ($Depth + 1)
           }
        }
        # Create a root group to hold all bookmarks
        $rootGroup = [BookmarkGroup]::new('ooo',"Root", 0, 0)
        $FirstNode = $htmlDoc.DocumentNode.SelectSingleNode('/dl')
        Process-Node -Node $FirstNode -ParentGroup $rootGroup
        $rootGroup
    } catch {
        Show-ExceptionDetails ($_) -ShowStack
    }
}



$HtmlFile = "$PSScriptRoot\test2.html"
Get-HtmlBookmarks -FilePath $HtmlFile
