# Using PowerShell Counters, without languages hardcoding

Performance Counters are named based on the Windows Language Version you have. But not the categories:

So to have the counter "\\Processor(\*)\% Processor Time", you can call ```(Get-Counter -ListSet Processor).Paths[0]```

Hence, replace this

```powershell
    $cpuTime = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
```

By this:

```powershell
    # Get Counter "\Processor(*)\% Processor Time"
    $cname = (Get-Counter -ListSet Processor).Paths[0]
    # Get Last Processor (total)
    $cpuTime = (Get-Counter $cname).CounterSamples.CookedValue | select -Last 1
```

and (memory)

```powershell
    $availMem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
```

To this

```powershell
    # Get Counter "\Memory\Available MBytes"
    $cname = (Get-Counter -ListSet Memory).Paths[28]
    $availMem = (Get-Counter $cname).CounterSamples.CookedValue
```

Example Functions


```powershell

	function Get-NumberOfLogicalProcessors {
	    [CmdletBinding(SupportsShouldProcess)]
	    param()
	    Write-Verbose "Get-NumberOfLogicalProcessors $($PSVersionTable.PSEdition)"
	    $NumProcessors = 0
	    try{
	        $NumProcessors = Get-Variable -Name 'NumberOfLogicalProcessors' -Scope Global -ValueOnly -ErrorAction stop
	        Write-Verbose "Get-Variable NumberOfLogicalProcessors SUCCESS $NumProcessors"
	    }catch{
	        Write-Verbose "Get-Variable NumberOfLogicalProcessors FAILED"
	        if($PSVersionTable.PSEdition -eq 'Core'){
	            $NumProcessors = (Get-CimInstance -ClassName 'Win32_Processor').NumberOfLogicalProcessors
	        }else{
	            $NumProcessors = (Get-WmiObject 'Win32_Processor').NumberOfLogicalProcessors
	        }
	        Write-Verbose "Set-Variable NumberOfLogicalProcessors $NumProcessors"
	        Set-Variable -Name 'NumberOfLogicalProcessors' -Scope Global -Option AllScope -Visibility Public -Force -Value $NumProcessors
	    }
	    $NumProcessors
	}


	function Get-AvailableMBytes {
	    $cname = (Get-Counter -ListSet Memory).Paths[28]
	    $availMem = (Get-Counter $cname).CounterSamples.CookedValue
	    return $availMem
	}


	function Get-CPUTime {
	    [CmdletBinding(SupportsShouldProcess)]
	    param(
	        [ValidateScript({
	        $n = Get-NumberOfLogicalProcessors
	        if($_ -gt $n){
	            throw "Id ($_) out of range (0-$n)"
	        }  
	        return $true 
	        })]
	        [Parameter(Mandatory=$false,Position=0)]
	        [uint32]$Id    
	    )
	    $cname = (Get-Counter -ListSet Processor).Paths[0]
	    if($PSBoundParameters.ContainsKey('Id')){
	        $cpuTime = (Get-Counter $cname).CounterSamples.CookedValue[$Id]
	    }else{
	        $cpuTime = (Get-Counter $cname).CounterSamples.CookedValue | select -Last 1
	    }
	    
	    return $cpuTime
	}

```
