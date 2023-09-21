# Download a Specific file

PowerShell function to save a file from a url. From this [Reddit Post](https://www.reddit.com/r/PowerShell/comments/16lks21/how_can_i_download_from_this_website_wwwlcpdfrcom/)

## Save-Gta5ModsFile

```
  function Get-WebRequestSessionData{
    [CmdletBinding(SupportsShouldProcess)]
    param() 

    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
    $session.Cookies.Add((New-Object System.Net.Cookie("_ga", "GA1.1.1820235975.1695009391", "/", ".lcpdfr.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("FPID", "FPID2.2.0XgG5naqiL%2FFH5Idk5gxOAp5joYCpIGZbasO2p5h9V4%3D.1695009391", "/", ".lcpdfr.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("ips4_g17_auth", "g17_6507cae43ba6e0.58402953", "/", "www.lcpdfr.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("Shortflare_Sec", "c9630bf2f1d32bc8df97351571b25b9d", "/", "www.lcpdfr.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("ips4_IPSSessionFront", "c2167d0e5a59a29475cc79f588ec9d42", "/", "www.lcpdfr.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("ips4_ipsTimezone", "America/Toronto", "/", "www.lcpdfr.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("ips4_hasJS", "true", "/", "www.lcpdfr.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("FPLC", "G8sgcZ1rGLvgnoN2uWqHdyJ2bQkD9qhbnm6mhQSDxofgFSK%2B1t%2BZfZ3k9n4aKpehLTF55GyxpTE31xqUbp6ZfUUjHD%2Bhyr10rDRpLSRTjhjV%2FE70sWqr5xVTPL04iA%3D%3D", "/", ".lcpdfr.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("_ga_T3QZZKPFFV", "GS1.1.1695144182.3.1.1695144405.0.0.0", "/", ".lcpdfr.com")))

    $session
  }

 function Save-Gta5ModsFile{
    [CmdletBinding(SupportsShouldProcess)]
    param() 
    begin{
        $session = Get-WebRequestSessionData
        $validationId = "dbce636f5ccc8c3c0cfc77957a8a4bbd"
        $csrfKey = "f918135c1427a632b6b9b77628aec183"
        $key = "1695144553"
        $fileId = "473528"

        $baseUrl = "https://www.lcpdfr.com/downloads/gta5mods/character/37322-german-hamburg-bremen-and-nrw-vest-skins-4k"
        $requestArguments = "?do=download&r={0}&confirm=1&t=1&csrfKey={1}&e={2}&validation={3}&servingMethod=8&fl=true" -f $fileId, $csrfKey, $key, $validationId
        $referer = "{0}/?do=download&r={1}&confirm=1&t=1&csrfKey={2}" -f $baseUrl, $fileId, $csrfKey
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
          "referer"="https://www.lcpdfr.com/downloads/gta5mods/"
          "sec-ch-ua"="`"Not.A/Brand`";v=`"8`", `"Chromium`";v=`"114`", `"Google Chrome`";v=`"114`""
          "sec-ch-ua-mobile"="?0"
          "sec-ch-ua-platform"="`"Windows`""
          "sec-fetch-dest"="empty"
          "sec-fetch-mode"="navigate"
          "sec-fetch-site"="same-origin"
          "upgrade-insecure-requests"="1"
        }

        $downloadDirectoryName = (get-date).GetDateTimeFormats()[5].Replace(' ','_').Replace(',','').Replace(':','-') -as [string]
        $destinationDirectory = "$PSScriptRoot\downloads\$downloadDirectoryName"
        New-Item -Path "$destinationDirectory" -ItemType Directory -Force -ErrorAction Ignore | Out-Null
        $destinationFile = Join-Path $destinationDirectory 'NRW-HH-HB-Vest.zip'
        $uri = "{0}/{1}" -f $baseUrl, $requestArguments

        Write-Verbose "uri $uri"
        Write-Verbose "requestArguments $requestArguments"
        Write-Verbose "referer $referer"
        Write-Verbose "destinationFile $destinationFile"
        Invoke-WebRequest -UseBasicParsing -Uri $uri -Headers $headers -WebSession $session -OutFile $destinationFile
      }catch{
        Write-Error "$_"
      }
    }
  }
```