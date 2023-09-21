<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



function Read-SelectPrinter{
    [CmdletBinding(SupportsShouldProcess)]
    param() 
    begin{
        # get valid printers
        $ValidPrinters = Get-ValidPrinters
    }
    process{
      try{
        Write-Host "Id`tPrinter Name" -f DarkYellow
        Write-Host "--`t------------`n" -f DarkGray
        $ValidPrinters | % {
            Write-Host "$($_.Id)`t$($_.Name)" -f DarkCyan
        }
        do{
          $SelectedId = (Read-Host -Prompt "Please enter Printer Id") -as [int32]
          $Ok = $ValidPrinters.Id.Contains($SelectedId)
        }while($Ok -eq $False)
        $SelectedId
      }catch{
        Write-Error "$_"
      }
    }
}



function Get-ValidPrinters{
    [CmdletBinding(SupportsShouldProcess)]
    param() 
    begin{
        # Portable CimInstance / WmiObject
        if($($PSVersionTable.PSEdition) -eq 'Core'){
            Write-Verbose "[Core] Get-CimInstance -> Get-WmiCimInstance"
            Write-Verbose "[Core] Invoke-CimMethod -> Invoke-WimCimMethod"
            New-Alias -Name "Get-WmiCimInstance" -Value 'Get-CimInstance' -Option AllScope -Force -ErrorAction Ignore
            New-Alias -Name "Invoke-WimCimMethod" -Value 'Invoke-CimMethod' -Option AllScope -Force -ErrorAction Ignore
        }else{
            Write-Verbose "[Desktop] Get-WmiObject -> Get-WmiCimInstance"
            Write-Verbose "[Desktop] Invoke-WmiMethod -> Invoke-WimCimMethod"
            New-Alias -Name "Get-WmiCimInstance" -Value 'Get-WmiObject' -Option AllScope -Force -ErrorAction Ignore
            New-Alias -Name "Invoke-WimCimMethod" -Value 'Invoke-WmiMethod' -Option AllScope -Force -ErrorAction Ignore
        }
    }   
    process{
      try{
        $Index = 0 
        $ValidPrinters = [System.Collections.ArrayList]::new()

        Get-WmiCimInstance -ClassName CIM_Printer | Select Name, SystemName | % {
          $name = $_.Name
          $system = $_.SystemName
          $id = $Index++
          $o = [PsCustomObject]@{
            Name = $name
            System = $system
            Id = $id
          }
          $Null=$ValidPrinters.Add($o)
        }
        $ValidPrinters
      }catch{
        Write-Error "$_"
      }
    }
}



function Test-IsValidPrinterName{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Name")]
        [string]$Name
    )    
    begin{
        # get valid printers
        $ValidPrinters = Get-ValidPrinters
    }
    process{
      try{
        if($($ValidPrinters.Count) -eq 0){ throw "no printers" }
        $Found = $ValidPrinters.Name.Contains($Name)
        $Found
      }catch{
        Write-Error "$_"
      }
    }
}


function Set-DefaultPrinterFromId{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Id")]
        [uint32]$Id
    )    
    begin{
        # Portable CimInstance / WmiObject
        if($($PSVersionTable.PSEdition) -eq 'Core'){
            Write-Verbose "[Core] Get-CimInstance -> Get-WmiCimInstance"
            Write-Verbose "[Core] Invoke-CimMethod -> Invoke-WimCimMethod"
            New-Alias -Name "Get-WmiCimInstance" -Value 'Get-CimInstance' -Option AllScope -Force -ErrorAction Ignore
            New-Alias -Name "Invoke-WimCimMethod" -Value 'Invoke-CimMethod' -Option AllScope -Force -ErrorAction Ignore
        }else{
            Write-Verbose "[Desktop] Get-WmiObject -> Get-WmiCimInstance"
            Write-Verbose "[Desktop] Invoke-WmiMethod -> Invoke-WimCimMethod"
            New-Alias -Name "Get-WmiCimInstance" -Value 'Get-WmiObject' -Option AllScope -Force -ErrorAction Ignore
            New-Alias -Name "Invoke-WimCimMethod" -Value 'Invoke-WmiMethod' -Option AllScope -Force -ErrorAction Ignore
        }
    }
    process{
      try{

        Write-Verbose "[Get-DefaultPrinterFromId] Id $Id"
        $SelectedPrinterName = Get-ValidPrinters | Where Id -eq $Id | Select -ExpandProperty Name
        Write-Verbose "[Get-DefaultPrinterFromId] SelectedPrinterName $SelectedPrinterName"
        if([string]::IsNullOrEmpty($SelectedPrinterName)){ throw "invalid printer"}
        # Using the name, create a filter
        $FilterString = "Name='{0}'" -f $SelectedPrinterName
        $PrinterPtr = Get-WmiCimInstance -Class Win32_Printer -Filter $FilterString
        if($PrinterPtr -eq $Null) { throw "cannot find printer handle for `"$SelectedPrinterName`"" }
        Write-Verbose "[Get-DefaultPrinterFromId] Invoke-WimCimMethod -MethodName SetDefaultPrinter "
        Invoke-WimCimMethod -InputObject $PrinterPtr -MethodName SetDefaultPrinter 

      }catch{
        Write-Error "$_"
      }
    }
}



function Test-PrinterCode{
    [CmdletBinding(SupportsShouldProcess)]
    param()    
    begin{
        # get valid printers
        $SelectedPrinter = Read-SelectPrinter
    }
    process{
      try{
        Write-Host "User select id `"$SelectedId`"" -f Red
        Set-DefaultPrinterFromId -Id $SelectedId
      }catch{
        Write-Error "$_"
      }
    }
}