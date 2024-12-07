function Add-JsonBookmark {
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        
        [Parameter(Mandatory)]
        [string]$Url,
        
        [Parameter(Mandatory)]
        [uint64]$AddedDate
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

# Example usage:

# Add individual bookmarks
$bookmark1 = Add-JsonBookmark -Name "Example Bookmark 1" -Url "http://example1.com" -AddedDate 123
$bookmark2 = Add-JsonBookmark -Name "Example Bookmark 2" -Url "http://example2.com" -AddedDate 123

# Create a directory with bookmarks
$directoryJson = Add-JsonDirectory -Name "My Directory" -AddedDate 123 -Bookmarks @($bookmark1, $bookmark2)

# Output the directory JSON
$directoryJson
