

<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   
#̷𝓍   Write-LogEntry
#̷𝓍   
#>

[CmdletBinding(SupportsShouldProcess)]
	param(
	    [Parameter(Mandatory = $false)]
	    [switch]$Test
	)

function ClonePath{
	[CmdletBinding(SupportsShouldProcess)]
	param(
	    [Parameter(Mandatory = $true,Position = 0)]
	    [string]$Src,
	    [Parameter(Mandatory = $true,Position = 1)]
	    [string]$Dst,
	    [Parameter(Mandatory = $false)]
	    [switch]$Test
	)
	
	$SrcLen = $Src.Length
	$DstLen = $Dst.Length
	if($SrcLen -ne $DstLen) { throw "Invalid PATH Entries"; }
	$SrcFiles = gci $Src -File -Recurse -ErrorVariable ListErrors -ErrorAction SilentlyContinue
	$SrcFilesCount = $SrcFiles.Count 
	Write-Host " Total of `"$SrcFilesCount`" source files" -f DarkRed
	$MissingFiles = 0
	[System.Collections.ArrayList]$CopiedFiles = [System.Collections.ArrayList]::new()
	ForEach($srcfile in $SrcFiles){
		$SrcFullName = $srcfile.Fullname 
		$SrcName = $srcfile.Name 
		$DstFullName = $SrcFullName.Replace($Src, $Dst)
		$DstDir = $DstFullName.Replace($SrcName,'')
		if(-not(Test-Path "$DstFullName")){
			if(-not(Test-Path "$DstDir")){
				$Null = New-Item -Path "$DstDir" -ItemType Directory -Force -ErrorAction Ignore
			}

			if($Test){
				$MissingFiles++
			}else{
				$MissingFiles++
			    Copy-Item "$SrcFullName" "$DstFullName" -Force -ErrorVariable CopyErrors -ErrorAction SilentlyContinue
			    [void]$CopiedFiles.Add($DstFullName)
			}
		}
	}
	Write-Host " Total of `"$MissingFiles`" Missing Files" -f DarkRed
	
	Set-Content "$PSScriptRoot\CopiedFiles.txt" -Value $CopiedFiles
	$ErrorsCount = $ListErrors.Count
	if($ErrorsCount -gt 0){
		ForEach($err in $ListErrors){
			$Message = $err.Exception.Message
			Write-Host "[ERROR] " -f DarkRed -n 
			Write-Host "$Message" -f DarkYellow
		}
	}
	$ErrorsCount = $CopyErrors.Count
	if($ErrorsCount -gt 0){
		ForEach($err in $CopyErrors){
			$Message = $err.Exception.Message
			Write-Host "[ERROR] " -f DarkRed -n 
			Write-Host "$Message" -f DarkYellow
		}
	}
}


$Src = "C:\Users\gp\AppData"
$Dst = "E:\Users\gp\AppData"

ClonePath "$Src" "$Dst" -Test:$Test