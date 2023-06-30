<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [parameter(Position=0, Mandatory=$true)]
        [String]$Hostname,
        [parameter(Position=1, Mandatory=$true)]
        [String]$JsonData
    )

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null



function Get-ImgPath{ 
    [CmdletBinding(SupportsShouldProcess)]
    Param ()  
    $ScriptPath = $PSScriptRoot
    $imgpath = Join-Path $ScriptPath 'img'
    return $imgpath
}

function Get-TestScanData{ 
    [CmdletBinding(SupportsShouldProcess)]
    Param ()  

    $ScanData = Get-Content "$PSScriptRoot\ScanData.json" | ConvertFrom-Json
    $ScanData
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
            Title="Port Scan Report" Height="410" Width="460" ResizeMode="NoResize" Topmost="True" WindowStartupLocation="CenterScreen" >

    <Grid>
        <Image HorizontalAlignment="Left" Height="500" VerticalAlignment="Top" Width="450" Stretch="UniformToFill" Source="$PSScriptRoot\img\BackGround.jpg" Margin="0,0,0,0"/>
        
        <Label x:Name="ScanTitle" Content="Host: " FontSize="14" FontFamily="Georgia" FontWeight="Bold" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" />
        <DataGrid x:Name="PortsData" Margin="10,50,10,0" VerticalAlignment="Top" Height="325" SelectionMode="Single" AlternationCount="1"
                  AutoGenerateColumns="false">

            <DataGrid.RowStyle>
              <Style TargetType="DataGridRow"> 
               <Setter Property="IsHitTestVisible" Value="False"></Setter>      
               <Style.Triggers>
                <DataTrigger Binding="{Binding State}" Value="closed">
                 <Setter Property="Background" Value="#009900"></Setter>
                </DataTrigger>   
                <DataTrigger Binding="{Binding State}" Value="open">
                 <Setter Property="Background" Value="#ff0000"></Setter>
                 <Setter Property="Foreground" Value="#ffff00"></Setter>
                </DataTrigger>   
               </Style.Triggers>
              </Style>
             </DataGrid.RowStyle>         


            <DataGrid.Columns>
                <DataGridTextColumn Binding="{Binding Path=Port}" ClipboardContentBinding="{x:Null}" CanUserSort="False" CanUserResize="False" IsReadOnly="True" Header="Port" Width="60"/>
                <DataGridTextColumn Binding="{Binding Path=Protocol}" ClipboardContentBinding="{x:Null}" CanUserSort="False" CanUserResize="False" IsReadOnly="True" Header="Protocol" Width="80"/>
                <DataGridTextColumn Binding="{Binding Path=State}" ClipboardContentBinding="{x:Null}" CanUserSort="False" CanUserResize="False" IsReadOnly="True" Header="State" Width="125"/>
                <DataGridTextColumn Binding="{Binding Path=Service}" ClipboardContentBinding="{x:Null}" CanUserSort="False" CanUserResize="False" IsReadOnly="True" Header="Service" Width="150"/>
            </DataGrid.Columns>



        </DataGrid>
    </Grid>
</Window>

"@ 




    Write-Host "[ReporDialog] ================================" -f DarkYellow
    Write-Host "[ReporDialog]             TEST MODE           " -f Red
    Write-Host "[ReporDialog] ================================" -f DarkYellow
    #Read the form 
    $Reader = (New-Object System.Xml.XmlNodeReader $xaml)  
    $Form = [Windows.Markup.XamlReader]::Load($reader)  
    $Script:SimulationOnly = $False
    #AutoFind all controls 
    $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object {  
        $VarName = $_.Name
        Write-Host "[ReporDialog] New Gui Variable => $VarName. Scope: Script"
        New-Variable  -Name $_.Name -Value $Form.FindName($_.Name) -Force -Scope Script 
    }

    #$PortInfos = Get-TestScanData

    $PortInfos = $JsonData | ConvertFrom-Json
    $ReportTitleString = 'Host {0}' -f $Hostname
    $ScanTitle.Content = $ReportTitleString
    # Add Services to a datatable
    $Datatable = New-Object System.Data.DataTable
    [void]$Datatable.Columns.AddRange($Fields)
    foreach ($info in $PortInfos){
        $Array = @()
        Foreach ($Field in $Fields){
            $array += $info.$Field
        }
        [void]$Datatable.Rows.Add($array)
    }

    $PortsData.ItemsSource = $PortInfos

    # Allow sorting on all columns
    $PortsData.Columns | ForEach-Object { 
        $_.CanUserSort = $False
        $_.IsReadOnly = $True
    }

    [void]$Form.ShowDialog() 

}catch{
    Show-ExceptionDetails $_ -ShowStack
}