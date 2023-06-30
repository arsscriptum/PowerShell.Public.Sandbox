
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position=0, HelpMessage="The plainText")]
        [string]$plainText,
        [Parameter(Mandatory = $false,Position=1, HelpMessage="The password")] 
        [string]$passwd="secret"
    )
    $Result = ''
    $plainText = $plainText.Trim()
    try{
        $CodeSecureString = ConvertTo-SecureString $plainText -AsPlainText -Force
        $Result = ConvertFrom-SecureString -SecureString $CodeSecureString
        
    }catch{
        $Result = "<ERROR OCCURED>"
        Write-Error $_
    }
    $Result




