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



Function Out-Message{
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [parameter(Position=0, Mandatory=$false)]
        [String]$Message,
        [parameter(Mandatory=$false)]
        [Alias('n')]
        [switch]$NewLine,
        [parameter(Mandatory=$false)]
        [Alias('c')]
        [switch]$Clear
    )
    Write-Verbose "Out-Message $Message $Type"
  
    if([string]::IsNullOrEmpty($Message)){
        $OutputStream.Text += "`n"
        return
    }
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
        
        <TextBox Name='InputFileEdit' HorizontalAlignment="Left" Height="23" Margin="69,10,0,0" VerticalAlignment="Top" Width="325"/>
        <Button Name='StartCompile' Content="Build!" HorizontalAlignment="Left" Margin="361,378,0,0" VerticalAlignment="Top" Height="23" Width="75" RenderTransformOrigin="0.161,14.528"/>
        
<Label Name='Url' Content='by http://arsscriptum.github.io' HorizontalAlignment="Left" Margin="10,360,0,0" VerticalAlignment="Top" Foreground="Gray" Cursor='Hand' ToolTip='by http://arsscriptum.github.io - For u/NegativelyMagnetic on Reddit'/>
        
        
        <TextBox Name='OutputStream' HorizontalAlignment="Left" Height="110" TextWrapping="Wrap" Margin="10,242,0,0" VerticalAlignment="Top" Width="440" />
       
        <Label x:Name="infile_label" Content="Input" HorizontalAlignment="Left" Margin="3,10,0,0" VerticalAlignment="Top"/>
        <Label x:Name="outfile_label" Content="Output" HorizontalAlignment="Left" Margin="3,40,0,0" VerticalAlignment="Top"/>
        <Label x:Name="iconfile_label" Content="Icon" HorizontalAlignment="Left" Margin="3,70,0,0" VerticalAlignment="Top"/>
        
        <TextBox x:Name='OutputFileEdit' HorizontalAlignment="Left" Height="23" Margin="69,40,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="325"/>
        <TextBox x:Name='IconFileEdit' HorizontalAlignment="Left" Height="23" Margin="69,70,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="325"/>
        <CheckBox x:Name="check_option_admin" IsChecked="False" Content="Requires Administrator Privileges" HorizontalAlignment="Left" Height="23" Margin="69,110,0,0"  VerticalAlignment="Top"/>
        <CheckBox x:Name="check_option_gui" IsChecked="False" Content="GUI Application" HorizontalAlignment="Left" Height="23" Margin="69,135,0,0"  VerticalAlignment="Top"/>
        <CheckBox x:Name="check_option_obfuscation" IsChecked="False" Content="Code Obfuscation" HorizontalAlignment="Left" Height="23" Margin="69,160,0,0"  VerticalAlignment="Top"/>

        
    </Grid>
</Window>

"@ 


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



    $Script:OutputStream.IsReadOnly = $true
    $Url.Add_MouseLeftButtonUp({ &"start" "http://arsscriptum.github.io"})
    $Url.Add_MouseEnter({$Url.Foreground = 'DarkGray'})
    $Url.Add_MouseLeave({$Url.Foreground = 'LightGray'})


    $StartCompile.Add_Click({
        
        $PoshBuildExe = Get-PoshBuildExe
        [string]$InFile = $InputFileEdit.Text
        [string]$OutFile = $OutputFileEdit.Text
        [string]$IconFile = $IconFileEdit.Text

        if(-not(Test-GuiValues)){
            return
        }

        $OutputStream.Text = ""
       
        $BuildScript = "F:\DEV3\Native.PowerShell.Wrapper\scripts\PoshBuild.ps1"
        # &"$PoshBuildExe" "$InFile" "$IconFile"
        Out-Message "COMPILING $InFile" -n
        [string[]]$OutData = . "$BuildScript" "$InFile"
        Out-Message "Done"

        ForEach($d in $OutData){
            Out-Message "$d"
        } 

    })

    [void]$Form.ShowDialog() 

}catch{
    Show-ExceptionDetails $_ -ShowStack
}


function Test-GuiValues{
    [CmdletBinding(SupportsShouldProcess)]
    Param()

    [string]$InFile = $InputFileEdit.Text
    [string]$OutFile = $OutputFileEdit.Text
    [string]$IconFile = $IconFileEdit.Text
    if( [string]::IsNullOrEmpty($InFile) ){
        [System.Windows.Forms.MessageBox]::Show("Invalid Input File","Invalid Entry",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
        return $False;
    }
    if( [string]::IsNullOrEmpty($OutFile) ){
        [System.Windows.Forms.MessageBox]::Show("Invalid Output File","Invalid Entry",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
        return $False;
    }
    if( [string]::IsNullOrEmpty($IconFile) ){
        [System.Windows.Forms.MessageBox]::Show("Invalid Icon File","Invalid Entry",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
        return $False;
    }
    return $True
}


function Get-PoshBuildExe{
    [CmdletBinding(SupportsShouldProcess)]
    Param()


    if(Test-Path "$ENV:PoshBuildExe"){
        return "$ENV:PoshBuildExe"
    }

    return "F:\DEV3\Native.PowerShell.Wrapper\tools\PoshBuild.exe"
}
