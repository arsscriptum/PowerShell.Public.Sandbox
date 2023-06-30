
$command = @"

    `$Title = `"ERROR EVENT`"
    `$Message = `"no message`"

    if([string]::IsNullOrEmpty(`$ENV:MsgBoxMessage) -eq `$False){
        `$Message = `$ENV:MsgBoxMessage
    }
    if([string]::IsNullOrEmpty(`$ENV:MsgBoxTitle) -eq `$False){
        `$Title = `$ENV:MsgBoxTitle
    }
    `$WindowsAssemblyReferences = @()
    `$WindowsAssemblyReferences += 'PresentationFramework'
    `$WindowsAssemblyReferences += 'PresentationCore'
    `$WindowsAssemblyReferences += 'WindowsBase'
    `$WindowsAssemblyReferences += 'System.Windows.Forms'
    `$WindowsAssemblyReferences += 'System.Drawing'
    `$WindowsAssemblyReferences += 'System' 
    `$WindowsAssemblyReferences += 'System.Xml' 
    Foreach (`$Ref in `$WindowsAssemblyReferences) {
        Try {
            Add-Type -AssemblyName `$Ref
        }  
        Catch {}
    }
    `$Script = `"C:\DOCUMENTS\PowerShell\Module-Development\PowerShell.Module.Core\src\MessageBox.ps1`"
    . `"`$Script`"
    Show-MessageBoxError -Text `"`$Message`"
"@


 $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
$encodedCommand = [Convert]::ToBase64String($bytes)
$cmd = "powershell.exe -noni -nop -encodedCommand `"$encodedCommand`""
$batch_code = @"
@echo off
set MsgBoxMessage=%*
$cmd
"@

Set-Content -Path "$PSScriptRoot\mbox_error.bat" -Value $batch_code


$command = @"

    `$Title = `"INFORMATION EVENT`"
    `$Message = `"no message`"

    if([string]::IsNullOrEmpty(`$ENV:MsgBoxMessage) -eq `$False){
        `$Message = `$ENV:MsgBoxMessage
    }
    if([string]::IsNullOrEmpty(`$ENV:MsgBoxTitle) -eq `$False){
        `$Title = `$ENV:MsgBoxTitle
    }
    `$WindowsAssemblyReferences = @()
    `$WindowsAssemblyReferences += 'PresentationFramework'
    `$WindowsAssemblyReferences += 'PresentationCore'
    `$WindowsAssemblyReferences += 'WindowsBase'
    `$WindowsAssemblyReferences += 'System.Windows.Forms'
    `$WindowsAssemblyReferences += 'System.Drawing'
    `$WindowsAssemblyReferences += 'System' 
    `$WindowsAssemblyReferences += 'System.Xml' 
    Foreach (`$Ref in `$WindowsAssemblyReferences) {
        Try {
            Add-Type -AssemblyName `$Ref
        }  
        Catch {}
    }
    `$Script = `"C:\DOCUMENTS\PowerShell\Module-Development\PowerShell.Module.Core\src\MessageBox.ps1`"
    . `"`$Script`"
    Show-MessageBoxInfo -Text `"`$Message`" -Title `"`$Title`"
"@

$bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
$encodedCommand = [Convert]::ToBase64String($bytes)
$cmd = "powershell.exe -noni -nop -encodedCommand `"$encodedCommand`""



$batch_code = @"
@echo off
set MsgBoxMessage=%*
$cmd
"@



Set-Content -Path "$PSScriptRoot\mbox_information.bat" -Value $batch_code