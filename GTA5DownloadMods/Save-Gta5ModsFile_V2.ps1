
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Import-ScriptDependencies{
<#
    .SYNOPSIS
            Create a RandomFilename 
    .DESCRIPTION
            Create a RandomFilename 
#>

    [CmdletBinding(SupportsShouldProcess)]
    param()    
    try{

      $ShowNotifPath = Join-Path "$PSScriptRoot\systray" "ShowSystemTrayNotification.ps1"
      . "$ShowNotifPath"
      Import-Module  "$PSScriptRoot\lib\NativeProgressBar.dll" -Force
      Write-Verbose "Import-Module  `"$PSScriptRoot\lib\NativeProgressBar.dll`""
      $FatalError = $False
      try{
          Write-Verbose "Check Register-AsciiProgressBar"
          Get-Command 'Register-AsciiProgressBar' -ErrorAction Stop | Out-Null 
          Write-Verbose "Check Unregister-AsciiProgressBar"
          Get-Command 'Unregister-AsciiProgressBar' -ErrorAction Stop | Out-Null 
          Write-Verbose "Check Write-AsciiProgressBar"
          Get-Command 'Write-AsciiProgressBar' -ErrorAction Stop | Out-Null 
          Write-Verbose "Check Show-SystemTrayNotification"
          Get-Command 'Show-SystemTrayNotification' -ErrorAction Stop | Out-Null 
      }catch [Exception]{
          Write-Host "[MISSING DEPENDENCY] " -f DarkRed -n
          Write-Host "$_" -f DarkYellow
          Write-Host "Make sure to include:`n==> `"$PSScriptRoot\lib\NativeProgressBar.dll`"`n==> `"$ShowNotifPath`"" -f DarkRed
          $FatalError = $True
      }
      if($FatalError){
          return
      }

    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
}



function Invoke-CustomWebRequest{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]$Uri,
        [Parameter(Mandatory=$True, Position=1)]
        [string]$OutFile,  
        [Parameter(Mandatory=$False)]
        [Hashtable]$CustomHeaders,
        [Parameter(Mandatory=$False)]
        [System.Net.CookieContainer]$CookieContainer,
        [Parameter(Mandatory=$False)]
        [uint32]$TimeoutMilliseconds=15000,
        [Parameter(Mandatory=$False)]
        [string]$Method='GET',
        [Parameter(Mandatory=$False)]
        [string]$Referer=''

    ) 
    try{
        new-item -path $OutFile -ItemType 'File' -Force | Out-Null
        remove-item -path $OutFile -Force | Out-Null

        $Script:ProgressTitle = 'STATE: DOWNLOAD'
        $uri = New-Object "System.Uri" "$Uri"
        $request = [System.Net.HttpWebRequest]::Create($Uri)
        $request.PreAuthenticate = $false
        $request.Method = $Method
        $request.Headers = New-Object System.Net.WebHeaderCollection
        if($Null -ne $CustomHeaders){
          $CustomHeaders.GetEnumerator() | % {
            $key = $_.Key
            $val = $_.Value
            $request.Headers.Add($key,$val)
          }
        }
        $request.Referer = $Referer
        # 15 second timeout
        $request.set_Timeout($TimeoutMilliseconds) 
        if($Null -ne $WebSession){
          $request.CookieContainer = $WebSession
        }
        # Cache Policy : no cache
        $request.CachePolicy                  = New-Object Net.Cache.RequestCachePolicy([Net.Cache.RequestCacheLevel]::NoCacheNoStore)


        $awaitedResult = await $request.GetResponseAsync()

        # create the Stream, FileStream and WebResponse objects
        [System.Net.WebResponse]$response     = $request.GetResponse()
        [System.IO.Stream]$responseStream     = $response.GetResponseStream()
        [System.IO.FileStream]$targetStream   = [System.IO.FileStream]::new($OutFile, [System.IO.FileMode]::Create)
        [long]$total_bytes                    = [System.Math]::Floor($response.get_ContentLength())
        [long]$total_kilobytes                = [System.Math]::Floor($total_bytes/1024)

        $buffer                               = new-object byte[] 10KB
        $count                                = $responseStream.Read($buffer,0,$buffer.length)
        $dlkb                                 = 0
        $downloadedBytes                      = $count

        Register-AsciiProgressBar -Size 60 -ShowCursor $false
        # Automatically hide the cursor, to keep the cursor visible, use the argument -ShowCursor $true
        #Register-AsciiProgressBar -Size 60 -ShowCursor $true

        while ($count -gt 0){
           $targetStream.Write($buffer, 0, $count)
           $count                   = $responseStream.Read($buffer,0,$buffer.length)
           $downloadedBytes         = $downloadedBytes + $count
           $dlkb                    = $([System.Math]::Floor($downloadedBytes/1024))
           $msg                     = "Downloaded $dlkb Kb of $total_kilobytes Kb"
           $perc                    = (($downloadedBytes / $total_bytes)*100)
           if(($perc -gt 0)-And($perc -lt 100)){
                Write-AsciiProgressBar $perc $msg 50 2 "DarkYellow" "DarkGray"
           }
        }
        Unregister-AsciiProgressBar

        $targetStream.Flush()
        $targetStream.Close()
        $targetStream.Dispose()
        $responseStream.Dispose()
    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
}




function Get-CookieContainerData{
    [CmdletBinding(SupportsShouldProcess)]
    param() 

    $CookieContainer = New-Object System.Net.CookieContainer
    $CookieContainer.Add((New-Object System.Net.Cookie("_ga", "GA1.1.1820235975.1695009391", "/", ".lcpdfr.com")))
    $CookieContainer.Add((New-Object System.Net.Cookie("FPID", "FPID2.2.0XgG5naqiL%2FFH5Idk5gxOAp5joYCpIGZbasO2p5h9V4%3D.1695009391", "/", ".lcpdfr.com")))
    $CookieContainer.Add((New-Object System.Net.Cookie("ips4_g17_auth", "g17_6507cae43ba6e0.58402953", "/", "www.lcpdfr.com")))
    $CookieContainer.Add((New-Object System.Net.Cookie("Shortflare_Sec", "c9630bf2f1d32bc8df97351571b25b9d", "/", "www.lcpdfr.com")))
    $CookieContainer.Add((New-Object System.Net.Cookie("ips4_IPSSessionFront", "c2167d0e5a59a29475cc79f588ec9d42", "/", "www.lcpdfr.com")))
    $CookieContainer.Add((New-Object System.Net.Cookie("ips4_ipsTimezone", "America/Toronto", "/", "www.lcpdfr.com")))
    $CookieContainer.Add((New-Object System.Net.Cookie("ips4_hasJS", "true", "/", "www.lcpdfr.com")))
    $CookieContainer.Add((New-Object System.Net.Cookie("FPLC", "G8sgcZ1rGLvgnoN2uWqHdyJ2bQkD9qhbnm6mhQSDxofgFSK%2B1t%2BZfZ3k9n4aKpehLTF55GyxpTE31xqUbp6ZfUUjHD%2Bhyr10rDRpLSRTjhjV%2FE70sWqr5xVTPL04iA%3D%3D", "/", ".lcpdfr.com")))
    $CookieContainer.Add((New-Object System.Net.Cookie("_ga_T3QZZKPFFV", "GS1.1.1695144182.3.1.1695144405.0.0.0", "/", ".lcpdfr.com")))

    $CookieContainer
}

function Save-Gta5ModsFile{
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory = $True,Position=0, HelpMessage="Destination FileName")]
        [string]$FileName,
        [Parameter(Mandatory = $false,Position=0, HelpMessage="Destination Directory")]
        [string]$DestinationDirectory = "$PSScriptRoot\downloads"
    )
    begin{
        $CookieContainerData = Get-CookieContainerData
        $validationId = "dbce636f5ccc8c3c0cfc77957a8a4bbd"
        $csrfKey = "f918135c1427a632b6b9b77628aec183"
        $key = "1695144553"
        $fileId = "473528"

        $baseUrl = "https://www.lcpdfr.com/downloads/gta5mods/character/37322-german-hamburg-bremen-and-nrw-vest-skins-4k"
        $requestArguments = "?do=download&r={0}&confirm=1&t=1&csrfKey={1}&e={2}&validation={3}&servingMethod=8&fl=true" -f $fileId, $csrfKey, $key, $validationId
        $referer = "https://www.lcpdfr.com/downloads/gta5mods/"
        $dlFilePath = "/downloads/gta5mods/character/37322-german-hamburg-bremen-and-nrw-vest-skins-4k/{0}" -f $requestArguments
    }
    process{
      try{

        $headers = @{
          "authority"="www.lcpdfr.com"
          "method"="GET"
          "path"="$dlFilePath"
          "scheme"="https"
          "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
          "accept-encoding"="gzip, deflate, br"
          "accept-language"="fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"
          "referer"="$referer"
          "sec-ch-ua"="`"Not.A/Brand`";v=`"8`", `"Chromium`";v=`"114`", `"Google Chrome`";v=`"114`""
          "sec-ch-ua-mobile"="?0"
          "sec-ch-ua-platform"="`"Windows`""
          "sec-fetch-dest"="empty"
          "sec-fetch-mode"="navigate"
          "sec-fetch-site"="same-origin"
          "upgrade-insecure-requests"="1"
        }

        $downloadDirectoryName = (get-date).GetDateTimeFormats()[5].Replace(' ','_').Replace(',','').Replace(':','-') -as [string]
        $DownloadLocation = "$DestinationDirectory\$downloadDirectoryName"
        New-Item -Path "$DownloadLocation" -ItemType Directory -Force -ErrorAction Ignore | Out-Null
        $destinationFile = Join-Path $DownloadLocation $FileName
        $uri = "{0}/{1}" -f $baseUrl, $requestArguments

        Write-Verbose "uri $uri"
        Write-Verbose "requestArguments $requestArguments"
        Write-Verbose "referer $referer"
        Write-Verbose "destinationFile $destinationFile"
        Invoke-CustomWebRequest -Uri $uri -CustomHeaders $headers -CookieContainer $CookieContainerData -OutFile $destinationFile -Referer $referer
      }catch{
        Show-ExceptionDetails $_ -ShowStack
      }
    }
}

Import-ScriptDependencies -Verbose
Save-Gta5ModsFile -FileName 'NRW-HH-HB-Vest.zip' -Verbose

