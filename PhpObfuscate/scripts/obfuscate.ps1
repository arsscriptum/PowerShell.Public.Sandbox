<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Get-PhpFnList{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            return $true
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path,
        [switch]$All
    )

    $FunctionPattern = "(?<FunctionTag>function)(\s*)(?<FunctionName>[\-a-zA-Z0-9]*)" 
    $IsFile = Test-Path -PathType Leaf -Path $Path
    $IsDirectory = Test-Path -PathType Container -Path $Path
    $TotalFnList = [System.Collections.ArrayList]::new()
    if($IsDirectory){
         $StrList = ( Get-ChildItem -Path $Path -Filter '*.php' | Select-String -Pattern $FunctionPattern )  # This will get a list of all the lines starting with 'function' followed by a space, then a word, then a '-' and a word.
    }else{
         $StrList = ( Get-Content -Path $Path | Select-String -Pattern $FunctionPattern )
    }

    ForEach ( $fn in $StrList){
        $FnName=$fn.Line.trim()        # get the Line key/value from the select-string object
        $NoExport=$FnName.IndexOf('NOEXPORT');
        if(($All -eq $false) -And ($NoExport -ne -1)){ Write-Verbose "NOEXPORT: skipping $FnName" ; continue ; }
        if($IsDirectory){
            $FnPath = $fn.Path
            $FnBase = (Get-Item -Path $Fn.Path).Basename
        }else{
            $FnPath = (Get-Item -Path $Path).Fullname
            $FnBase = (Get-Item -Path $Path).Basename
        }

        # Use RegEx instead of Select-FunctionName
        # $StrFunctionName = Select-FunctionName $FnName
        if($FnName -imatch $FunctionPattern){
            $StrFunctionName = $Matches.FunctionName
            $FunctionInfoObject = [PSCustomObject]@{
                Name = $StrFunctionName
                Base = $FnBase
                Path = $FnPath
                Alias= ''
            }

            $null=$TotalFnList.Add($FunctionInfoObject)
        }
    }
    return $TotalFnList | Sort-Object -Property Base | Select *
}

function Invoke-ChangePhpFuncNames{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory=$false, position = 1)]
        [string]$DestinationPath
    )
    Write-Verbose "[Invoke-ChangePhpFuncNames] Path is `"$Path`"" 
    $Path = (Resolve-Path "$Path").Path
    if([string]::IsNullOrEmpty($DestinationPath)){
        $DestinationPath = $Path
        Write-Verbose "[Invoke-ChangePhpFuncNames] Destination Path set to `"$DestinationPath`"" 
    }
    
    $Content = Get-Content -Path $Path -Raw
    $Fnames = (Get-PhpFnList $Path).Name
    ForEach($fn in $Fnames){
        if([string]::IsNullOrEmpty($fn)){ continue ; }
        [BigInt]$NumVal = ((Get-Date -UFormat "%s") -as [BigInt])
        $Guid = (New-Guid).Guid
        $RandIds = $Guid.Split('-')
        [BigInt]$NumVal = ((Get-Date -UFormat "%s") -as [BigInt]) / ( Get-Random -Maximum 9999999 )
        $NewFunctionName = "{0}{1}" -f (Get-RandomVerb), $RandIds[0]
        Write-Verbose "Changing `"$fn`" -> `"$NewFunctionName`""
        $Content = $Content.Replace("$fn", "$NewFunctionName")
    } 
    Write-Verbose "[Invoke-ChangePhpFuncNames] Writing file `"$DestinationPath`"" 
    Set-Content -Path "$DestinationPath" -Value $Content
    return "$DestinationPath"
}


function Invoke-PhpObfuscator{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, position=0)]
        [string]$Path,
        [Parameter(Mandatory=$true, position=1)]
        [string]$DestinationPath,
        [Parameter(Mandatory=$false)]
        [ValidateSet('CRC32','MD5','NUM')]
        [string]$RenamingMethod='CRC32',
        [Parameter(Mandatory=$false)]
        [switch]$RenameFunctions,
        [Parameter(Mandatory=$false)]
        [switch]$RemoveComments,
        [Parameter(Mandatory=$false)]
        [switch]$ObfuscateVariables,
        [Parameter(Mandatory=$false)]
        [switch]$EncodeStrings,
        [Parameter(Mandatory=$false)]
        [switch]$UseHexValuesForNames,
        [Parameter(Mandatory=$false)]
        [switch]$RemoveWhitespaces,
        [Parameter(Mandatory=$false)]
        [switch]$PrefixDelimiter,
        [Parameter(Mandatory=$false)]
        [ValidateSet(8,12,16,24,32)]
        [int]$Md5Length=8,
        [Parameter(Mandatory=$false)]
        [ValidateRange(0,8)]
        [int]$PrefixLength=2,
        [Parameter(Mandatory=$false)]
        [switch]$Test
    )

    try{

        $PathSrc = (Resolve-Path "$Path").Path
        $Content = ''
        if($Test){
            Remove-Item -Path "$PSScriptRoot\test" -Recurse -Force -ErrorAction Ignore | Out-Null
            New-Item -Path "$PSScriptRoot\test" -ItemType Directory -Force -ErrorAction Ignore | Out-Null
        }
        if($RenameFunctions){

            $PathTmp = Invoke-ChangePhpFuncNames $PathSrc "$PSScriptRoot\tmp_change_function_names.php"
            $Content = Get-Content -Path $PathTmp -Raw
            if($Test){
                Write-Verbose "Moving file `"$PathTmp`" to `"$PSScriptRoot\test`"" 
                Move-Item "$PathTmp" "$PSScriptRoot\test"
            }else{
                Write-Verbose "Removing file `"$PathTmp`""
                Remove-Item "$PathTmp" -Force -ErrorAction Ignore | Out-Null
            }
            
        }else{
            $PathDst = (Resolve-Path "$Path").Path
            $Content = Get-Content -Path $PathDst -Raw
        }

        $TagPhpStart = '<?php'
        $TagPhpEnd = '?>'
        $Start = $Content.IndexOf($TagPhpStart)
        $End = $Content.IndexOf($TagPhpEnd)
        $PhpContent = $Content.Substring($Start,($End-$Start)+($TagPhpEnd.Length))
        $HtmlContent = $Content.Remove($Start,($End-$Start)+($TagPhpEnd.Length))
        if($Test){
            $PathPhpContent = "$PSScriptRoot\test\PhpContent.php"
            Set-Content -Path "$PathPhpContent" -Value $PhpContent
            Write-Verbose "Writing file `"$PathPhpContent`""
        }
        if($Test){
            $PathHtmlContent = "$PSScriptRoot\test\HtmlContent.php"
            Set-Content -Path "$PathHtmlContent" -Value $HtmlContent
            Write-Verbose "Writing file `"$PathHtmlContent`""
        }
        Add-Type -AssemblyName System.Web
        $encodedPhpCode = [System.Web.HttpUtility]::UrlEncode($PhpContent) 

        $BodyStr = "p_source={0}" -f $encodedPhpCode

        if($RemoveComments){
            $BodyStr = $BodyStr + "&p_obcom=1"
        }
        if($ObfuscateVariables){
            $BodyStr = $BodyStr + "&p_obvar=1"
        }
        if($EncodeStrings){
            $BodyStr = $BodyStr + "p_obstr=1"
        }
        if($UseHexValuesForNames){
            $BodyStr = $BodyStr + "p_obashex=1"
        }
        if($RemoveWhitespaces){
            $BodyStr = $BodyStr + "&p_obspc=1"
        }
        if($PrefixDelimiter){
            $BodyStr = $BodyStr + "&p_obpredelim=_"
        }else{
            $BodyStr = $BodyStr + "&p_obpredelim="
        }
        $BodyAdd = "&p_obmethod={0}&p_obprelen={1}&p_obmd5len={2}&submit=Obfuscate+Source+Code&p_send=1" -f $RenamingMethod,$PrefixLength,$Md5Length
        $BodyStr = $BodyStr + $BodyAdd 
        if($Test){
            $PathBodyContent = "$PSScriptRoot\test\BodyContent.php"
            Set-Content -Path "$PathBodyContent" -Value $BodyStr
            Write-Verbose "Writing file `"$PathBodyContent`""
        }
        $MyHeaders = @{
        "authority"="www.gaijin.at"
          "method"="POST"
          "path"="/en/tools/php-obfuscator"
          "scheme"="https"
          "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
          "accept-encoding"="gzip, deflate, br"
          "cache-control"="no-cache"
          "origin"="https://www.gaijin.at"
          "referer"="https://www.gaijin.at/en/tools/php-obfuscator"
        }
        $Url = "https://www.gaijin.at/en/tools/php-obfuscator"
        $CntType = "application/x-www-form-urlencoded"
        $Ret = Invoke-WebRequest -UseBasicParsing -Uri "$Url" -Method "POST" -Headers $MyHeaders -ContentType "$CntType" -Body "$BodyStr"
        $RetStatusCode = $Ret.StatusCode 
        if($RetStatusCode -ne 200) { throw "invalid server response" }
        Write-Verbose "RetStatusCode `"$RetStatusCode`"" 
        $RetContent = $Ret.Content 
        $TagHtmlEncodedPhpStart = '&lt;?php'
        $TagHtmlEncodedPhpEnd = '?&gt;'
        $CodedTag = '<div class="box_form"><form><textarea'
        if($Test){
            $PathWebRequestContent = "$PSScriptRoot\test\WebRequest.php"
            Set-Content -Path "$PathWebRequestContent" -Value $RetContent
            Write-Verbose "Writing file `"$PathHtmlContent`"" 
        }
        $CodedTagIndex = $RetContent.LastIndexOf($CodedTag)
        $StartIndex = $RetContent.IndexOf($TagHtmlEncodedPhpStart,$CodedTagIndex)
        $EndIndex = $RetContent.IndexOf($TagHtmlEncodedPhpEnd,$CodedTagIndex)

        $PhpContent = $RetContent.Substring($StartIndex,($EndIndex-$StartIndex)+($TagHtmlEncodedPhpEnd.Length))
        $PhpContent = [System.Web.HttpUtility]::HtmlDecode($PhpContent) 
        $PhpContent = $PhpContent.Replace($TagHtmlEncodedPhpStart,$TagPhpStart).Replace($TagHtmlEncodedPhpEnd,$TagPhpEnd)
        # Bug Fix
        $PhpContent = $PhpContent.Replace('returnisset','return isset')
        $NewPhpContent = $HtmlContent.Insert($Start, $PhpContent)
        Set-Content -Path "$DestinationPath" -Value $NewPhpContent
        $DestinationPath
    }catch{
        Write-Error "$_"
    }
}

