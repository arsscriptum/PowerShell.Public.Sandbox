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
    Write-Verbose "AESDecrypt `"$Cipher`" `"$Password`""
    . "$PSScriptRoot\AES-Type.ps1"
    if(-not 'Cryptography.AES' -as [Type]){
        Write-Verbose "Add-Type -TypeDefinition AES"
        Add-Type -TypeDefinition $AesType
    }

    $Result = [Cryptography.AES]::Decrypt($Cipher,$Password)
    $Result



