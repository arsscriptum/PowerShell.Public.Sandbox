<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding(SupportsShouldProcess)]
Param (
    [parameter(Mandatory=$False, HelpMessage="This argument is for development purposes only. It help for testing.")]
    [switch]$TestMode
)


function Get-ImgPath{ 
    [CmdletBinding(SupportsShouldProcess)]
    Param ()  
    $ScriptPath = $PSScriptRoot
    $imgpath = Join-Path $ScriptPath 'img'
    return $imgpath
}

function Get-ContentBytes{ 
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [parameter(Mandatory=$true)]
        [string]$Path
    )
    if($PSVersionTable.PSEdition -eq 'Core'){
        return ((Get-Content -Path "$Path" -AsByteStream) -As [byte[]])
    }else{
        return ((Get-Content -Path "$Path" -Encoding Byte) -As [byte[]])
    }

}



$ImageScriptName = "$PSScriptRoot\scripts\Images.ps1"
Set-Content -Path "$ImageScriptName" -Value "# images definitions`n`n"
$i = 0
$AllImages = (Get-ChildItem (Get-ImgPath) -File).Fullname
ForEach($img in $AllImages){
   # create a byte array from our image file
	Write-Host "Creating ByteArray from $img" -f Blue
    [byte[]]$DataBuffer = Get-ContentBytes -Path "$img" 

    # from the byet aray, create a base 64 string representing our file...
    $Base64JsonData = [System.Convert]::ToBase64String($DataBuffer)

    # create a code block to add to our script
    $StrToAdd = "`$Image_{0:d3} = `"{1}`" " -f $i++, $Base64JsonData

    # adding a string variable in the script
    Add-Content -Path "$ImageScriptName" -Value "$StrToAdd"
}