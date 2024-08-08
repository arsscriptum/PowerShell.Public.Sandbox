# Function to get directory hash
function Get-DirectoryHash {
    param (
        [string]$DirectoryPath,
        [string]$Algorithm = "SHA256"  # Default to SHA256, can be changed to MD5, SHA1, etc.
    )

    # Ensure the directory exists
    if (-not (Test-Path -Path $DirectoryPath -PathType Container)) {
        throw "The specified directory '$DirectoryPath' does not exist."
    }

    # Create a new hash algorithm object
    $hashAlgo = [System.Security.Cryptography.HashAlgorithm]::Create($Algorithm)
    if (-not $hashAlgo) {
        throw "Invalid hash algorithm specified: $Algorithm"
    }

    # Initialize a combined hash byte array
    $combinedHashBytes = @()

    # Get all files in the directory recursively
    $files = Get-ChildItem -Path $DirectoryPath -File -Recurse | Sort-Object -Property FullName

    foreach ($file in $files) {
        # Read the file contents
        $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)

        # Compute the hash of the file contents
        $fileHashBytes = $hashAlgo.ComputeHash($fileBytes)

        # Combine the file hash with the combined hash
        $combinedHashBytes += $fileHashBytes
    }

    # Compute the final hash of the combined hash bytes
    $finalHashBytes = $hashAlgo.ComputeHash($combinedHashBytes)

    # Convert the final hash bytes to a hex string
    $finalHashString = [BitConverter]::ToString($finalHashBytes) -replace '-', ''

    return $finalHashString
}

# Main script
$baseDir = "C:\Programs\Sysinternals"
$preInstalledPackagesDir = "$baseDir\PreInstalledPackages"
$suiteDir = "$baseDir\Suite"
$zipUrl = "https://download.sysinternals.com/files/SysinternalsSuite.zip"
$zipPath = "$preInstalledPackagesDir\SysinternalsSuite.zip"
$expectedHash = "DEC05EFBFB3EE2FDDEE729E58BE5F8CBA9C5B27D4F13369623A6F3D462917C52"
$expectedItemCount = 160

# Create directories if they do not exist
if (-not (Test-Path -Path $baseDir -PathType Container)) {
    New-Item -Path $baseDir -ItemType Directory
}
if (-not (Test-Path -Path $preInstalledPackagesDir -PathType Container)) {
    New-Item -Path $preInstalledPackagesDir -ItemType Directory
}
if (-not (Test-Path -Path $suiteDir -PathType Container)) {
    New-Item -Path $suiteDir -ItemType Directory
}

# Check if the suite directory exists and has the expected number of items and hash
if (Test-Path -Path $suiteDir -PathType Container) {
    $itemCount = (Get-ChildItem -Path $suiteDir -Recurse).Count
    if ($itemCount -eq $expectedItemCount) {
        $currentHash = Get-DirectoryHash -DirectoryPath $suiteDir
        if ($currentHash -eq $expectedHash) {
            Write-Output "The directory already contains the expected files and hash. Exiting."
            return
        }
    }
}

# Download the zip package
Write-Output "Downloading Sysinternals Suite..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

# Expand the archive
Write-Output "Extracting Sysinternals Suite..."
Expand-Archive -Path $zipPath -DestinationPath $suiteDir -Force

# Add the suite directory to the PATH environment variable for the User scope
$path = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
if ($path -notlike "*$suiteDir*") {
    [System.Environment]::SetEnvironmentVariable("PATH", "$path;$suiteDir", [System.EnvironmentVariableTarget]::User)
    Write-Output "Added $suiteDir to the PATH environment variable."
} else {
    Write-Output "$suiteDir is already in the PATH environment variable."
}

Write-Output "Sysinternals Suite installation and setup complete."
