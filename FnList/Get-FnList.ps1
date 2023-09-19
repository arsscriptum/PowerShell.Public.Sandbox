
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

function Get-WritableModulePath_V2{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Permissions")]
        [string[]]$Permissions=@('Modify','FullControl','Write')
    )
    $VarModPath=[System.Environment]::GetEnvironmentVariable("PSModulePath")
    $Paths=$VarModPath.Split(';')

    Write-Verbose "Get-WriteableFolder from $Path and $PathsCount childs"
    # 1 -> Retrieve my appartenance (My Groups)
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $groups = $id.Groups | foreach-object {$_.Translate([Security.Principal.NTAccount])}
    $GroupList = @() ; ForEach( $g in $groups){  $GroupList += $g ; }
    Sleep -Milliseconds 500
    $PathPermissions =  [System.Collections.ArrayList]::new()   

    $aclfilter_perm = {
        $ir=$_.IdentityReference;$fsr=$_.FileSystemRights.ToString();$hasright=$false;
        ForEach($pxs in $Permissions){ if($fsr -match $pxs){$hasright=$True;}};
        $GroupList.Contains($ir) -and $hasright
    }
    ForEach($p in $Paths){
        if(-not(Test-Path -Path $p -PathType Container)) { continue; }
        $perm = (Get-Acl $p).Access | Where $aclfilter_perm | Select `
                                 @{n="Path";e={$p}},
                                 @{n="IdentityReference";e={$ir}},
                                 @{n="Permission";e={$_.FileSystemRights}}
        if( $perm -ne $Null ){
            $null = $PathPermissions.Add($perm)
        }
    }

    return $PathPermissions
}


function Get-ModulePath_V2{
    $VarModPath=$env:PSModulePath
    $Paths=$VarModPath.Split(';').ToLower()
    $WritablePaths=(Get-WritableModulePath).Path.ToLower()
    $Modules = [System.Collections.ArrayList]::new()
    ForEach($dir in $Paths){
        if(-not(Test-Path $dir)){ continue;}
        $Childrens = (gci $dir -Directory)
        $Mod = [PSCustomObject]@{
                Path            = $dir
                Writeable        = $WritablePaths.Contains($dir)
                Childrens       = $Childrens.Count
            }
        $Null = $Modules.Add($Mod)
    }
    return $Modules
}



function Get-FunctionList_V2 {
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

    $FunctionPattern = "^(?<FunctionTag>function|Function)(\s*)(?<FunctionName>[\-a-zA-Z0-9]*)"
    $IsFile = Test-Path -PathType Leaf -Path $Path
    $IsDirectory = Test-Path -PathType Container -Path $Path
    $TotalFnList = [System.Collections.ArrayList]::new()
    if($IsDirectory){
         $StrList = ( Get-ChildItem -Path $Path -Filter '*.ps1' | Select-String -Pattern $FunctionPattern )  # This will get a list of all the lines starting with 'function' followed by a space, then a word, then a '-' and a word. 
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
