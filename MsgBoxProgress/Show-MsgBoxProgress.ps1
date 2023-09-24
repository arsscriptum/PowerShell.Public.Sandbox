<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding(SupportsShouldProcess)]
Param()

function Show-MsgBoxProgress{
    [CmdletBinding(SupportsShouldProcess)]
    Param()


    [void][System.Reflection.Assembly]::LoadWithPartialName('PresentationFramework')
    [void][System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')
    [void][System.Reflection.Assembly]::LoadWithPartialName('WindowsBase')
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')
    [void][System.Reflection.Assembly]::LoadWithPartialName('System')
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Xml')
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows')

    [xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Please Wait" Height="176" Width="488.932"
    WindowStartupLocation="CenterOwner"
    x:Name="Window" ResizeMode="NoResize" FontFamily="Verdana" FontSize="14"
    xmlns:wf="clr-namespace:System.Windows.Forms;assembly=System.Windows.Forms">
    <Window.Background>
        <LinearGradientBrush EndPoint="0.5,1" MappingMode="RelativeToBoundingBox" StartPoint="0.5,0">
            <GradientStop Color="{DynamicResource {x:Static SystemColors.HotTrackColorKey}}" Offset="0.869"/>
            <GradientStop Color="White" Offset="0.109"/>
        </LinearGradientBrush>
    </Window.Background>
    <Grid Margin="40,20,40,16">
        <ProgressBar Height="20" Margin="34,36,46,0" VerticalAlignment="Top" Minimum="0" Maximum="100" Name="pbStatus"/>
        <Button x:Name="buttonCancel" Content="Cancel" HorizontalAlignment="Left" Margin="163,73,0,0" VerticalAlignment="Top" Width="75" RenderTransformOrigin="0.52,-0.857" Height="23"/>
        <Label x:Name="labelProgress" Content="Operation in progress..." HorizontalAlignment="Left" Margin="34,0,0,0" VerticalAlignment="Top" Width="321" Height="31"/>
    </Grid>
</Window>
"@



    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    $Window=[Windows.Markup.XamlReader]::Load( $reader )
    

    #AutoFind all controls 
    $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object {  
        New-Variable  -Name $_.Name -Value $Window.FindName($_.Name) -Force -Scope Script
        Write-Verbose "Variable named: Name $($_.Name)"
    }

   
    $pbStatus = Get-Variable -Name "pbStatus" -ValueOnly -Scope Script
    $labelProgress = Get-Variable -Name "labelProgress" -ValueOnly -Scope Script
    $buttonCancel = Get-Variable -Name "buttonCancel" -ValueOnly -Scope Script


    $pbStatus.Value = 0

    $buttonCancel.Add_Click({
        $Window.Close()
    })
    ## -- Show the Progress-Bar and Start The PowerShell Script
    $Window.Show() | Out-Null
    $Window.Focus() | Out-NUll


    [uint32[]]$AllItems = 1..100
    $Counter = 0
    ForEach ($Item In $AllItems) {
        ## -- Calculate The Percentage Completed
        $Counter++
        [Int]$Percentage = ($Counter/$AllItems.Count)*100
        $pbStatus.Value = $Percentage
        Start-Sleep -Milliseconds 50
    }

    $Window.Close()
}


Show-MsgBoxProgress



