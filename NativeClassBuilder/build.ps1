
function Get-LocalSourcePath{   
    $ModPath = (Get-CoreModuleInformation).ModuleScriptPath
    $LocalSourcePath = (Resolve-Path "$PSScriptRoot\cs").Path
    return $LocalSourcePath
}

function Register-NativeClass{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [string]$NameSpace = 'AssemblyResourcesCore',
        [Parameter(Mandatory = $false)]
        [string]$ClassName = 'AssemblyHelper',
        [Parameter(Mandatory = $false)]
        [ValidateSet('AssemblyHelper','SetEncoding','CryptoHelper')]
        [string]$FileName = 'AssemblyHelper',
        [Parameter(Mandatory = $false)]
        [Switch]$Random
    )
    if($Random){
        $Guid1 = ((New-Guid).Guid -as [string]).SubString(0,2)
        $Guid2 = ((New-Guid).Guid -as [string]).SubString(2,2)
        $NameSpace += "_" + $Guid1
        #$ClassName += $Guid2
    }
    Write-Host "New Type [$NameSpace.$ClassName]" -f Red
    
    $LocalSourcePath = Get-LocalSourcePath
    $tpl_file = "{0}_Template.cs" -f $FileName
    $cs_file = "{0}.cs" -f $FileName
    $CsSourceTpl = (Join-Path $LocalSourcePath $tpl_file)  
    $CsSource = (Join-Path $LocalSourcePath $cs_file)  
    $Source = Get-Content $CsSourceTpl -Raw
    $Source = $Source.Replace('__NAMESPACE_NAME_PLACEHOLDER__',$NameSpace).Replace('__CLASS_NAME_PLACEHOLDER__',$ClassName)
    Set-Content -Path "$CsSource" -Value "$Source"
    $Ret = $Null
    if (!("$NameSpace" -as [type])) {
        Write-Verbose "Registering $CsSource... " 
        $Ret = Add-Type -Path "$CsSource" -Passthru
        ForEach($o in $Ret){
            $AssemblyName = $o.Name 
            $Str = $o  | gm -Static | Where MemberType -eq 'Method' | Select -Skip 4 |  select Name, Definition | Out-String
            $StrList = $Str.Split("`r`n")
            $StrList = $StrList  | Select -Skip 3 | Select -SkipLast 2
            Write-Host "`n======================================" -f DarkCyan
            Write-Host " [$NameSpace.$AssemblyName] Static Members" -f Yellow
            Write-Host "--------------------------------------" -f DarkCyan
            ForEach($line in $StrList){
                Write-Host "   $line" -f Magenta
            }
        } 
    }else{
        Write-Verbose "$NameSpace already registered: $CsSource... " 
    }
    $Ret
}

$Null = Register-NativeClass -Random