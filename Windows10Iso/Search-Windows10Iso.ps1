#
# Search-Windows10Iso - Feature ISO Downloader, for retail Windows images and UEFI Shell
#

function Search-Windows10Iso{
    [CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory=$false, HelpMessage="The title to display on the application window")]
		[string]$AppTitle = "Fido - Feature ISO Downloader",
		[Parameter(Mandatory=$false, HelpMessage=" '|' separated UI localization strings")]
		[string]$LocData,
		[Parameter(Mandatory=$false, HelpMessage="Forced locale")]
		[string]$Locale = "en-US",
		[Parameter(Mandatory=$false, HelpMessage="Path to a file that should be used for the UI icon")]
		[string]$Icon,
		[Parameter(Mandatory=$false, HelpMessage="Name of a pipe the download URL should be sent to,If not provided, a browser window is opened instead")]
		[string]$PipeName,
		[Parameter(Mandatory=$false, HelpMessage="Specify Windows version (e.g. 'Windows 10')")]
		[string]$Win,
		[Parameter(Mandatory=$false, HelpMessage="Specify Windows release")]
		[string]$Rel,
		[Parameter(Mandatory=$false, HelpMessage="Specify Windows edition (e.g. 'Pro')")]
		[string]$Ed,
		[Parameter(Mandatory=$false, HelpMessage=" Specify Windows language")]
		[string]$Lang,
		[Parameter(Mandatory=$false, HelpMessage="Specify Windows architecture")]
		[string]$Arch,
		[Parameter(Mandatory=$false, HelpMessage="Only display the download URL")]
		[switch]$ShowUrl
	)
    try{

		try {
			[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
		} catch {}

		$Cmd = $false
		if ($Win -or $Rel -or $Ed -or $Lang -or $Arch -or $ShowUrl) {
			$Cmd = $true
		}

		# Return a decimal Windows version that we can then check for platform support.
		# Note that because we don't want to have to support this script on anything
		# other than Windows, this call returns 0.0 for PowerShell running on Linux/Mac.
		function Get-Platform-Version()
		{
			$version = 0.0
			$platform = [string][System.Environment]::OSVersion.Platform
			# This will filter out non Windows platforms
			if ($platform.StartsWith("Win")) {
				# Craft a decimal numeric version of Windows
				$version = [System.Environment]::OSVersion.Version.Major * 1.0 + [System.Environment]::OSVersion.Version.Minor * 0.1
			}
			return $version
		}

		$winver = Get-Platform-Version

		# The default TLS for Windows 8.x doesn't work with Microsoft's servers so we must force it
		if ($winver -lt 10.0) {
			[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
		}

		#region Assembly Types
		$Drawing_Assembly = "System.Drawing"
		# PowerShell 7 altered the name of the Drawing assembly...
		if ($host.version -ge "7.0") {
			$Drawing_Assembly += ".Common"
		}

		$Signature = @{
			Namespace            = "WinAPI"
			Name                 = "Utils"
			Language             = "CSharp"
			UsingNamespace       = "System.Runtime", "System.IO", "System.Text", "System.Drawing", "System.Globalization"
			ReferencedAssemblies = $Drawing_Assembly
			ErrorAction          = "Stop"
			WarningAction        = "Ignore"
			IgnoreWarnings       = $true
			MemberDefinition     = @"
				[DllImport("shell32.dll", CharSet = CharSet.Auto, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true)]
				internal static extern int ExtractIconEx(string sFile, int iIndex, out IntPtr piLargeVersion, out IntPtr piSmallVersion, int amountIcons);

				[DllImport("user32.dll")]
				public static extern bool ShowWindow(IntPtr handle, int state);
				// Extract an icon from a DLL
				public static Icon ExtractIcon(string file, int number, bool largeIcon) {
					IntPtr large, small;
					ExtractIconEx(file, number, out large, out small, 1);
					try {
						return Icon.FromHandle(largeIcon ? large : small);
					} catch {
						return null;
					}
				}
"@
		}

		if (!$Cmd) {
			Write-Host Please Wait...

			if (!("WinAPI.Utils" -as [type]))
			{
				Add-Type @Signature
			}
			Add-Type -AssemblyName PresentationFramework

			# Hide the powershell window: https://stackoverflow.com/a/27992426/1069307
			[WinAPI.Utils]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0) | Out-Null
		}
		#endregion

		#region Data
		$zh = 0x10000
		$ko = 0x20000
		$WindowsVersions = @(
			@(
				@("Windows 11", "windows11"),
				@(
					"23H2 v2 (Build 22631.2861 - 2023.12)",
					@("Windows 11 Home/Pro/Edu", 2935),
					@("Windows 11 Home China ", ($zh + 2936))
				)
			),
			@(
				@("Windows 10", "Windows10ISO"),
				@(
					"22H2 v1 (Build 19045.2965 - 2023.05)",
					@("Windows 10 Home/Pro/Edu", 2618),
					@("Windows 10 Home China ", ($zh + 2378))
				)
			)
			@(
				@("Windows 8.1", "windows8ISO"),
				@(
					"Update 3 (build 9600)",
					@("Windows 8.1 Standard", 52),
					@("Windows 8.1 N", 55)
					@("Windows 8.1 Single Language", 48),
					@("Windows 8.1 K", ($ko + 61)),
					@("Windows 8.1 KN", ($ko + 62))
				)
			),
			@(
				@("UEFI Shell 2.2", "UEFI_SHELL 2.2"),
				@(
					"24H1 (edk2-stable202405)",
					@("Release", 0),
					@("Debug", 1)
				),
				@(
					"23H2 (edk2-stable202311)",
					@("Release", 0),
					@("Debug", 1)
				),
				@(
					"23H1 (edk2-stable202305)",
					@("Release", 0),
					@("Debug", 1)
				),
				@(
					"22H2 (edk2-stable202211)",
					@("Release", 0),
					@("Debug", 1)
				),
				@(
					"22H1 (edk2-stable202205)",
					@("Release", 0),
					@("Debug", 1)
				),
				@(
					"21H2 (edk2-stable202108)",
					@("Release", 0),
					@("Debug", 1)
				),
				@(
					"21H1 (edk2-stable202105)",
					@("Release", 0),
					@("Debug", 1)
				),
				@(
					"20H2 (edk2-stable202011)",
					@("Release", 0),
					@("Debug", 1)
				)
			),
			@(
				@("UEFI Shell 2.0", "UEFI_SHELL 2.0"),
				@(
					"4.632 [20100426]",
					@("Release", 0)
				)
			)
		)
		#endregion

		#region Functions
		function Select-Language([string]$LangName)
		{
			# Use the system locale to try select the most appropriate language
			[string]$SysLocale = [System.Globalization.CultureInfo]::CurrentUICulture.Name
			if (($SysLocale.StartsWith("ar") -and $LangName -like "*Arabic*") -or `
				($SysLocale -eq "pt-BR" -and $LangName -like "*Brazil*") -or `
				($SysLocale.StartsWith("ar") -and $LangName -like "*Bulgar*") -or `
				($SysLocale -eq "zh-CN" -and $LangName -like "*Chinese*" -and $LangName -like "*simp*") -or `
				($SysLocale -eq "zh-TW" -and $LangName -like "*Chinese*" -and $LangName -like "*trad*") -or `
				($SysLocale.StartsWith("hr") -and $LangName -like "*Croat*") -or `
				($SysLocale.StartsWith("cz") -and $LangName -like "*Czech*") -or `
				($SysLocale.StartsWith("da") -and $LangName -like "*Danish*") -or `
				($SysLocale.StartsWith("nl") -and $LangName -like "*Dutch*") -or `
				($SysLocale -eq "en-US" -and $LangName -eq "English") -or `
				($SysLocale.StartsWith("en") -and $LangName -like "*English*" -and ($LangName -like "*inter*" -or $LangName -like "*ingdom*")) -or `
				($SysLocale.StartsWith("et") -and $LangName -like "*Eston*") -or `
				($SysLocale.StartsWith("fi") -and $LangName -like "*Finn*") -or `
				($SysLocale -eq "fr-CA" -and $LangName -like "*French*" -and $LangName -like "*Canad*") -or `
				($SysLocale.StartsWith("fr") -and $LangName -eq "French") -or `
				($SysLocale.StartsWith("de") -and $LangName -like "*German*") -or `
				($SysLocale.StartsWith("el") -and $LangName -like "*Greek*") -or `
				($SysLocale.StartsWith("he") -and $LangName -like "*Hebrew*") -or `
				($SysLocale.StartsWith("hu") -and $LangName -like "*Hungar*") -or `
				($SysLocale.StartsWith("id") -and $LangName -like "*Indones*") -or `
				($SysLocale.StartsWith("it") -and $LangName -like "*Italia*") -or `
				($SysLocale.StartsWith("ja") -and $LangName -like "*Japan*") -or `
				($SysLocale.StartsWith("ko") -and $LangName -like "*Korea*") -or `
				($SysLocale.StartsWith("lv") -and $LangName -like "*Latvia*") -or `
				($SysLocale.StartsWith("lt") -and $LangName -like "*Lithuania*") -or `
				($SysLocale.StartsWith("ms") -and $LangName -like "*Malay*") -or `
				($SysLocale.StartsWith("nb") -and $LangName -like "*Norw*") -or `
				($SysLocale.StartsWith("fa") -and $LangName -like "*Persia*") -or `
				($SysLocale.StartsWith("pl") -and $LangName -like "*Polish*") -or `
				($SysLocale -eq "pt-PT" -and $LangName -eq "Portuguese") -or `
				($SysLocale.StartsWith("ro") -and $LangName -like "*Romania*") -or `
				($SysLocale.StartsWith("ru") -and $LangName -like "*Russia*") -or `
				($SysLocale.StartsWith("sr") -and $LangName -like "*Serbia*") -or `
				($SysLocale.StartsWith("sk") -and $LangName -like "*Slovak*") -or `
				($SysLocale.StartsWith("sl") -and $LangName -like "*Slovenia*") -or `
				($SysLocale -eq "es-ES" -and $LangName -eq "Spanish") -or `
				($SysLocale.StartsWith("es") -and $Locale -ne "es-ES" -and $LangName -like "*Spanish*") -or `
				($SysLocale.StartsWith("sv") -and $LangName -like "*Swed*") -or `
				($SysLocale.StartsWith("th") -and $LangName -like "*Thai*") -or `
				($SysLocale.StartsWith("tr") -and $LangName -like "*Turk*") -or `
				($SysLocale.StartsWith("uk") -and $LangName -like "*Ukrain*") -or `
				($SysLocale.StartsWith("vi") -and $LangName -like "*Vietnam*")) {
				return $true
			}
			return $false
		}

		function Add-Entry([int]$pos, [string]$Name, [array]$Items, [string]$DisplayName)
		{
			$Title = New-Object System.Windows.Controls.TextBlock
			$Title.FontSize = $WindowsVersionTitle.FontSize
			$Title.Height = $WindowsVersionTitle.Height;
			$Title.Width = $WindowsVersionTitle.Width;
			$Title.HorizontalAlignment = "Left"
			$Title.VerticalAlignment = "Top"
			$Margin = $WindowsVersionTitle.Margin
			$Margin.Top += $pos * $dh
			$Title.Margin = $Margin
			$Title.Text = Get-Translation($Name)
			$XMLGrid.Children.Insert(2 * $Stage + 2, $Title)

			$Combo = New-Object System.Windows.Controls.ComboBox
			$Combo.FontSize = $WindowsVersion.FontSize
			$Combo.Height = $WindowsVersion.Height;
			$Combo.Width = $WindowsVersion.Width;
			$Combo.HorizontalAlignment = "Left"
			$Combo.VerticalAlignment = "Top"
			$Margin = $WindowsVersion.Margin
			$Margin.Top += $pos * $script:dh
			$Combo.Margin = $Margin
			$Combo.SelectedIndex = 0
			if ($Items) {
				$Combo.ItemsSource = $Items
				if ($DisplayName) {
					$Combo.DisplayMemberPath = $DisplayName
				} else {
					$Combo.DisplayMemberPath = $Name
				}
			}
			$XMLGrid.Children.Insert(2 * $Stage + 3, $Combo)

			$XMLForm.Height += $dh;
			$Margin = $Continue.Margin
			$Margin.Top += $dh
			$Continue.Margin = $Margin
			$Margin = $Back.Margin
			$Margin.Top += $dh
			$Back.Margin = $Margin

			return $Combo
		}

		function Refresh-Control([object]$Control)
		{
			$Control.Dispatcher.Invoke("Render", [Windows.Input.InputEventHandler] { $Continue.UpdateLayout() }, $null, $null) | Out-Null
		}

		function Send-Message([string]$PipeName, [string]$Message)
		{
			[System.Text.Encoding]$Encoding = [System.Text.Encoding]::UTF8
			$Pipe = New-Object -TypeName System.IO.Pipes.NamedPipeClientStream -ArgumentList ".", $PipeName, ([System.IO.Pipes.PipeDirection]::Out), ([System.IO.Pipes.PipeOptions]::None), ([System.Security.Principal.TokenImpersonationLevel]::Impersonation)
			try {
				$Pipe.Connect(1000)
			} catch {
				Write-Host $_.Exception.Message
			}
			$bRequest = $Encoding.GetBytes($Message)
			$cbRequest = $bRequest.Length;
			$Pipe.Write($bRequest, 0, $cbRequest);
			$Pipe.Dispose()
		}

		# From https://www.powershellgallery.com/packages/IconForGUI/1.5.2
		# Copyright © 2016 Chris Carter. All rights reserved.
		# License: https://creativecommons.org/licenses/by-sa/4.0/
		function ConvertTo-ImageSource
		{
			[CmdletBinding()]
			Param(
				[Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
				[System.Drawing.Icon]$Icon
			)

			Process {
				foreach ($i in $Icon) {
					[System.Windows.Interop.Imaging]::CreateBitmapSourceFromHIcon(
						$i.Handle,
						(New-Object System.Windows.Int32Rect -Args 0,0,$i.Width, $i.Height),
						[System.Windows.Media.Imaging.BitmapSizeOptions]::FromEmptyOptions()
					)
				}
			}
		}

		function Throw-Error([object]$Req, [string]$Alt)
		{
			$Err = $(GetElementById -Request $Req -Id "errorModalMessage").innerText -replace "<[^>]+>" -replace "\s+", " "
			if (!$Err) {
				$Err = $Alt
			} else {
				$Err = [System.Text.Encoding]::UTF8.GetString([byte[]][char[]]$Err)
			}
			throw $Err
		}

		# Translate a message string
		function Get-Translation([string]$Text)
		{
			if (!($English -contains $Text)) {
				Write-Host "Error: '$Text' is not a translatable string"
				return "(Untranslated)"
			}
			if ($Localized) {
				if ($Localized.Length -ne $English.Length) {
					Write-Host "Error: '$Text' is not a translatable string"
				}
				for ($i = 0; $i -lt $English.Length; $i++) {
					if ($English[$i] -eq $Text) {
						if ($Localized[$i]) {
							return $Localized[$i]
						} else {
							return $Text
						}
					}
				}
			}
			return $Text
		}

		# Some PowerShells don't have Microsoft.mshtml assembly (comes with MS Office?)
		# so we can't use ParsedHtml or IHTMLDocument[2|3] features there...
		function GetElementById([object]$Request, [string]$Id)
		{
			try {
				return $Request.ParsedHtml.IHTMLDocument3_GetElementByID($Id)
			} catch {
				return $Request.AllElements | ? {$_.id -eq $Id}
			}
		}

		function Error([string]$ErrorMessage)
		{
			Write-Host Error: $ErrorMessage
			if (!$Cmd) {
				$XMLForm.Title = $(Get-Translation("Error")) + ": " + $ErrorMessage
				Refresh-Control($XMLForm)
				$XMLGrid.Children[2 * $script:Stage + 1].IsEnabled = $true
				$UserInput = [System.Windows.MessageBox]::Show($XMLForm.Title,  $(Get-Translation("Error")), "OK", "Error")
				$script:ExitCode = $script:Stage--
			} else {
				$script:ExitCode = 2
			}
		}

		function Get-RandomDate()
		{
			[DateTime]$Min = "1/1/2008"
			[DateTime]$Max = [DateTime]::Now

			$RandomGen = new-object random
			$RandomTicks = [Convert]::ToInt64( ($Max.ticks * 1.0 - $Min.Ticks * 1.0 ) * $RandomGen.NextDouble() + $Min.Ticks * 1.0 )
			$Date = new-object DateTime($RandomTicks)
			return $Date.ToString("yyyyMMdd")
		}
		#endregion

		#region Form
		[xml]$XAML = @"
		<Window xmlns = "http://schemas.microsoft.com/winfx/2006/xaml/presentation" Height = "162" Width = "384" ResizeMode = "NoResize">
			<Grid Name = "XMLGrid">
				<Button Name = "Continue" FontSize = "16" Height = "26" Width = "160" HorizontalAlignment = "Left" VerticalAlignment = "Top" Margin = "14,78,0,0"/>
				<Button Name = "Back" FontSize = "16" Height = "26" Width = "160" HorizontalAlignment = "Left" VerticalAlignment = "Top" Margin = "194,78,0,0"/>
				<TextBlock Name = "WindowsVersionTitle" FontSize = "16" Width="340" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="16,8,0,0"/>
				<ComboBox Name = "WindowsVersion" FontSize = "14" Height = "24" Width = "340" HorizontalAlignment = "Left" VerticalAlignment="Top" Margin = "14,34,0,0" SelectedIndex = "0"/>
				<CheckBox Name = "Check" FontSize = "14" Width = "340" HorizontalAlignment = "Left" VerticalAlignment="Top" Margin = "14,0,0,0" Visibility="Collapsed" />
			</Grid>
		</Window>
"@
		#endregion

		#region Globals
		$ErrorActionPreference = "Stop"
		$DefaultTimeout = 30
		$dh = 58
		$Stage = 0
		$SelectedIndex = 0
		$ltrm = "‎"
		if ($Cmd) {
			$ltrm = ""
		}
		$MaxStage = 4
		$SessionId = [guid]::NewGuid()
		$ExitCode = 100
		$Locale = $Locale
		$RequestData = @{}
		# This GUID applies to all visitors, regardless of their locale
		$RequestData["GetLangs"] = @("a8f8f489-4c7f-463a-9ca6-5cff94d8d041", "getskuinformationbyproductedition" )
		# This GUID applies to visitors of the en-US download page. Other locales may get a different GUID.
		$RequestData["GetLinks"] = @("6e2a1789-ef16-4f27-a296-74ef7ef5d96b", "GetProductDownloadLinksBySku" )
		# Create a semi-random Linux User-Agent string
		$FirefoxVersion = Get-Random -Minimum 90 -Maximum 110
		$FirefoxDate = Get-RandomDate
		$UserAgent = "Mozilla/5.0 (X11; Linux i586; rv:$FirefoxVersion.0) Gecko/$FirefoxDate Firefox/$FirefoxVersion.0"
		$Verbosity = 2
		if ($Cmd) {
			if ($ShowUrl) {
				$Verbosity = 0
			} elseif (!$Verbose) {
				$Verbosity = 1
			}
		}
		#endregion

		# Localization
		$EnglishMessages = "en-US|Version|Release|Edition|Language|Architecture|Download|Continue|Back|Close|Cancel|Error|Please wait...|" +
			"Download using a browser|Download of Windows ISOs is unavailable due to Microsoft having altered their website to prevent it.|" +
			"PowerShell 3.0 or later is required to run this script.|Do you want to go online and download it?|" +
			"This feature is not available on this platform."
		[string[]]$English = $EnglishMessages.Split('|')
		[string[]]$Localized = $null
		if ($LocData -and !$LocData.StartsWith("en-US")) {
			$Localized = $LocData.Split('|')
			# Adjust the $Localized array if we have more or fewer strings than in $EnglishMessages
			if ($Localized.Length -lt $English.Length) {
				while ($Localized.Length -ne $English.Length) {
					$Localized += $English[$Localized.Length]
				}
			} elseif ($Localized.Length -gt $English.Length) {
				$Localized = $LocData.Split('|')[0..($English.Length - 1)]
			}
			$Locale = $Localized[0]
		}
		$QueryLocale = $Locale

		# Convert a size in bytes to a human readable string
		function Size-To-Human-Readable([uint64]$size)
		{
			$suffix = "bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"
			$i = 0
			while ($size -gt 1kb) {
				$size = $size / 1kb
				$i++
			}
			"{0:N1} {1}" -f $size, $suffix[$i]
		}

		# Check if the locale we want is available - Fall back to en-US otherwise
		function Check-Locale
		{
			try {
				$url = "https://www.microsoft.com/" + $QueryLocale + "/software-download/"
				if ($Verbosity -ge 2) {
					Write-Host Querying $url
				}
				# Looks Microsoft are filtering our script according to the first query it performs with the spoofed user agent.
				# So, to continue this pointless cat and mouse game, we simply add an extra first query with the default user agent.
				# Also: "Hi Microsoft. You sure have A LOT OF RESOURCES TO WASTE to have assigned folks of yours to cripple scripts
				# that merely exist because you have chosen to make the user experience from your download website utterly subpar.
				# And while I am glad senpai noticed me (UwU), I feel compelled to ask: Don't you guys have better things to do?"
				Invoke-WebRequest -UseBasicParsing -TimeoutSec $DefaultTimeout -MaximumRedirection 0 $url | Out-Null
				Invoke-WebRequest -UseBasicParsing -TimeoutSec $DefaultTimeout -MaximumRedirection 0 -UserAgent $UserAgent $url | Out-Null
			} catch {
				# Of course PowerShell 7 had to BREAK $_.Exception.Status on timeouts...
				if ($_.Exception.Status -eq "Timeout" -or $_.Exception.GetType().Name -eq "TaskCanceledException") {
					Write-Host Operation Timed out
				}
				$script:QueryLocale = "en-US"
			}
		}

		# Return an array of releases (e.g. 20H2, 21H1, ...) for the selected Windows version
		function Get-Windows-Releases([int]$SelectedVersion)
		{
			$i = 0
			$releases = @()
			foreach ($version in $WindowsVersions[$SelectedVersion]) {
				if (($i -ne 0) -and ($version -is [array])) {
					$releases += @(New-Object PsObject -Property @{ Release = $ltrm + $version[0].Replace(")", ")" + $ltrm); Index = $i })
				}
				$i++
			}
			return $releases
		}

		# Return an array of editions (e.g. Home, Pro, etc) for the selected Windows release
		function Get-Windows-Editions([int]$SelectedVersion, [int]$SelectedRelease)
		{
			$editions = @()
			foreach ($release in $WindowsVersions[$SelectedVersion][$SelectedRelease])
			{
				if ($release -is [array]) {
					if (($release[1] -lt 0x10000) -or ($Locale.StartsWith("ko") -and ($release[1] -band $ko)) -or ($Locale.StartsWith("zh") -and ($release[1] -band $zh))) {
						$editions += @(New-Object PsObject -Property @{ Edition = $release[0]; Id = $($release[1] -band 0xFFFF) })
					}
				}
			}
			return $editions
		}

		# Return an array of languages for the selected edition
		function Get-Windows-Languages([int]$SelectedVersion, [int]$SelectedEdition)
		{
			$languages = @()
			$i = 0;
			if ($WindowsVersions[$SelectedVersion][0][1] -eq "WIN7") {
				foreach ($entry in $Windows7Versions[$SelectedEdition]) {
					if ($entry[0] -ne "") {
						$languages += @(New-Object PsObject -Property @{ DisplayLanguage = $entry[0]; Language = $entry[1]; Id = $i })
					}
					$i++
				}
			} elseif ($WindowsVersions[$SelectedVersion][0][1].StartsWith("UEFI_SHELL")) {
				$languages += @(New-Object PsObject -Property @{ DisplayLanguage = "English (US)"; Language = "en-us"; Id = 0 })
			} else {
				# Microsoft download protection now requires the sessionId to be whitelisted through vlscppe.microsoft.com/tags
				$url = "https://vlscppe.microsoft.com/tags?org_id=y6jn8c31&session_id=" + $SessionId
				if ($Verbosity -ge 2) {
					Write-Host Querying $url
				}
				try {
					Invoke-WebRequest -UseBasicParsing -TimeoutSec $DefaultTimeout -MaximumRedirection 0 -UserAgent $UserAgent $url | Out-Null
				} catch {
					Error($_.Exception.Message)
					return @()
				}
				$url = "https://www.microsoft.com/" + $QueryLocale + "/api/controls/contentinclude/html"
				$url += "?pageId=" + $RequestData["GetLangs"][0]
				$url += "&host=www.microsoft.com"
				$url += "&segments=software-download," + $WindowsVersions[$SelectedVersion][0][1]
				$url += "&query=&action=" + $RequestData["GetLangs"][1]
				$url += "&sessionId=" + $SessionId
				$url += "&productEditionId=" + [Math]::Abs($SelectedEdition)
				$url += "&sdVersion=2"
				if ($Verbosity -ge 2) {
					Write-Host Querying $url
				}

				$script:SelectedIndex = 0
				try {
					$r = Invoke-WebRequest -Method Post -UseBasicParsing -TimeoutSec $DefaultTimeout -UserAgent $UserAgent -SessionVariable "Session" $url
					if ($r -match "errorModalMessage") {
						Throw-Error -Req $r -Alt "Could not retrieve languages from server"
					}
					$r = $r -replace "`n" -replace "`r"
					$pattern = '.*<select id="product-languages"[^>]*>(.*)</select>.*'
					$html = [regex]::Match($r, $pattern).Groups[1].Value
					# Go through an XML conversion to keep all PowerShells happy...
					$html = $html.Replace("selected value", "value")
					$html = "<options>" + $html + "</options>"
					$xml = [xml]$html
					foreach ($var in $xml.options.option) {
						$json = $var.value | ConvertFrom-Json;
						if ($json) {
							$languages += @(New-Object PsObject -Property @{ DisplayLanguage = $var.InnerText; Language = $json.language; Id = $json.id })
							if (Select-Language($json.language)) {
								$script:SelectedIndex = $i
							}
							$i++
						}
					}
					if ($languages.Length -eq 0) {
						Throw-Error -Req $r -Alt "Could not parse languages"
					}
				} catch {
					Error($_.Exception.Message)
					return @()
				}
			}
			return $languages
		}

		# Return an array of download links for each supported arch
		function Get-Windows-Download-Links([int]$SelectedVersion, [int]$SelectedRelease, [int]$SelectedEdition, [string]$SkuId, [string]$LanguageName)
		{
			$links = @()
			if ($WindowsVersions[$SelectedVersion][0][1] -eq "WIN7") {
				foreach ($Version in $Windows7Versions[$SelectedEdition][$SkuId][2]) {
					$links += @(New-Object PsObject -Property @{ Type = $Version[0]; Link = $Version[1] })
				}
			} elseif ($WindowsVersions[$SelectedVersion][0][1].StartsWith("UEFI_SHELL")) {
				$tag = $WindowsVersions[$SelectedVersion][$SelectedRelease][0].Split(' ')[0]
				$shell_version = $WindowsVersions[$SelectedVersion][0][1].Split(' ')[1]
				$url = "https://github.com/pbatard/UEFI-Shell/releases/download/" + $tag
				$link = $url + "/UEFI-Shell-" + $shell_version + "-" + $tag
				if ($SelectedEdition -eq 0) {
					$link += "-RELEASE.iso"
				} else {
					$link += "-DEBUG.iso"
				}
				try {
					# Read the supported archs from the release URL
					$url += "/Version.xml"
					$xml = New-Object System.Xml.XmlDocument
					if ($Verbosity -ge 2) {
						Write-Host Querying $url
					}
					$xml.Load($url)
					$sep = ""
					$archs = ""
					foreach($arch in $xml.release.supported_archs.arch) {
						$archs += $sep + $arch
						$sep = ", "
					}
					$links += @(New-Object PsObject -Property @{ Type = $archs; Link = $link })
				} catch {
					Error($_.Exception.Message)
					return @()
				}
			} else {
				$url = "https://www.microsoft.com/" + $QueryLocale + "/api/controls/contentinclude/html"
				$url += "?pageId=" + $RequestData["GetLinks"][0]
				$url += "&host=www.microsoft.com"
				$url += "&segments=software-download," + $WindowsVersions[$SelectedVersion][0][1]
				$url += "&query=&action=" + $RequestData["GetLinks"][1]
				$url += "&sessionId=" + $SessionId
				$url += "&skuId=" + $SkuId
				$url += "&language=" + $LanguageName
				$url += "&sdVersion=2"
				if ($Verbosity -ge 2) {
					Write-Host Querying $url
				}

				$i = 0
				$script:SelectedIndex = 0

				try {
					$Is64 = [Environment]::Is64BitOperatingSystem
					# Must add a referer for this request, else Microsoft's servers will deny it
					$ref = "https://www.microsoft.com/software-download/windows11"
					$r = Invoke-WebRequest -Method Post -Headers @{ "Referer" = $ref } -UseBasicParsing -TimeoutSec $DefaultTimeout -UserAgent $UserAgent -WebSession $Session $url
					if ($r -match "errorModalMessage") {
						$Alt = [regex]::Match($r.Content, '<p id="errorModalMessage">(.+?)<\/p>').Groups[1].Value -replace "<[^>]+>" -replace "\s+", " " -replace "\?\?\?", "-"
						$Alt = [System.Text.Encoding]::UTF8.GetString([byte[]][char[]]$Alt)
						if (!$Alt) {
							$Alt = "Could not retrieve architectures from server"
						} elseif ($Alt -match "715-123130") {
							$Alt += " " + $SessionId + "."
						}
						Throw-Error -Req $r -Alt $Alt
					}
					$pattern = '(?s)(<input.*?></input>)'
					ForEach-Object { [regex]::Matches($r, $pattern) } | ForEach-Object { $html += $_.Groups[1].value }
					# Need to fix the HTML and JSON data so that it is well-formed
					$html = $html.Replace("class=product-download-hidden", "")
					$html = $html.Replace("type=hidden", "")
					$html = $html.Replace("&nbsp;", " ")
					$html = $html.Replace("IsoX86", "&quot;x86&quot;")
					$html = $html.Replace("IsoX64", "&quot;x64&quot;")
					$html = "<inputs>" + $html + "</inputs>"
					$xml = [xml]$html
					foreach ($var in $xml.inputs.input) {
						$json = $var.value | ConvertFrom-Json;
						if ($json) {
							if (($Is64 -and $json.DownloadType -eq "x64") -or (!$Is64 -and $json.DownloadType -eq "x86")) {
								$script:SelectedIndex = $i
							}
							$links += @(New-Object PsObject -Property @{ Type = $json.DownloadType; Link = $json.Uri })
							$i++
						}
					}
					if ($links.Length -eq 0) {
						Throw-Error -Req $r -Alt "Could not retrieve ISO download links"
					}
				} catch {
					Error($_.Exception.Message)
					return @()
				}
			}
			return $links
		}

		# Process the download URL by either sending it through the pipe or by opening the browser
		function Process-Download-Link([string]$Url)
		{
			try {
				if ($PipeName -and !$Check.IsChecked) {
					Send-Message -PipeName $PipeName -Message $Url
				} else {
					if ($Cmd) {
						$pattern = '.*\/(.*\.iso).*'
						$File = [regex]::Match($Url, $pattern).Groups[1].Value
						# PowerShell implicit conversions are iffy, so we need to force them...
						$str_size = (Invoke-WebRequest -UseBasicParsing -TimeoutSec $DefaultTimeout -Uri $Url -Method Head).Headers.'Content-Length'
						$tmp_size = [uint64]::Parse($str_size)
						$Size = Size-To-Human-Readable $tmp_size
						Write-Host "Downloading '$File' ($Size)..."
						Start-BitsTransfer -Source $Url -Destination $File
					} else {
						Write-Host Download Link: $Url
						Start-Process -FilePath $Url
					}
				}
			} catch {
				Error($_.Exception.Message)
				return 404
			}
			return 0
		}

		if ($Cmd) {
			$winVersionId = $null
			$winReleaseId = $null
			$winEditionId = $null
			$winLanguageId = $null
			$winLanguageName = $null
			$winLink = $null

			# Windows 7 and non Windows platforms are too much of a liability
			if ($winver -le 6.1) {
				Error(Get-Translation("This feature is not available on this platform."))
				exit 403
			}

			$i = 0
			$Selected = ""
			if ($Win -eq "List") {
				Write-Host "Please select a Windows Version (-Win):"
			}
			foreach($version in $WindowsVersions) {
				if ($Win -eq "List") {
					Write-Host " -" $version[0][0]
				} elseif ($version[0][0] -match $Win) {
					$Selected += $version[0][0]
					$winVersionId = $i
					break;
				}
				$i++
			}
			if ($winVersionId -eq $null) {
				if ($Win -ne "List") {
					Write-Host "Invalid Windows version provided."
					Write-Host "Use '-Win List' for a list of available Windows versions."
				}
				exit 1
			}

			# Windows Version selection
			$releases = Get-Windows-Releases $winVersionId
			if ($Rel -eq "List") {
				Write-Host "Please select a Windows Release (-Rel) for ${Selected} (or use 'Latest' for most recent):"
			}
			foreach ($release in $releases) {
				if ($Rel -eq "List") {
					Write-Host " -" $release.Release
				} elseif (!$Rel -or $release.Release.StartsWith($Rel) -or $Rel -eq "Latest") {
					if (!$Rel -and $Verbosity -ge 1) {
						Write-Host "No release specified (-Rel). Defaulting to '$($release.Release)'."
					}
					$Selected += " " + $release.Release
					$winReleaseId = $release.Index
					break;
				}
			}
			if ($winReleaseId -eq $null) {
				if ($Rel -ne "List") {
					Write-Host "Invalid Windows release provided."
					Write-Host "Use '-Rel List' for a list of available $Selected releases or '-Rel Latest' for latest."
				}
				exit 1
			}

			# Windows Release selection => Populate Product Edition
			$editions = Get-Windows-Editions $winVersionId $winReleaseId
			if ($Ed -eq "List") {
				Write-Host "Please select a Windows Edition (-Ed) for ${Selected}:"
			}
			foreach($edition in $editions) {
				if ($Ed -eq "List") {
					Write-Host " -" $edition.Edition
				} elseif (!$Ed -or $edition.Edition -match $Ed) {
					if (!$Ed -and $Verbosity -ge 1) {
						Write-Host "No edition specified (-Ed). Defaulting to '$($edition.Edition)'."
					}
					$Selected += "," + $edition.Edition -replace "Windows [0-9\.]*"
					$winEditionId = $edition.Id
					break;
				}
			}
			if ($winEditionId -eq $null) {
				if ($Ed -ne "List") {
					Write-Host "Invalid Windows edition provided."
					Write-Host "Use '-Ed List' for a list of available editions or remove the -Ed parameter to use default."
				}
				exit 1
			}

			# Product Edition selection => Request and populate Languages
			$languages = Get-Windows-Languages $winVersionId $winEditionId
			if (!$languages) {
				exit 3
			}
			if ($Lang -eq "List") {
				Write-Host "Please select a Language (-Lang) for ${Selected}:"
			} elseif ($Lang) {
				# Escape parentheses so that they aren't interpreted as regex
				$Lang = $Lang.replace('(', '\(')
				$Lang = $Lang.replace(')', '\)')
			}
			$i = 0
			foreach ($language in $languages) {
				if ($Lang -eq "List") {
					Write-Host " -" $language.Language
				} elseif ((!$Lang -and $script:SelectedIndex -eq $i) -or ($Lang -and $language.Language -match $Lang)) {
					if (!$Lang -and $Verbosity -ge 1) {
						Write-Host "No language specified (-Lang). Defaulting to '$($language.Language)'."
					}
					$Selected += ", " + $language.Language
					$winLanguageId = $language.Id
					$winLanguageName = $language.Language
					break;
				}
				$i++
			}
			if (!$winLanguageId -or !$winLanguageName) {
				if ($Lang -ne "List") {
					Write-Host "Invalid Windows language provided."
					Write-Host "Use '-Lang List' for a list of available languages or remove the option to use system default."
				}
				exit 1
			}

			# Language selection => Request and populate Arch download links
			$links = Get-Windows-Download-Links $winVersionId $winReleaseId $winEditionId $winLanguageId $winLanguageName
			if (!$links) {
				exit 3
			}
			if ($Arch -eq "List") {
				Write-Host "Please select an Architecture (-Arch) for ${Selected}:"
			}
			$i = 0
			foreach ($link in $links) {
				if ($Arch -eq "List") {
					Write-Host " -" $link.Type
				} elseif ((!$Arch -and $script:SelectedIndex -eq $i) -or ($Arch -and $link.Type -match $Arch)) {
					if (!$Arch -and $Verbosity -ge 1) {
						Write-Host "No architecture specified (-Arch). Defaulting to '$($link.Type)'."
					}
					$Selected += ", [" + $link.Type + "]"
					$winLink = $link
					break;
				}
				$i++
			}
			if ($winLink -eq $null) {
				if ($Arch -ne "List") {
					Write-Host "Invalid Windows architecture provided."
					Write-Host "Use '-Arch List' for a list of available architectures or remove the option to use system default."
				}
				exit 1
			}

			# Arch selection => Return selected download link
			if ($ShowUrl) {
				Return $winLink.Link
				$ExitCode = 0
			} else {
				Write-Host "Selected: $Selected"
				$ExitCode = Process-Download-Link $winLink.Link
			}

			# Clean up & exit
			exit $ExitCode
		}

		# Form creation
		$XMLForm = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $XAML))
		$XAML.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $XMLForm.FindName($_.Name) -Scope Script }
		$XMLForm.Title = $AppTitle
		if ($Icon) {
			$XMLForm.Icon = $Icon
		} else {
			$XMLForm.Icon = [WinAPI.Utils]::ExtractIcon("imageres.dll", -5205, $true) | ConvertTo-ImageSource
		}
		if ($Locale.StartsWith("ar") -or $Locale.StartsWith("fa") -or $Locale.StartsWith("he")) {
			$XMLForm.FlowDirection = "RightToLeft"
		}
		$WindowsVersionTitle.Text = Get-Translation("Version")
		$Continue.Content = Get-Translation("Continue")
		$Back.Content = Get-Translation("Close")

		# Windows 7 and non Windows platforms are too much of a liability
		if ($winver -le 6.1) {
			Error(Get-Translation("This feature is not available on this platform."))
			exit 403
		}

		# Populate the Windows versions
		$i = 0
		$versions = @()
		foreach($version in $WindowsVersions) {
			$versions += @(New-Object PsObject -Property @{ Version = $version[0][0]; PageType = $version[0][1]; Index = $i })
			$i++
		}
		$WindowsVersion.ItemsSource = $versions
		$WindowsVersion.DisplayMemberPath = "Version"

		# Button Action
		$Continue.add_click({
			$script:Stage++
			$XMLGrid.Children[2 * $Stage + 1].IsEnabled = $false
			$Continue.IsEnabled = $false
			$Back.IsEnabled = $false
			Refresh-Control($Continue)
			Refresh-Control($Back)

			switch ($Stage) {

				1 { # Windows Version selection
					$XMLForm.Title = Get-Translation($English[12])
					Refresh-Control($XMLForm)
					if ($WindowsVersion.SelectedValue.Version.StartsWith("Windows")) {
						Check-Locale
					}
					$releases = Get-Windows-Releases $WindowsVersion.SelectedValue.Index
					$script:WindowsRelease = Add-Entry $Stage "Release" $releases
					$Back.Content = Get-Translation($English[8])
					$XMLForm.Title = $AppTitle
				}

				2 { # Windows Release selection => Populate Product Edition
					$editions = Get-Windows-Editions $WindowsVersion.SelectedValue.Index $WindowsRelease.SelectedValue.Index
					$script:ProductEdition = Add-Entry $Stage "Edition" $editions
				}

				3 { # Product Edition selection => Request and populate languages
					$XMLForm.Title = Get-Translation($English[12])
					Refresh-Control($XMLForm)
					$languages = Get-Windows-Languages $WindowsVersion.SelectedValue.Index $ProductEdition.SelectedValue.Id
					if ($languages.Length -eq 0) {
						break
					}
					$script:Language = Add-Entry $Stage "Language" $languages "DisplayLanguage"
					$Language.SelectedIndex = $script:SelectedIndex
					$XMLForm.Title = $AppTitle
				}

				4 { # Language selection => Request and populate Arch download links
					$XMLForm.Title = Get-Translation($English[12])
					Refresh-Control($XMLForm)
					$links = Get-Windows-Download-Links $WindowsVersion.SelectedValue.Index $WindowsRelease.SelectedValue.Index $ProductEdition.SelectedValue.Id $Language.SelectedValue.Id $Language.SelectedValue.Language
					if ($links.Length -eq 0) {
						break
					}
					$script:Architecture = Add-Entry $Stage "Architecture" $links "Type"
					if ($PipeName) {
						$XMLForm.Height += $dh / 2;
						$Margin = $Continue.Margin
						$top = $Margin.Top
						$Margin.Top += $dh /2
						$Continue.Margin = $Margin
						$Margin = $Back.Margin
						$Margin.Top += $dh / 2
						$Back.Margin = $Margin
						$Margin = $Check.Margin
						$Margin.Top = $top - 2
						$Check.Margin = $Margin
						$Check.Content = Get-Translation($English[13])
						$Check.Visibility = "Visible"
					}
					$Architecture.SelectedIndex = $script:SelectedIndex
					$Continue.Content = Get-Translation("Download")
					$XMLForm.Title = $AppTitle
				}

				5 { # Arch selection => Return selected download link
					$script:ExitCode = Process-Download-Link $Architecture.SelectedValue.Link
					$XMLForm.Close()
				}
			}
			$Continue.IsEnabled = $true
			if ($Stage -ge 0) {
				$Back.IsEnabled = $true
			}
		})

		$Back.add_click({
			if ($Stage -eq 0) {
				$XMLForm.Close()
			} else {
				$XMLGrid.Children.RemoveAt(2 * $Stage + 3)
				$XMLGrid.Children.RemoveAt(2 * $Stage + 2)
				$XMLGrid.Children[2 * $Stage + 1].IsEnabled = $true
				$dh2 = $dh
				if ($Stage -eq 4 -and $PipeName) {
					$Check.Visibility = "Collapsed"
					$dh2 += $dh / 2
				}
				$XMLForm.Height -= $dh2;
				$Margin = $Continue.Margin
				$Margin.Top -= $dh2
				$Continue.Margin = $Margin
				$Margin = $Back.Margin
				$Margin.Top -= $dh2
				$Back.Margin = $Margin
				$script:Stage = $Stage - 1
				$XMLForm.Title = $AppTitle
				if ($Stage -eq 0) {
					$Back.Content = Get-Translation("Close")
				} else {
					$Continue.Content = Get-Translation("Continue")
					Refresh-Control($Continue)
				}
			}
		})

		# Display the dialog
		$XMLForm.Add_Loaded({$XMLForm.Activate()})
		$XMLForm.ShowDialog() | Out-Null

		# Clean up & exit
		exit $ExitCode

    }catch{
        Write-Error $_
    }finally{


    }
}

function Save-RufusProgram {
	try{
		$Url = "https://github.com/pbatard/rufus/releases/download/v4.5/rufus-4.5p.exe"
		$OutFile = "$PSScriptPath\rufus-4.5.exe"
		if(Test-Path -Path $Outfile){
			Write-Host "already exists!"
			return;
		}
		$r = Invoke-WebRequest -Uri $Url -OutFile "$PSScriptPath\rufus-4.5.exe" -Passthru
		if($r.StatusCode -ne 200) { throw "error on download rufus" }
	}catch{

	}
}

function Test-SearchWin10Iso{
	Search-Windows10Iso -Win 10 -Ed Edu -Arch x64 -Rel Latest -ShowUrl  
}
