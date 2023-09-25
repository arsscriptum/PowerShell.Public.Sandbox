<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


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



function Get-ExternalIpInformation{
    [CmdletBinding(SupportsShouldProcess)]
    param()
   try{
    $Data=(iwr 'http://ipinfo.io/json')
    if($Data.StatusCode -eq 200){
        Remove-Variable 'ExternalIpInformation' -ErrorAction ignore -Force
        $ExternalIpInformation = ($Data.Content | ConvertFrom-Json -AsHashtable)
        New-Variable -Name 'ExternalIpInformation' -Scope Global -Option ReadOnly,AllScope -Value $ExternalIpInformation -ErrorAction Ignore
        $ExternalIpInformation
    }
    }catch{
        Get-Variable -Name "ExternalIpInformation" -ValueOnly -Scope Global
    }
}




function Test-FirewallPort{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True, Position = 0)]
        [int]$Port,
        [Parameter(Mandatory=$false)]
        [ValidateSet('TCP','UDP','BOTH')]
        [string]$Protocol="TCP",
        [Parameter(Mandatory=$false)]
        [switch]$DumpHtml
    )

   try{
        Add-Type -AssemblyName System.Web  

        $Null = Register-HtmlAgilityPack 
        $TestTCP = 0
        $TestUDP = 0
        $NumScans = 0
        if(($Protocol -eq 'TCP') -Or ($Protocol -eq 'BOTH')){ $TestTCP = 1 ; $NumScans++ }
        if(($Protocol -eq 'UDP') -Or ($Protocol -eq 'BOTH')){ $TestUDP = 1 ; $NumScans++ }

        $Url = "https://www.speedguide.net/portscan.php?tcp={0}&udp={1}&port={2}" -f $TestTCP, $TestUDP, $Port 
    

        $Results = Invoke-WebRequest -Uri $Url -Method Get
        Write-Verbose "Loading URL `"$Url`" "

        $StatusCode = $Results.StatusCode 
        if(200 -ne $StatusCode){
            Write-Error "Request Failed"
            return
        }

        $HtmlContent = $Results.Content 

        if($DumpHtml){
            $CurrentDir = (Get-Location).Path 
            $FilePath = Join-Path $CurrentDir "firewall-test-$Port.html"
            Set-Content -Path "$FilePath" -Value "$HtmlContent" -Force
            Write-Verbose "Dumping Html data in `"$FilePath`" "
        }
        [HtmlAgilityPack.HtmlDocument]$doc = @{}
        $doc.LoadHtml($HtmlContent)
        
        [string]$StrBuffer = ''
        [string[]]$PortScanResultsText = [string[]]::new($NumScans+1)
        Write-Verbose "NumScans $NumScans"
        [System.Collections.ArrayList]$ScanResultsList = [System.Collections.ArrayList]::new()
        For($i = 0 ; $i -lt $NumScans ; $i++){
            $TableIndex = 4 + $i
            Write-Verbose "========================= RESULT SET $i ================================="
            Write-Verbose "SelectNodes $TableIndex"
            $ResultSet = $doc.DocumentNode.SelectNodes("/html[1]/body[1]/table[1]/tr[1]/td[2]/table[1]/tr[$TableIndex]")
            $ResultSetInnerText = $ResultSet.InnerText
            Write-Verbose "====================== InnerText`n$($ResultSetInnerText)`n======================"
            if($ResultSetInnerText -notmatch "$Port") {  
                throw "Scan Results not found in server reply." 
            }

            [string[]]$PortScanResultsText = [System.Web.HttpUtility]::HtmlDecode($ResultSetInnerText).Split("`n")
        
            $x = 0
            while([string]::IsNullOrEmpty($PortScanResultsText[$x++])){}

            $Max = $PortScanResultsText.Count - 1
            $PortNumber = $PortScanResultsText[$x].Trim().Split('/')[0]
            $Protocol = $PortScanResultsText[$x++].Trim().Split('/')[1]
            $PortStatus = $PortScanResultsText[$x++].Trim()
            $PortService = $PortScanResultsText[$x++].Trim()
            $Description = $PortScanResultsText[$x .. $Max].Trim()

            $ScanResultObject = [PsCustomObject]@{
                Port = $PortNumber
                Protocol = $Protocol
                Status = $PortStatus
                Service = $PortService
                Description = $Description
            }
            [void]$ScanResultsList.Add($ScanResultObject) 
        }

        $ScanDetailsObject = [PsCustomObject]@{}
        
        For($i = 0 ; $i -lt 4 ; $i++){
            $TableIndex = 4 + $NumScans + $i
            $ResultSet = $doc.DocumentNode.SelectNodes("/html[1]/body[1]/table[1]/tr[1]/td[2]/table[1]/tr[$TableIndex]").InnerText
            $ScanDetails = $ResultSet.Split(':')
            [string]$StatName = $ScanDetails[0].Replace(' ','_').Trim() -as [string]
            [int32]$StatValue = $ScanDetails[1].Trim() -as [int32]
                
            $ScanDetailsObject | Add-Member -MemberType NoteProperty -Name "$StatName" -Value $StatValue -Force
        }

        $ScanDetailsObject | Add-Member -MemberType NoteProperty -Name "Ports" -Value $ScanResultsList -Force

        return $ScanDetailsObject
    }catch{
        Write-Error "$_"
    }
}




function RunTest{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $info = Get-ExternalIpInformation
    $external_ip = $info.ip 

    Write-Host "External Ip is $external_ip"

    Write-Host "Testing Port 80..."
    Test-FirewallPort -Port 80 -Protocol TCP

    Start-Sleep 5  # Server limits request rate

    Write-Host "Testing Port 1194, TCP and UDP..."
    Test-FirewallPort -Port 1194 -Protocol BOTH 

    Start-Sleep 5  # Server limits request rate

    Write-Host "Testing Port 64 UDP"
    Test-FirewallPort -Port 64 -Protocol UDP
}
