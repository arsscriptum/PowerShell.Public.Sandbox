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


function Get-ScriptPath{ 
    [CmdletBinding(SupportsShouldProcess)]
    Param ()  
    $ScriptPath = $PSScriptRoot
    $imgpath = Join-Path $ScriptPath 'scripts'
    return $imgpath
}


$ScriptPath = Get-ScriptPath
$ImagePath = "{0}\Images.ps1" -f $ScriptPath

. "$ImagePath"

 function ConvertTo-BitmapImage {
    [CmdletBinding(SupportsShouldProcess)]
      param(
          [Parameter(Position = 0, Mandatory = $true)]
          [string]$Base64String,
          [Parameter(Position = 1, Mandatory = $True)]
          [ValidateSet("Bmp", "Emf", "Exif", "Gif", "Icon", "Jpeg", "MemoryBmp", "Png", "Tiff", "Wmf")]
          [string]$ImageType
      )

    [System.Drawing.Imaging.ImageFormat]$Format = [System.Drawing.Imaging.ImageFormat]::$ImageType

    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing
    [System.Drawing.Bitmap]$bmp = [System.Drawing.Bitmap]::FromStream((New-Object System.IO.MemoryStream (@(, [Convert]::FromBase64String($Base64String)))))
    $memory = New-Object System.IO.MemoryStream
    $null = $bmp.Save($memory, $Format)
    $memory.Position = 0
    $img = New-Object System.Windows.Media.Imaging.BitmapImage
    $img.BeginInit()
    $img.StreamSource = $memory
    $img.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
    $img.EndInit()
    $img.Freeze()

    $memory.Close()

    $img
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

    #Load required libraries 

    [xml]$xaml = @"

<Window
            xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
            xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
            xmlns:local="clr-namespace:WpfApp10"
            Title="Embedded Image DEMO Tool" Height="463.632" Width="476.995" ResizeMode="NoResize" Topmost="True" WindowStartupLocation="CenterScreen">

    <Grid>
        <Image Name='ImageVariable' HorizontalAlignment="Left" Height="419" VerticalAlignment="Top" Width="469" Margin="0,0,0,-58"/>
        <Label Name='Url' Content='by http://arsscriptum.github.io' HorizontalAlignment="Left" Margin="10,70,0,0" VerticalAlignment="Top" Foreground="Gray" Cursor='Hand' ToolTip='https://arsscriptum.github.io/blog/embedding-resources-in-script/'/>
        <Button Name='DoneDialog' Content="Done" HorizontalAlignment="Left" Margin="361,378,0,0" VerticalAlignment="Top" Height="23" Width="75" RenderTransformOrigin="0.161,14.528"/>
        <Button Name='ChangeImage' Content="Change Img" HorizontalAlignment="Left" Margin="260,378,0,0" VerticalAlignment="Top" Height="23" Width="75" RenderTransformOrigin="0.161,14.528"/>
        
       
        <Label x:Name="img_label" Content="Image" HorizontalAlignment="Left" Margin="3,40,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name='ImageLoaded' HorizontalAlignment="Left" Height="23" Margin="69,41,0,0" TextWrapping="Wrap" IsEnabled="False" Text="secret" VerticalAlignment="Top" Width="325"/>

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


    $Url.Add_MouseLeftButtonUp({ &"start" "https://arsscriptum.github.io/blog/embedding-resources-in-script/"})
    $Url.Add_MouseEnter({$Url.Foreground = 'DarkGray'})
    $Url.Add_MouseLeave({$Url.Foreground = 'LightGray'})

    $Script:ImagesArray = @( '$Image_000','$Image_001','$Image_002','$Image_003' )
    $Script:CurrentIndex = 0
    $ChangeImage.Add_Click({
        Write-Host "Change Image to index $Script:CurrentIndex. $Script:ImagesArray[$Script:CurrentIndex]"
        $ImageLoaded.Text = ($ImagesArray[$Script:CurrentIndex])
        [System.Windows.Media.Imaging.BitmapImage]$BitmapObj =  ConvertTo-BitmapImage -Base64String (iex $Script:ImagesArray[$Script:CurrentIndex]) -ImageType Jpeg
        $ImageVariable.Source = $BitmapObj
        $Script:CurrentIndex++
        if($Script:CurrentIndex -ge $Script:ImagesArray.Count){ $Script:CurrentIndex = 0}
    })

    $DoneDialog.Add_Click({
        [void]$Form.Close()
     

    })

    [void]$Form.ShowDialog() 

}catch{
    Show-ExceptionDetails $_ -ShowStack
}