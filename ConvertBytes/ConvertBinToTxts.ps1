

Function Convert-BinToTxts{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Array of Bytes to use for CRC calculation
        [Parameter(Mandatory=$true, Position = 0)]  
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
                throw "The Destination Path argument must be a file. Directory paths are not allowed."
            }
            return $true 
        })]
        [string]$inputFilePath,
        [Parameter(Mandatory=$true, Position = 1)]  
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Container) ){
                throw "The Destination Path argument must be a file. Directory paths are not allowed."
            }
            return $true 
        })]
        [string]$outputDirectory        
    )

    try{

        # Read all bytes from the file
        $fileBytes = [System.IO.File]::ReadAllBytes($inputFilePath)

        # Convert the bytes to Base64 string
        $base64String = [Convert]::ToBase64String($fileBytes)

        # Define the block size (100KB in characters)
        $blockSize = 1024 * 100

        # Split the Base64 string into blocks of 100KB each
        $blocks = -split ($base64String -replace "(.{$blockSize})", '$1 ')

        # Write each block to a separate text file
        for ($i = 0; $i -lt $blocks.Length; $i++) {
            $fname = "file_{0:d3}.cpp" -f $i
            $blockFileName = [System.IO.Path]::Combine($outputDirectory, $fname)
            [System.IO.File]::WriteAllText($blockFileName, $blocks[$i])
        }

        Write-Output "Files created successfully in $outputDirectory"

    }catch{
        Show-ExceptionDetails ($_) -ShowStack
    }
}



Function Convert-TxtsToBin{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Array of Bytes to use for CRC calculation
        [Parameter(Mandatory=$true, Position = 0)]  
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Container) ){
                throw "The Destination Path argument must be a file. Directory paths are not allowed."
            }
            return $true 
        })]
        [string]$inputDirectory,
        [Parameter(Mandatory=$true, Position = 1)]  
        [ValidateScript({
            if($_ | Test-Path -PathType Leaf){
                throw "Files already exists!"
            }
            return $true 
        })]
        [string]$outputFilePath 
    )

    try{

        # Get all text files in the directory, sorted by name
        $textFiles = Get-ChildItem -Path $inputDirectory -Filter "*.cpp" | Sort-Object Name

        # Initialize an empty string to hold the concatenated Base64 data
        $base64String = ""

        # Read each text file and append its content to the Base64 string
        foreach ($file in $textFiles) {
            $base64String += Get-Content -Path $file.FullName -Raw
        }

        # Convert the Base64 string back to a byte array
        $fileBytes = [Convert]::FromBase64String($base64String)

        # Write the byte array to the output binary file
        [System.IO.File]::WriteAllBytes($outputFilePath, $fileBytes)

        Write-Output "Binary file created successfully at $outputFilePath"

    }catch{
        Show-ExceptionDetails ($_) -ShowStack
    }
}


function Get-MD5Hash($filePath) {
    $md5 = [System.Security.Cryptography.MD5]::Create()
    $fileStream = [System.IO.File]::OpenRead($filePath)
    $hashBytes = $md5.ComputeHash($fileStream)
    $fileStream.Close()
    return [BitConverter]::ToString($hashBytes) -replace "-", ""
}



$f1 = "D:\tmp\DejaInsight.zip"
$f2 = "D:\tmp\DejaInsight_Copy.zip"
$o = "d:\out"

New-Item -Path "$o" -ItemType Directory -Force -ErrorAction Ignore | Out-Null

Convert-BinToTxts $f1 $o

Convert-TxtsToBin $o $f2

# Compute the MD5 hashes of the two files
$hash1 = Get-MD5Hash $f1
$hash2 = Get-MD5Hash $f2

# Compare the hashes
if ($hash1 -eq $hash2) {
    Write-Output "The files are identical."
} else {
    Write-Output "The files are different."
}

Write-Output "Hash of file 1: $hash1"
Write-Output "Hash of file 2: $hash2"