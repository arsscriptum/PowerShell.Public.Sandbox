


[CmdletBinding(SupportsShouldProcess)]
param()


function Register-HtmlAgilityPack {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $False)]
        [string]$Path
    )
    begin {
        if ([string]::IsNullOrEmpty($Path)) {
            $Path = "{0}\lib\{1}\HtmlAgilityPack.dll" -f "$PSScriptRoot", "$($PSVersionTable.PSEdition)"
        }
    }
    process {
        try {
            if (-not (Test-Path -Path "$Path" -PathType Leaf)) { throw "no such file `"$Path`"" }
            if (!("HtmlAgilityPack.HtmlDocument" -as [type])) {
                Write-Verbose "Registering HtmlAgilityPack... "
                add-type -Path "$Path"
            } else {
                Write-Verbose "HtmlAgilityPack already registered "
            }
        } catch {
            throw $_
        }
    }
}

function Register-LinkedInCreds {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "Gui")]
        [switch]$Gui
    )

    Write-Host "`n==============================="
    Write-Host "   ENTER LINKEDIN CREDENTIALS"
    Write-Host "===============================`n"

    if ($Gui) {
        Add-Type -AssemblyName System.Windows.Forms

        $form = New-Object System.Windows.Forms.Form
        $form.Text = "LinkedIn Credentials"
        $form.Size = New-Object System.Drawing.Size (300, 220)
        $form.StartPosition = "CenterScreen"

        $usernameLabel = New-Object System.Windows.Forms.Label
        $usernameLabel.Text = "Username:"
        $usernameLabel.Location = New-Object System.Drawing.Point (10, 20)
        $usernameLabel.Size = New-Object System.Drawing.Size (280, 20)
        $form.Controls.Add($usernameLabel)

        $usernameBox = New-Object System.Windows.Forms.TextBox
        $usernameBox.Location = New-Object System.Drawing.Point (10, 40)
        $usernameBox.Size = New-Object System.Drawing.Size (260, 20)
        $form.Controls.Add($usernameBox)

        $passwordLabel = New-Object System.Windows.Forms.Label
        $passwordLabel.Text = "Password:"
        $passwordLabel.Location = New-Object System.Drawing.Point (10, 70)
        $passwordLabel.Size = New-Object System.Drawing.Size (280, 20)
        $form.Controls.Add($passwordLabel)

        $passwordBox = New-Object System.Windows.Forms.TextBox
        $passwordBox.Location = New-Object System.Drawing.Point (10, 90)
        $passwordBox.Size = New-Object System.Drawing.Size (260, 20)
        $passwordBox.UseSystemPasswordChar = $true
        $form.Controls.Add($passwordBox)

        $confirmLabel = New-Object System.Windows.Forms.Label
        $confirmLabel.Text = "Confirm Password:"
        $confirmLabel.Location = New-Object System.Drawing.Point (10, 120)
        $confirmLabel.Size = New-Object System.Drawing.Size (280, 20)
        $form.Controls.Add($confirmLabel)

        $confirmBox = New-Object System.Windows.Forms.TextBox
        $confirmBox.Location = New-Object System.Drawing.Point (10, 140)
        $confirmBox.Size = New-Object System.Drawing.Size (260, 20)
        $confirmBox.UseSystemPasswordChar = $true
        $form.Controls.Add($confirmBox)

        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Text = "OK"
        $okButton.Location = New-Object System.Drawing.Point (100, 170)
        $okButton.Add_Click({
                if ($passwordBox.Text -ne $confirmBox.Text) {
                    [System.Windows.Forms.MessageBox]::Show("Passwords do not match.", "Error", 'OK', 'Error')
                } elseif (-not $usernameBox.Text -or -not $passwordBox.Text) {
                    [System.Windows.Forms.MessageBox]::Show("Username or Password cannot be empty.", "Error", 'OK', 'Error')
                } else {
                    $form.Tag = $true
                    $form.Close()
                }
            })
        $form.Controls.Add($okButton)

        $form.ShowDialog() | Out-Null

        if (-not $form.Tag) {
            Write-Error "User cancelled or error occurred."
            return
        }

        $UsernameInputted = $usernameBox.Text
        $PasswordInputted = $passwordBox.Text
    }
    else {
        $UsernameInputted = Read-Host "Enter your LinkedIn username"
        $pass1 = Read-Host "Enter password" -AsSecureString
        $pass2 = Read-Host "Confirm password" -AsSecureString

        if (([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass1))) -ne
            ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass2)))) {
            Write-Error "Passwords do not match."
            return
        }

        $PasswordInputted = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass1))
    }

    $Success = Register-AppCredentials -Id "LinkedInWebPage" -Username $UsernameInputted -Password $PasswordInputted
}






function Resolve-AnyPath {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, HelpMessage = 'Path')]
        [string]$Path,
        [Parameter(Mandatory = $False, HelpMessage = 'Recursive')]
        [switch]$CreateIfMissing
    )

    process {
        try {
            [string]$ReturnValue = ''
            [System.Management.Automation.PathInfo]$FullDestinationPathInfo = Resolve-Path -Path "$Path" -ErrorAction Stop
            $ReturnValue = $FullDestinationPathInfo.Path
        } catch {
            [System.Management.Automation.ErrorCategoryInfo]$CatInfo = $_.CategoryInfo
            if ($CatInfo.Category -eq 'ObjectNotFound') {
                $MissingPath = $CatInfo.TargetName
                [string]$ReturnValue = $MissingPath
                if ($CreateIfMissing) {
                    $null = New-Item -ItemType Directory -Path $MissingPath -Force -ErrorAction Ignore
                }
            }
        }
        return $MissingPath
    }
}

function Get-MachinTechImages {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$HtmlFilePath,
        [Parameter(Mandatory = $False, HelpMessage = 'Recursive')]
        [int]$MaxImages = 150
    )

    try {
        if (!(Test-Path -Path "$HtmlFilePath" -PathType Leaf)) {
            Write-Error "Html File path `"$HtmlFilePath`"  doesn't exists"
            return
        }

        Add-Type -AssemblyName System.Web

        $Null = Register-HtmlAgilityPack

        $Ret = $False
        $HtmlContent = Get-Content -Path "$HtmlFilePath" -Raw


        [HtmlAgilityPack.HtmlDocument]$HtmlDoc = @{}
        $HtmlDoc.LoadHtml($HtmlContent)

        $HtmlNode = $HtmlDoc.DocumentNode
        [System.Collections.ArrayList]$List = [System.Collections.ArrayList]::new()
        $HashTable = @{}
        [int]$i = 1
        $Proceed = $True
        while ($Proceed) {
            $XNodeAddr = "/html/body/div[7]/div[3]/div/div[2]/div/div[2]/main/div[2]/div/div/div[2]/div[3]/div/div[1]/div[{0}]/div/div/div/div/div/div/div[1]/div[3]/div/div/button/div/div/img" -f $i
            if ($i -gt $MaxImages) {
                $Proceed = $False
            } else {
                $i++
            }

            try {
                $ResultNode = $HtmlNode.SelectNodes($XNodeAddr)
                if (!$ResultNode) {
                    continue;
                }
                [string]$u = $ResultNode.Attributes[1].Value
                [string]$value = $u.Replace('&amp;', '&')
                [void]$List.Add($value)

            } catch {
                break;
            }

        }

        return $List

    } catch {
        Write-Verbose "$_"
        Write-Host "Error Occured. Probably Invalid Page Id" -f DarkRed
    }
    return $Null
}

function Show-MessageWithDelay {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Message')]
        [string]$Message,
        [Parameter(Mandatory = $false, Position = 1, HelpMessage = 'Delay')]
        [int]$Delay=10
    )

    Write-Host -n "$Message  " -f DarkRed

    for ($i = $Delay; $i -gt 0; $i--) {
        Write-Host -n "$i " -f DarkYellow
        Start-Sleep -Seconds 1
    }

    Write-Host  # Move to the next line after delay
}

function Save-BrowseLinkedInPage {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$CompanyName = "machitech-automation-inc-"
    )
    try {

        [string]$LogFilePath = Join-Path "$PSScriptRoot" " SaveBrowseLinkedInPage.log"
        [string]$datestr = ((Get-Date).GetDateTimeFormats()[19]) -as [string]
        [string]$logstr = "test started on $datestr"
        New-Item -Path "$LogFilePath" -ItemType File -Value  "$logstr" -Force | Out-Null


        $CredsCmd = Get-Command 'Get-AppCredentials'
        if (!$CredsCmd) { throw "no Get-AppCredentials command (core mod)" }
        Write-Host "Get-AppCredentials for LinkedInWebPage..." -f DarkYellow
        $Credz = Get-AppCredentials -Id "LinkedInWebPage"
        if (!$Credz) { throw "no LinkedInWebPage credentials registered, use Register-LinkedInCreds " }
        $LinkedInUsername = $Credz.UserName
        $LinkedInPassword = $Credz.GetNetworkCredential().Password

        $XPathUsername = '/html/body/div/main/div[3]/div[1]/form/div[1]/input'

        $XPathPassword = '/html/body/div/main/div[3]/div[1]/form/div[2]/input'

        $XPathLoginButton = '/html/body/div/main/div[3]/div[1]/form/div[4]/button'

        # Start a Firefox browser and go to the LinkedIn page
        $Url = "https://www.linkedin.com/company/{0}/posts/?feedView=all" -f $CompanyName
        
        $Driver = Start-SeFirefox -StartURL "$Url" -SuppressLogging
        Show-MessageWithDelay "Opening $Url..." -Delay 5
        Write-Host -n "Get Username Input Element..." -f DarkYellow
        $UsernameElement = Find-SeElement -Driver $Driver -Wait -Timeout 10 -XPath $XPathUsername
        if (!$UsernameElement) { throw "cannot find login input" }
        Write-Host "Ok!" -f DarkGreen
        Write-Host -n "Get Password Input Element..." -f DarkYellow
        $PasswordElement = Find-SeElement -Driver $Driver -Wait -Timeout 10 -XPath $XPathPassword
        if (!$PasswordElement) { throw "cannot find password input" }
        Write-Host "Ok!" -f DarkGreen
        Write-Host -n "Get Login Button Element..." -f DarkYellow
        $LoginButtonElem = Find-SeElement -Driver $Driver -Wait -Timeout 10 -XPath $XPathLoginButton
        if (!$LoginButtonElem) { throw "cannot find login btn" }
        Write-Host "Ok!" -f DarkGreen

        Write-Host "Inputting Username..." -f DarkYellow

        Send-SeKeys -Element $UsernameElement -Keys "$LinkedInUsername"
        Start-Sleep 3

        Write-Host "Inputting Password..." -f DarkYellow
        Send-SeKeys -Element $PasswordElement -Keys "$LinkedInPassword"
        Start-Sleep 2

        Write-Host "Login In...." -f DarkYellow
        Invoke-SeClick -Element $LoginButtonElem

        Show-MessageWithDelay "Page Loading..." -Delay 5

        $DoConvertBytes =  (Get-Command 'Convert-Bytes' -ErrorAction Ignore) -ne $Null

        [int]$TotalSize = 0
        [int]$NumReloads = 0
        [int]$MaxReloads = 20
        [int]$ZeroSizeCount = 0
        [bool]$NomoreData = $false

        # Scroll loop: simulate user scrolling down multiple times
        while( ($NomoreData -eq $False) -And ($NumReloads -lt $MaxReloads)){
            $Driver.ExecuteScript("window.scrollTo(0, document.body.scrollHeight);")
            $NumReloads++
            Show-MessageWithDelay "[$NumReloads / $MaxReloads] Auto Scroll User feed..." -Delay 2
            $HtmlBuffer = $Driver.PageSource
            $DownloadedSize = $HtmlBuffer.Length - $TotalSize
            
            $TotalSize += $DownloadedSize
            if($DownloadedSize -eq 0){
                Write-Host "no data streamed ($ZeroSizeCount)" -f DarkRed
                if($ZeroSizeCount -ge 3){
                    $NomoreData = $True
                    Write-Host "NO MORE DATA" -f DarkRed
                }else{
                    $ZeroSizeCount++    
                }
            }else{
                $TotalSizeStr = if($DoConvertBytes){ $TotalSize | Convert-Bytes }else{ "$TotalSize bytes" }
                $DownloadedSizeStr = if($DoConvertBytes){ $DownloadedSize | Convert-Bytes }else{ "$DownloadedSize bytes" }
                Write-Host "streamed $DownloadedSizeStr. Total so far $TotalSizeStr" -f DarkGreen
            }
        }

        # Once done, extract full HTML
        $Html = $Driver.PageSource

        $TotalSize = $Html.Length
        $TotalSizeStr = if($DoConvertBytes){ $TotalSize | Convert-Bytes }else{ "$TotalSize bytes" }
        Write-Host "Downloaded page source, total $TotalSizeStr"
        Add-Content -Path "$LogFilePath" -Value "Downloaded page source, total $TotalSizeStr"
        $OutFilePath = "$env:TEMP\linkedin_full.html"
        Write-Host "Saving to `"$OutFilePath bytes`""
        Add-Content -Path "$LogFilePath" -Value "Saving to `"$OutFilePath bytes`""

        # Save to file or parse it directly
        $Html | Out-File "$OutFilePath"


        Write-Host "Closing Webpage...." -f DarkMagenta
        $Driver.Close()
        $Driver.Dispose()
        Remove-Item -Path "$LogFilePath" -Recurse -Force | Out-Null

        return "$OutFilePath"


    } catch {
        if($Driver){
          $Driver.Close()
          $Driver.Dispose()    
        }
        
        Add-Content -Path "$LogFilePath" -Value "$_"
        $logs = Get-Content -Path "$LogFilePath" -Raw
        throw " $logs"
    }

}


function Save-LinkedInImage {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Url,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationPath
    )
    try {

        $FilePath = $Url.Replace('https://media.licdn.com', '')

        if (!(Test-Path -Path "$DestinationPath" -PathType Container)) {
            Write-Error "Download path `"$DestinationPath`"  doesn't exists. Create it before."
            return
        }
            
        
        if (!$FilePath.StartsWith('/dms')) {
            Write-Error "bad url `"$Url`" $FilePath"
        }
        $DoConvertBytes =  (Get-Command 'Convert-Bytes' -ErrorAction Ignore) -ne $Null

        [int]$RetSize = 0

        
        $OutFilePath = Join-Path "$DestinationPath" "$(Get-Random).jfif"
        $LogFilePath = $OutFilePath + ".log"
        
        New-Item -Path "$LogFilePath" -ItemType File -Value  "downloading file to `"$OutFilePath`"" -Force | Out-Null
        $RelLogPath = Resolve-Path -Path $LogFilePath -Relative
        $RelImgPath = $RelLogPath.TrimEnd('.log')
        $Headers = @{
            "authority" = "media.licdn.com"
            "method" = "GET"
            "path" = "$FilePath"
            "scheme" = "https"
            "accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8"
            "accept-encoding" = "gzip, deflate, br, zstd"
            "accept-language" = "en-US,en;q=0.7"
            "cache-control" = "no-cache"
            "pragma" = "no-cache"
            "priority" = "u=0, i"
            "referer" = "https://www.linkedin.com/"
            "sec-ch-ua" = "`"Brave`";v=`"135`", `"Not-A.Brand`";v=`"8`", `"Chromium`";v=`"135`""
            "sec-ch-ua-mobile" = "?0"
            "sec-ch-ua-platform" = "`"Windows`""
            "sec-fetch-dest" = "document"
            "sec-fetch-mode" = "navigate"
            "sec-fetch-site" = "cross-site"
            "sec-fetch-user" = "?1"
            "sec-gpc" = "1"
            "upgrade-insecure-requests" = "1"
        }
        

        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36"
        Write-Host " [i] downloading file to `"$RelImgPath`"" -f DarkCyan
        try{
           Invoke-WebRequest -UseBasicParsing -Uri "$Url" -WebSession $session -Headers $Headers -OutFile "$OutFilePath" -ErrorAction Stop -Verbose *> "$LogFilePath"
           $RetSize = (Get-Item "$OutFilePath").Length
           $RetSizeStr = if($DoConvertBytes){ $RetSize | Convert-Bytes }else{ "$RetSize bytes" }
           Write-Host " [i] transfered $RetSizeStr" -f DarkGreen
           Remove-Item -Path "$LogFilePath" -Recurse -Force | Out-Null
        }catch{
            $RetSize = 0
            Write-Host " [!] transfered zero bytes!" -f DarkRed
        }
        
        return $RetSize
        

    } catch {
        Write-Error "$_"
    }

}



function Start-LinkedInScrapeTest {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    try {

        try{
            Write-Host "Register HtmlAgilityPack Libraries..." -f DarkCyan
            Register-HtmlAgilityPack
        }catch{
            Write-Host "Error registering HtmlAgilityPack!" -f DarkRed
            return;
        }
        try{
            Write-Host "Save page source for parsing..." -f DarkCyan
            $FilePath = Save-BrowseLinkedInPage 
        }catch{
            Write-Host "Error loading webpage" -f DarkRed
            return;
        }
        try{
            Write-Host "Parse web page source for image links..." -f DarkCyan
            $MachinTechImages = Get-MachinTechImages -HtmlFilePath "$FilePath"
            $MachinTechImagesCount = $MachinTechImages.Count
            Write-Host "Found $MachinTechImagesCount image!" -f DarkCyan
        }catch{
            Write-Host "Error parsing page for images links" -f DarkRed
            return;
        }
        
        $OutFileDir = Join-Path "$PWD" "downloaded_images"
        Remove-Item -Path "$OutFileDir" -Recurse -Force | Out-Null
        New-Item -Path "$OutFileDir" -ItemType Directory -Force | Out-Null

        $GitIgnore = Join-Path "$PWD" ".gitignore"
        Add-Content -Path "$GitIgnore" -Value "downloaded_images" -Force
        [int]$linkcount=1
        [int]$imgcount=0
        foreach ($img in $MachinTechImages) {
            $log = "`nProcessing Image Link {0}/{1}..." -f $linkcount, $MachinTechImagesCount
            Write-Host "$log" -f DarkYellow
            $RetSize = Save-LinkedInImage -Url "$img" -DestinationPath "$OutFileDir"
            if($RetSize -eq 0){
                Write-Host " [!] download failed!" -f DarkRed
            }else{
                $imgcount++
                Write-Host " [i] downloaded image no $imgcount / $MachinTechImagesCount" -f DarkGreen
            }
            $linkcount++
        }

        $ExplorerExe = (Get-Command 'explorer.exe').Source
        & "$ExplorerExe" "$OutFileDir"


    } catch {
        Write-Error "$_"
    }

}

