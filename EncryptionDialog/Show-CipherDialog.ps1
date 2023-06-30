<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding(SupportsShouldProcess)]
Param (
    [parameter(Mandatory=$False, HelpMessage="This argument is for development purposes only. It help for testing.")]
    [switch]$TestMode
)

[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null



function Get-ImgPath{ 
    [CmdletBinding(SupportsShouldProcess)]
    Param ()  
    $ScriptPath = $PSScriptRoot
    $imgpath = Join-Path $ScriptPath 'img'
    return $imgpath
}

function Get-CiphersPath{ 
    [CmdletBinding(SupportsShouldProcess)]
    Param ()  
    $ScriptPath = $PSScriptRoot
    $cipherspath = Join-Path $ScriptPath 'ciphers'
    return $cipherspath
}

$ciphers = Get-CiphersPath

$caesar = Join-Path $ciphers 'CaesarDefinition.ps1'
$aes = Join-Path $ciphers 'AES-Type.ps1'

. "$aes"
. "$caesar"

Add-Type -TypeDefinition $Caesar -PassThru

Add-Type -TypeDefinition $AesType -PassThru


function Get-CiphersList{ 
    [CmdletBinding(SupportsShouldProcess)]
    Param ()  
    $ScriptPath = $PSScriptRoot
    $filepath = Join-Path $ScriptPath "ciphers.json"
    [system.collections.arraylist]$cipher_list = Get-Content $filepath | ConvertFrom-Json
    $cipher_list
}




Function Out-Message{
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [String]$Message,
        [parameter(Mandatory=$false)]
        [Alias('n')]
        [switch]$NewLine,
        [parameter(Mandatory=$false)]
        [Alias('c')]
        [switch]$Clear
    )
    Write-Verbose "Out-Message $Message $Type"
  
    if($Clear) { $OutputStream.Text = "" } 

    if ($NewLine) {
        $OutputStream.Text += "$Message`n"
    }
    else  {
        $OutputStream.Text += $Message
    }
    
}

try{
    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

    $ImgPath = Get-ImgPath
    Write-Verbose "Get-ImgPath $ImgPath"
    $ImgSrc = (Join-Path $ImgPath "BackGround.jpg")

    #Load required libraries 

    [xml]$xaml = @"

<Window
            xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
            xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
            xmlns:local="clr-namespace:WpfApp10"
            Title="Reddit Support - Encrypt Tool" Height="463.632" Width="476.995" ResizeMode="NoResize" Topmost="True" WindowStartupLocation="CenterScreen">

    <Grid>
        <Image HorizontalAlignment="Left" Height="419" VerticalAlignment="Top" Width="469" Source="$PSScriptRoot\img\BackGround.jpg" Margin="0,0,0,-58"/>
        <Label Name='Url' Content='by http://arsscriptum.github.io' HorizontalAlignment="Left" Margin="10,70,0,0" VerticalAlignment="Top" Foreground="Gray" Cursor='Hand' ToolTip='by http://arsscriptum.github.io - For u/NegativelyMagnetic on Reddit'/>
        <ComboBox Name='Algo' HorizontalAlignment="Left" Height="23" Margin="69,10,0,0" VerticalAlignment="Top" Width="325"/>
        <Button Name='EncryptDecrypt' Content="Go" HorizontalAlignment="Left" Margin="361,378,0,0" VerticalAlignment="Top" Height="23" Width="75" RenderTransformOrigin="0.161,14.528"/>
        

        <TextBox Name='InputText' HorizontalAlignment="Left" Height="110" TextWrapping="Wrap" Margin="10,102,0,0" VerticalAlignment="Top" Width="440" />
        <TextBox Name='OutputStream' HorizontalAlignment="Left" Height="110" TextWrapping="Wrap" Margin="10,242,0,0" VerticalAlignment="Top" Width="440" />
       
        <Label x:Name="labelpath" Content="Algorithm" HorizontalAlignment="Left" Margin="3,9,0,0" VerticalAlignment="Top"/>
        <Label x:Name="password_label" Content="Password" HorizontalAlignment="Left" Margin="3,40,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name='Password' HorizontalAlignment="Left" Height="23" Margin="69,41,0,0" TextWrapping="Wrap" Text="secret" VerticalAlignment="Top" Width="325"/>
        <CheckBox x:Name="check_savetofile" IsChecked="True" Content="Save to file" HorizontalAlignment="Left" Margin="10,364,0,0" VerticalAlignment="Top"  Visibility="Collapsed"/>
        <CheckBox x:Name="check_option2" IsChecked="False" Content="Option 2" HorizontalAlignment="Left" Margin="178,364,0,0" VerticalAlignment="Top"  Visibility="Collapsed"/>
        <CheckBox x:Name="check_option3" Content="Option 3" HorizontalAlignment="Left" Margin="10,390,0,0" VerticalAlignment="Top" Width="310" Height="25" Visibility="Collapsed"/>
        
    </Grid>
</Window>

"@ 


Function Initialize-CiphersCombobox{
    [CmdletBinding(SupportsShouldProcess)]
    Param ()

    ForEach($c in Get-CiphersList){
        $cipher = $c.Cipher
        [void] $Algo.Items.Add($cipher)
    }
    $Algo.SelectedIndex = 0
}


    Write-Host "[RShow-ResetPermissionsDialog] ================================" -f DarkYellow
    Write-Host "[RShow-ResetPermissionsDialog]             TEST MODE           " -f Red
    Write-Host "[RShow-ResetPermissionsDialog] ================================" -f DarkYellow
    #Read the form 
    $Reader = (New-Object System.Xml.XmlNodeReader $xaml)  
    $Form = [Windows.Markup.XamlReader]::Load($reader)  
    $Script:SimulationOnly = $False
    #AutoFind all controls 
    $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object {  
        $VarName = $_.Name
        Write-Host "[RShow-ResetPermissionsDialog] New Gui Variable => $VarName. Scope: Script"
        New-Variable  -Name $_.Name -Value $Form.FindName($_.Name) -Force -Scope Script 
    }

    $ProcessFiles = $False
    $ProcessDirectories = $True


    $Script:InputText.IsReadOnly = $false
    $Script:InputText.AcceptsReturn = $True 
    $Script:InputText.VerticalScrollBarVisibility = "Visible"

    $Script:OutputStream.IsReadOnly = $true
    $Url.Add_MouseLeftButtonUp({ &"start" "https://www.reddit.com/r/PowerShell/comments/ykh3cq/how_to_replace_digits_by_alphabet_letters_1_a_2_b/"})
    $Url.Add_MouseEnter({$Url.Foreground = 'DarkGray'})
    $Url.Add_MouseLeave({$Url.Foreground = 'LightGray'})

    Initialize-CiphersCombobox
   


    $EncryptDecrypt.Add_Click({
        $list = Get-CiphersList
        $passwd = $Script:Password.Text
        $o = $list[$Algo.SelectedIndex]
        $Filename = $o.File
        $CipherFilePath = "$PSScriptRoot\ciphers\$Filename"
        [string]$plainText = $Script:InputText.Text
        $OutputStream.Text = ""
       
        Write-Host "`"$CipherFilePath`" $plainText $passwd"
        $processedMsg = . "$CipherFilePath" "$plainText" "$passwd"
        Write-Host "`"$processedMsg`" "
        Out-Message "$processedMsg" -n

    })

    [void]$Form.ShowDialog() 

}catch{
    Show-ExceptionDetails $_ -ShowStack
}