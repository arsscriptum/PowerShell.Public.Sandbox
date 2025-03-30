


[CmdletBinding(SupportsShouldProcess)]
param()


function Register-HtmlAgilityPack{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$False)]
        [string]$Path
    )
    begin{
        if([string]::IsNullOrEmpty($Path)){
            $Path = "{0}\lib\{1}\HtmlAgilityPack.dll" -f "$PSScriptRoot", "$($PSVersionTable.PSEdition)"
        }
    }
    process{
      try{
        if(-not(Test-Path -Path "$Path" -PathType Leaf)){ throw "no such file `"$Path`"" }
        if (!("HtmlAgilityPack.HtmlDocument" -as [type])) {
            Write-Verbose "Registering HtmlAgilityPack... " 
            add-type -Path "$Path"
        }else{
            Write-Verbose "HtmlAgilityPack already registered " 
        }
      }catch{
        throw $_
      }
    }
}


function Get-Vpnconfig{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [int]$Page = 1
    )

    try{

        Add-Type -AssemblyName System.Web  

        $Null = Register-HtmlAgilityPack 

        $Ret = $False
        $HtmlContent = Get-Content -Path "$PSScriptRoot\source.html" -Raw


        [HtmlAgilityPack.HtmlDocument]$HtmlDoc = @{}
        $HtmlDoc.LoadHtml($HtmlContent)
        
        $HtmlNode = $HtmlDoc.DocumentNode
        [System.Collections.ArrayList]$List = [System.Collections.ArrayList]::new()
        $HashTable = @{}
        For($i=1;$i -lt 20;$i++){
            $XNodeAddr = "/html/body/div[1]/div/div[1]/div[2]/div[1]/div[2]/div/div[17]/div[4]/div/ol/div[2]/div[1]/div[{0}]/ul/li[{1}]/a" -f $Page,$i
            try{
                $ResultNode = $HtmlNode.SelectNodes($XNodeAddr)
                [string]$htmlString = $ResultNode.OuterHtml
                [string]$Name = $ResultNode.InnerHtml
                # Regex patterns
                $clusterIdPattern = 'cluster_id=(\d+)'
                $cityPattern = '>([^<]+)<'

                # Extract cluster_id
                if ($htmlString -match $clusterIdPattern) {
                    $clusterId = $matches[1]
                } else {
                    $clusterId = "Not Found"
                }

                # Extract city name
                if ($htmlString -match $cityPattern) {
                    $cityName = $matches[1]
                } else {
                    $cityName = "Not Found"
                }

                if("$cityName" -ne "Not Found"){
                    $filename = $cityName.Replace(' ', '_')

                    $HashTable.Add("$clusterId", "$cityName")
                    [PsCustomObject]$o = [PsCustomObject]@{
                        Name = "$cityName"
                        File = "$filename"
                        ClusterId = $clusterId
                    }
                    [void]$List.Add($o)
                }
                

            }catch{
                break;
            }

        }

        return $List
        
    }catch{
        Write-Verbose "$_"
        Write-Host "Error Occured. Probably Invalid Page Id" -f DarkRed
    }
    return $Null
}






function Get-AllVpnconfig{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $AllVpnconfig = Get-Vpnconfig 1
    $AllVpnconfig += Get-Vpnconfig 2
    $AllVpnconfig += Get-Vpnconfig 3
    $AllVpnconfig += Get-Vpnconfig 4
    $AllVpnconfig += Get-Vpnconfig 5



    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36"
    $session.Cookies.Add((New-Object System.Net.Cookie("xvid", "Sec5diwc9IcVABFx199PB_RBcfZyDBGW_CUFJ_UOeMLTyl9VrjUy_w%3D%3D", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("landing_page", "https://www.expressvpn.com/", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("locale", "", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("xvsrcorganic", "duckduckgo", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("media_source", "organic", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("xv_lp", "homepage", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("xv_campaign", "default_campaign", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("rl_page_init_referrer", "RudderEncrypt%3AU2FsdGVkX18YZhakuEYEx2jCLLk3PYXNRFlYas45z0KHlchqo91T%2Bc%2Ftc%2BXv%2Flj5", "/", ".expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("rl_page_init_referring_domain", "RudderEncrypt%3AU2FsdGVkX1%2FzCQeTL9eeCUBxg4YlwUYA5g8oVUcGoRfVtdzs5mKfxoPdTGgsLWxP", "/", ".expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("page_type", "Legacy", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("u_krn", "krn%3A%3Aiam%3A%3Axvpn%3Auser%3A39bd3685-d09c-4346-91b4-af1536b58ec1", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("s_krn", "krn%3A%3Apayments%3A%3Axvpn%3Asub%3A82c6c8d8-100b-4863-9aaf-cab706b259ee", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("xv3v2ksky", "49kBYtcUPv9XNnFpAAAAAFTn4AUAAAAApHwEB_1E0zrcKlBUd7c-Y9_WIkxMJN-Rqfw9MO25hjn0HVxhWJiKyIXjWpXh0AbQn9ehcamRlmZswfdKCPa8ah0F9mCMXo6DehBQ6dUoMi3lTGgog5PjRzAqfHk0PwxqRL5yYqH-n1_NbN3caBlEODXlGoQ-wkU6fsOm_S3bft6WstmZOXWRUmH_hiVbfICIEjVuQ8K5BmOSblBX9o54K7E6_UjtsFEC3AeW9WRvoieHPn9GcWfOXZoW7PIzz5ioBBBMIH3DjEA8XOTzb2qfMhNWFXvmY9j71cMgFvtfZyp9x0bIxDMH2rFC6zjGBMo1tdCtTixOkAO4eoS9FPFmeg%3D%3D", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("xvu95kprm", "d21Bc2grc051S0QxU0RBVXN0em1nNDZsSjl3MDQxRWJLQkEyOE93bzJQQnRKZGhZemlZcUZIeC94QVJsc2IzYUhxS2NkOU5yakJOdU5KQlMyL0MwNEJwVTRBYmt4UG9GbWFycjUzaUZyVlc4cWxteGI3clJuT0twWmFhczJiRXVSVTkwSkpDRmw0eXRVcC9QTzFFeTdONlplSHNNTmJkamxxT2xaT0VoVWMxcHF5SlVDTkxxWTBkbG5ZQVd2VEd4QXBGL3c3SHdzV0dGUHVNUzc4em1TU28vVWpocW13ckw3T0V2bVZBWnZya1hWVlZkV2Y1Uk5Ra3d3TGZlRU1kSUp4R0R0VmpOWUsxZVF1OWxmOUpkQUE4SC9LRUJyZXhVN2d4MGNUOStZSGlrcWVIMkx1ZzllRkNlY2RQcy9OZ1hJcFV3Um1UREY2RHUwQnZRcFNaYTFJV1JrVTYyNmVkZUNYb25kSlh0T2E5ZU9jY2wzdE1pQkFrcTNVQXJIV0M3MjRkemRacVlkMUVuODc0ek1pRnhieG5mQXNkTDBoNmYxUWFVb2FJQll4WDJIQUhyWEhVTkN4S1o3Z0lBUldlWDQwQ3NQYVlkMHlyMERZZWQvMFVWcm9aa3hSUHBxMUU4Z2llYUhEOWVMMGc9LS1DSXZSaFZhQjdoZTVpeE0wUThxVzV3PT0%3D--b947ab5b613fe515e35591757fc37580f6d46238", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("xvsrcwebsite", "www.expressvpn.com", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("webe_179", "vpn-download", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("kexn", "a%2Fa_test", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("kvarn", "control", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("wp-wpml_current_language", "en", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("_ga", "GA1.2.1053720154.1737491232", "/", ".expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("_gid", "GA1.2.1247147230.1737491232", "/", ".expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("xvsrcdirect", "1", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("utm", "%7B%22utm_campaign%22%3A%22txn_all_en_sign-in-link-web-Variant+1%22%2C%22utm_medium%22%3A%22email%22%2C%22utm_source%22%3A%22EDM%22%2C%22utm_content%22%3A%22sign-in%22%2C%22utm_term%22%3Anull%7D", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("xv_ue", "1", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("xvnv389t", "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjEifQ.eyJzdWIiOjk4NjI1MzY0LCJhdWQiOiJodHRwczovL2FwaXMuZXhwcmVzc3Zwbi5jb20vIiwiaXNzIjoiaHR0cHM6Ly9hcGktdjItandrcy5pbnRlZ3JhdGlvbi5leHByZXNzdnBuLmNvbS8iLCJleHAiOjE3Mzc1NzgyNzcsImlhdCI6MTczNzQ5MTg3Nywic2NvcGUiOltdLCJrcF91c2VyIjoia3JuOjppYW06Onh2cG46dXNlcjozOWJkMzY4NS1kMDljLTQzNDYtOTFiNC1hZjE1MzZiNThlYzEiLCJzdWJfa3JuIjoia3JuOjpwYXltZW50czo6eHZwbjpzdWI6ODJjNmM4ZDgtMTAwYi00ODYzLTlhYWYtY2FiNzA2YjI1OWVlIn0.n9lwGmhz94YdKyeZuJ_iMV8eHDoo0Omm8pniH9BEFtA7SG0L2YY2pYLYucY9Yq-Q3-5WpGgioVTUgSRjt65DGyopc6WYspzeV7TjfSc3Iwv9DzTPvKZs5c6OQCMK60WEQOvvlfkm3hs3Z6s4Kqp2Zoia26aOpUxwUnwZi_61P777Py4L0dfzF9nL7n1_dxdVwwXIeaGTiyQqh9Pmp_n-O0jFztMSSyNCWeem4iqX6E9U7ftPTOGJI-MFCf7MswXt9SuI9xMfLZHX4C43z5yI_MFAslEArd5omds4a1oI4QjaNjQgcgZNiGed1arO8wrE6JoCmNZp7Io11NGk2dHTBA", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("rl_user_id", "RudderEncrypt%3AU2FsdGVkX19yejcy6h2osdkOHx%2FZquUJOcvxXMOSuYQ%3D", "/", ".expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("rl_trait", "RudderEncrypt%3AU2FsdGVkX18SjBUz%2FEmFX3ElfaVsVMKjtfmIYLpzKA4%3D", "/", ".expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("rl_group_id", "RudderEncrypt%3AU2FsdGVkX18gI1PuzQhMXNu36ZpHoqffQ6GTWUxSXOQ%3D", "/", ".expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("rl_group_trait", "RudderEncrypt%3AU2FsdGVkX18fVJ6abPjGf%2BAVCLJ6GHDZovDEzVV8U5o%3D", "/", ".expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("rl_anonymous_id", "RudderEncrypt%3AU2FsdGVkX1%2BJENiyPX%2F4uikaJIYCCJoNXmevrFujEoUk09O6vTvNaQ5v%2FdyaFRd2YuyhgtQH3zawhd4CkSXuZQ%3D%3D", "/", ".expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("rl_session", "RudderEncrypt%3AU2FsdGVkX1%2FTfKGWr%2BkM%2B7BJGsmikziAmNknJJPaGcfbL4a716DXCuzWXYf%2BFUiT03Ju0FD%2FhNWAFUNE2Z2onP3QgjlLE0eHEB5T2e2MXyJEtW88qXR7%2BrjupkzeJpP1du2QBav8H%2B4CEyOFsfruVQ%3D%3D", "/", ".expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("xvgtm", "%7B%22logged_in%22%3Atrue%2C%22location%22%3A%22CA%22%2C%22report_aid_to_ga%22%3Afalse%7D", "/", "www.expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("mp_ZXhwcmVzc3Zwbg", "=_alooma=%7B%22distinct_id%22%3A%20%221948a882cad9b-01c44a2efa9df9-26011b51-43bb6a-1948a882cae185%22%2C%22%24search_engine%22%3A%20%22duckduckgo%22%2C%22%24initial_referrer%22%3A%20%22https%3A%2F%2Fduckduckgo.com%2F%22%2C%22%24initial_referring_domain%22%3A%20%22duckduckgo.com%22%7D", "/", ".expressvpn.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("_xv_web_frontend_session", "OTNodHl5YUplV3V3bCtFUE5lMlBWaE1hV2RXdUwwVitkUXltVk4rajIzNyt0ZTgvSlYxaExaeVExMGovd1RQOUdoVzg0VkwyeStZOVJZRkF5by94NDdNZEc4bTVIUVdyRHVYeFBIVC9nR3c0L0FPYVVxdDZ0Q2VSWWlqRXpqTVJkNUc1UDlwVDljeER1bmRRNDUxeWgrVEZlSzdveFkrWFBDUjNEWDRzQmNObUlVSjY5VTgwVTlYS0NHaURGVUttbGVNNUtaVkVJZXVyclY3dSsxeUdkOEEzNUJWeWx4YVhua0pJZUQ0U0tJdjY1bXExNHpCYkJybUNPNWdjQ3duYUp3c1FhQllxWnAzd1ZBMjZKdlJxUGp6Vk51b3oyODZNdUxmeVNuRWRqeUY5WmlHNit1OERVcUlEWWxkV1hPNy8yejZRK200M0EvL0hoK05OM2krdEJ5b1VqdDduU0l3ZUlkYXhkTHhQS0YyZFhhQ0x3VFNGdkVKSCtYUk1sZVpBd2hRU3RNZ0g2UjlybloxYm5sR1hWeFZCOWJQYTg2QjZMUXA1SGxMWnp3bmJHRHVxKzM1eHlKTTFwSnBsTkRDRVovdXpXNWtJZUJZUHlTYk9NR0FhRXphZVJUUVhXd3lLMFlsSUtMYTFWYUtwYzVQSVo0eG4xYzNWQXE0Y0k5aXdqc1RvM29jWDhUMXFXL1QvZTRlcEkyL05BdE82Vkh6TGRkNG9IQVJibGlNc0hQS3hCVEFQSUhGVjFyVFhxUG1hakVkNm45UXQxSjVxMVlHc2lLL1JOczJRRUZYTlAvZnU3TWJBRDF3YTExU1hOcVNOV0ViV0Mrcmx2NlE3VGJkZzkralE0T3k3Ym9zdVJvSXhzOHNVVjRqWVVtaFJtKy8ydi8wT0VVUWhkakI2TzBvMm5vT2Iwd1I5SXBsYjY2OHJuMm1Cc3B1aE4yQWg4a3pkc1R6MExKaVVlR0xZZWRKUEg3ZXE2YWdMWnJqK3dPUHMzeHlxTWZxUW94RUpFdy8xNUdwWkkxQkpDTHNXbndMSzVEekJpKzkrbVFYWllxYzFtM1B1eGhHbHZyY3VQKzNZWnIxaW9hYnJ2dzNGYjZOMzlSZG1JbnJVU2dpYUJGS0hYRk5yWUE9PS0tWEw2MkpQQzlpTEZkZkFYeldXUEJPZz09--99d885af75ac916ee642593dc9be6c9dc738d4d1", "/", "www.expressvpn.com")))


    $headerz = @{
      "authority"="www.expressvpn.com"
      "method"="GET"
      "path"="/custom_installer?cluster_id=248&code=eyJhbGciOiJSU0EtT0FFUCIsImVuYyI6IkExMjhHQ00ifQ.ss-LKKJTchJT86DBZb7oyS6cjT-eGlgQAvSE3q5cDK-5wGSjkYZKDni9ChW3nvehxQcXCS1IsfCzn6iFGSWKsPbWRP1Z_6ZR85hkJh-VnH8vMfyA1SVt4fRTtsiPSDC1Ij9q7zpAosnEX_JsK1S-RXMpvmNoUIjB1Kedlm5frVxjEc35Sz4YKZE9N0KwIM7lDYsXu9rlPfRFicfSlx_ExEjTtxQih1GZuFwu83SFSw17XkgSE7gDFNT42j6Bst1RjBm2A-Y4gZzqu-51b0DFzUTDQId0LBZkcE-1FfomTxg32Ol3xOj5zj9I_mmTKO_8tBSrt1xOcppzmqZ_N1ux0g.8ky0aMFKeNUn7OFM.JsMrnoGPmUpAf8ICmERNyUMEnf1dfNKYYMZ8dJrhXNEEUY5Dz_2nxw5LJYHG2JFiJgOCiiTIdEtaZFEsPRkLV2uDQFf_FlE2Xrh3a7pvhw7Dzq4F0uu0sQaf4DJD9yRY89T2489-wJtNElyQnneEsZbTBpG0mtbxQA0iRgnP76_omyqisIuVTlcqyAq9xzlkWwqERA.V5OpUDlbOS7jP5a5ebHRQA&os=linux&source=web"
      "scheme"="https"
      "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8"
      "accept-encoding"="gzip, deflate, br, zstd"
      "accept-language"="en-US,en;q=0.9"
      "cache-control"="no-cache"
      "pragma"="no-cache"
      "priority"="u=0, i"
      "referer"="https://www.expressvpn.com/setup"
      "sec-ch-ua"="`"Not A(Brand`";v=`"8`", `"Chromium`";v=`"132`", `"Brave`";v=`"132`""
      "sec-ch-ua-mobile"="?0"
      "sec-ch-ua-platform"="`"Windows`""
      "sec-fetch-dest"="document"
      "sec-fetch-mode"="navigate"
      "sec-fetch-site"="same-origin"
      "sec-fetch-user"="?1"
      "sec-gpc"="1"
      "upgrade-insecure-requests"="1"
    }

    $Source = "web"
    $Os = "linux"
    $ClusterId = 248
    $Code = "eyJhbGciOiJSU0EtT0FFUCIsImVuYyI6IkExMjhHQ00ifQ.ss-LKKJTchJT86DBZb7oyS6cjT-eGlgQAvSE3q5cDK-5wGSjkYZKDni9ChW3nvehxQcXCS1IsfCzn6iFGSWKsPbWRP1Z_6ZR85hkJh-VnH8vMfyA1SVt4fRTtsiPSDC1Ij9q7zpAosnEX_JsK1S-RXMpvmNoUIjB1Kedlm5frVxjEc35Sz4YKZE9N0KwIM7lDYsXu9rlPfRFicfSlx_ExEjTtxQih1GZuFwu83SFSw17XkgSE7gDFNT42j6Bst1RjBm2A-Y4gZzqu-51b0DFzUTDQId0LBZkcE-1FfomTxg32Ol3xOj5zj9I_mmTKO_8tBSrt1xOcppzmqZ_N1ux0g.8ky0aMFKeNUn7OFM.JsMrnoGPmUpAf8ICmERNyUMEnf1dfNKYYMZ8dJrhXNEEUY5Dz_2nxw5LJYHG2JFiJgOCiiTIdEtaZFEsPRkLV2uDQFf_FlE2Xrh3a7pvhw7Dzq4F0uu0sQaf4DJD9yRY89T2489-wJtNElyQnneEsZbTBpG0mtbxQA0iRgnP76_omyqisIuVTlcqyAq9xzlkWwqERA.V5OpUDlbOS7jP5a5ebHRQA"
    

    $CurrentPath = (Resolve-Path -Path "$PSScriptRoot").Path
    $SavePath = Join-Path $CurrentPath "Configs"

    New-Item -Path $SavePath -ItemType Directory -Force -ErrorAction Ignore | Out-Null 


    ForEach($cfg in $AllVpnconfig){
        $CityName = $cfg.Name
        $Id = $cfg.ClusterId
        $FilePath = Join-Path $SavePath $cfg.File
        $FilePath = $FilePath + '.ovpn'
        Write-host "Downloading VPN Config $CityName,  cluster id $Id to `"$FilePath`"" -f DarkCyan
        $Url = "https://www.expressvpn.com/custom_installer?cluster_id={0}&code={1}&os={2}&source={3}" -f $Id, $Code, $Os, $Source
        Invoke-WebRequest -UseBasicParsing -Uri $Url -WebSession $session -Headers $headerz -OutFile "$FilePath"
    }

    

}
    

Get-AllVpnconfig