<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory = $True,Position=0, HelpMessage="The plain text to encrypt")]
        [string]$Cipher,
        [Parameter(Mandatory = $True,Position=1, HelpMessage="The password")] 
        [string]$Password
    )
    Write-Verbose "CaesarDecrypt `"$Cipher`" `"$Password`""
    . "$PSScriptRoot\CaesarDefinition.ps1"
    if(-not 'Cryptography.Caesar' -as [Type]){
        Write-Verbose "Add-Type -TypeDefinition Ceasar"
        Add-Type -TypeDefinition $Ceasar
    }

    $Result = [Cryptography.Caesar]::Decrypt($Cipher,$Password)
    $Result



