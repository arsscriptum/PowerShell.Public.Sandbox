# Install-NuGetPackage

[NuGet](https://www.nuget.org/) is the package manager for .NET. The NuGet client tools provide the ability to produce and consume packages. The NuGet Gallery is the central package repository used by all package authors and consumers.

### Package Installation

Can be done using the following: 

1) NuGet client
2) .NET client
3) Packet Client
4) Cake

Unfortunately, they lack the flexibility required when using specific Dll assembiles with your PowerShell scripts.

### Examples

```
    # Create destination path...
    $InstallLocation = "$PSScriptRoot\lib"
    new-item -path $InstallLocation -ItemType 'Directory' -Force | Out-Null

    # Install PowerShell.Native
    Install-NuGetPackage 'Microsoft.PowerShell.Native' '7.3.2' "$InstallLocation"

    # Install HtmlAgilityPack
    Install-NuGetPackage 'HtmlAgilityPack' '1.11.48' "$InstallLocation"
```


[InstallNugetPackage on Github](https://github.com/arsscriptum/PowerShell.Public.Sandbox/tree/master/InstallNugetPackage)