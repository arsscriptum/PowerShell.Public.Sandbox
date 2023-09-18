

function Invoke-BackupPathValues{     
    [CmdletBinding(SupportsShouldProcess)]
    param()

   try{
        $UserPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::User)
        $MachinePath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
     
        Set-EnvironmentVariable -Name "BACKUP_PATH_USER" -Value "$UserPath" -Scope User
        Set-EnvironmentVariable -Name "BACKUP_PATH_MACHINE" -Value "$MachinePath" -Scope User
        New-Item -Path "C:\Backup\BACKUP_PATH_USER.txt" -ItemType File -Force -ErrorAction Ignore

        Set-Content "C:\Backup\BACKUP_PATH_USER.txt" -Value "$UserPath"
        Set-Content "C:\Backup\BACKUP_PATH_MACHINE.txt" -Value "$MachinePath"
    }catch{
        Show-ExceptionDetails $_
    }
    return $Null
}

function Invoke-ResetPathValues{   
    [CmdletBinding(SupportsShouldProcess)]
    param()

   try{
        $IsAdmin =  Invoke-IsAdministrator
        if($IsAdmin -eq $False){ throw "MUST BE ADMIN TO CONFIRM"}
        $UserValues = Get-Content "C:\Backup\BACKUP_PATH_USER.txt" 
        $MachineValues = Get-Content "C:\Backup\BACKUP_PATH_MACHINE.txt" 
        Set-EnvironmentVariable -Name "BACKUP_PATH_USER" -Value "$UserValues" -Scope User
        Set-EnvironmentVariable -Name "BACKUP_PATH_MACHINE" -Value "$MachineValues" -Scope Machine
    }catch{
        Show-ExceptionDetails $_
    }
    return $Null
}


function Invoke-CleanUpPathValues{   
    [CmdletBinding(SupportsShouldProcess)]
    param(   
        [Parameter(Mandatory=$false)]
        [switch]$Commit          
    )

   try{
        $ConfirmNewValues = $False
        ###
        # Must be ADINISTRATOR for the function to confirm the actually set the
        # cleaned up values in the User and Machine path. NOTE THAT you can (and should)
        # test the function as a regular user first to review the logs and confrm the new values
        # are OK with you.
        if($Commit){
            $IsAdmin =  Invoke-IsAdministrator
            if($IsAdmin -eq $False){ 

                Write-Host "============================================================" -f DarkYellow
                Write-Host "IMPORTANT: This function requires Administrator Privileges  " -f DarkRed
                Write-Host "     in order to confirm the fnal values in the system.     " -f DarkRed
                Write-Host "  It is recommended to test and validate values though logs " -f Magenta
                Write-Host "                 as a regular user first though             " -f Magenta
                Write-Host "============================================================`n" -f DarkYellow
                Write-Host "Do you want to continue, only to test, without confirming values ? " -f DarkYellow
                $a = Read-Host "==> ? (yes/No)"
                Invoke-SendDelayedKeys "No"
                if($($a.ToUpper()) -ne 'YES') { return ; }
               
            }else {
                $ConfirmNewValues = $True
            }
        }

        ###
        # Get the PATH Environment Variables for both the USER and MACHINE SCOPES
        $UserPathEnvironmentVariable = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::User)
        $MachinePathEnvironmentVariable = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)

       
        Write-Host "PATH VALUES in" -f DarkGray -n 
        Write-Host " MACHINE SCOPE" -f DarkRed
        Write-Host "----------------------------" -f DarkGray

        $MachinePathValues = $MachinePathEnvironmentVariable.Split(';')
        $MachinePathValuesCount = $MachinePathValues.Count
        Write-Host "[INFO] " -f DarkBlue -n
        Write-Host "Machine Path Values Before cleanup: $MachinePathValuesCount" -f Gray

        # Array containing the final path values for the machine scope
        $NewPathValues_MachineScope = @()

        # temporary array to hold some path values tthat will need to be transfered from machine scope to user scope
        $NewPathValues_TemporaryArray = @()

        # Loop in the path values
        $MachinePathValues | % {
            $NewValue = $_

            # Remove the '\' at the end of the value 
            $NewValue = $NewValue.Trim('\')

            # If the value is a Users directory, it needs to be transfered to the User Scope 
            if($NewValue.Contains('Users\') -eq $True){
                Write-Host "[WARN] " -f DarkRed -n
                Write-Host "Value in MACHINE PATH Contains USER PATH `"$NewValue`"" -f DarkYellow
                $NewPathValues_TemporaryArray += $NewValue
            }else{
                $NewPathValues_MachineScope += $NewValue
            }
        }
        #######################################
        # Sort the values and remove duplicates
        $NewPathValues_MachineScope = $NewPathValues_MachineScope  | Select -Unique | Sort -Descending


        $NewPathValues_MachineScopeCount = $NewPathValues_MachineScope.Count
        Write-Host "Machine Path Values AFTER cleanup: $NewPathValues_MachineScopeCount`n" -f Red

        Write-Host "PATH VALUES in" -f DarkGray -n 
        Write-Host " USER SCOPE" -f DarkGreen
        Write-Host "----------------------------" -f DarkGray

        $UserPathValues = $UserPathEnvironmentVariable.Split(';')
        $UserPathValuesCount = $UserPathValues.Count
        Write-Host "[INFO] " -f DarkBlue -n
        Write-Host "User Scope Path Values Before cleanup : $UserPathValuesCount" -f Gray


        $NewPathValues_TemporaryArray | % {
            [string]$NewValue = $_
            $UserPathValues += $NewValue
            Write-Host "[INFO] " -f DarkBlue -n
            Write-Host "adding machine value that has user path : `"$NewValue`"" -f DarkMagenta
        }
        $UserPathValuesCount = $UserPathValues.Count
        Write-Host "[INFO] " -f DarkBlue -n
        Write-Host "Modified USER Path Values Count : $UserPathValuesCount" -f Magenta
        $NewPathValues_UserScope = @()
        $UserPathValues | % {
            $NewValue = $_
            $NewValue = $NewValue.Trim('\').Trim()  # remove unwanted characters

            # Make sure the path values in USER are not already in he MACHINE Scope array
            if($NewPathValues_MachineScope.Contains($NewValue) -eq $False){
                if($False -eq [string]::IsNullOrEmpty($NewValue)){ $NewPathValues_UserScope += $NewValue } 
            }else{
                Write-Host "[DUPLICATE] " -f DarkRed -n
                Write-Host "Value Already in MACHINE PATH: `"$NewValue`"" -f DarkYellow
            }
            
        }
        #######################################
        # Sort the values and remove duplicates
        $NewPathValues_UserScope = $NewPathValues_UserScope | Select -Unique | Sort -Descending
        $NewPathValues_UserScopeCount = $NewPathValues_UserScope.Count
        Write-Host "[INFO] " -f DarkBlue -n
        Write-Host "User Scope Path Values AFTER cleanup : $NewPathValues_UserScopeCount" -f RED
        $NewPathValues_UserScope 

        $NewUserPathValues = ''
        $NewPathValues_UserScope | % {
             $Value = $_
             $NewUserPathValues += "$Value;"
         }

        $NewMachinePathValues = ''
        $NewPathValues_MachineScope | % {
             $Value = $_
             $NewMachinePathValues += "$Value;"
         }

         $NewUserPathValues = $NewUserPathValues.Trim(';')
         $NewMachinePathValues = $NewMachinePathValues.Trim(';')

         Write-Host "================================================================" -f DarkGray
         Write-Host "MACHINE PATH VALUES ($($NewMachinePathValues.Length) chars)" -f Yellow
         Write-Host "---------------------------------------------------------------" -f DarkGray
         Write-Host "$NewMachinePathValues" -f Cyan
         Write-Host "================================================================`n" -f DarkGray

         Write-Host "`n================================================================" -f DarkGray
         Write-Host "USER PATH VALUES ($($NewUserPathValues.Length) chars)" -f Yellow
         Write-Host "---------------------------------------------------------------" -f DarkGray
         Write-Host "$NewUserPathValues" -f Cyan
         Write-Host "================================================================" -f DarkGray

         if($ConfirmNewValues){
            Set-EnvironmentVariable -Name "Path" -Value "$NewUserPathValues" -Scope User
            Set-EnvironmentVariable -Name "Path" -Value "$NewMachinePathValues" -Scope Machine
        }
    }catch{
        Show-ExceptionDetails $_
    }
    return $Null
}


function Invoke-ChangePathProgramsDrive{   
    [CmdletBinding(SupportsShouldProcess)]
    param(   
        [Parameter(Mandatory=$false)]
        [char]$NewDrive='E',  
        [Parameter(Mandatory=$false)]
        [switch]$Commit          
    )

   try{
        $ConfirmNewValues = $False
        ###
        # Must be ADINISTRATOR for the function to confirm the actually set the
        # cleaned up values in the User and Machine path. NOTE THAT you can (and should)
        # test the function as a regular user first to review the logs and confrm the new values
        # are OK with you.
        if($Commit){
            $IsAdmin =  Invoke-IsAdministrator
            if($IsAdmin -eq $False){ 

                Write-Host "============================================================" -f DarkYellow
                Write-Host "IMPORTANT: This function requires Administrator Privileges  " -f DarkRed
                Write-Host "     in order to confirm the fnal values in the system.     " -f DarkRed
                Write-Host "  It is recommended to test and validate values though logs " -f Magenta
                Write-Host "                 as a regular user first though             " -f Magenta
                Write-Host "============================================================`n" -f DarkYellow
                Write-Host "Do you want to continue, only to test, without confirming values ? " -f DarkYellow
                $a = Read-Host "==> ? (yes/No)"
                Invoke-SendDelayedKeys "No"
                if($($a.ToUpper()) -ne 'YES') { return ; }
                
            }else{
                $ConfirmNewValues = $True
            }
        }

        ###
        # Get the PATH Environment Variables for both the USER and MACHINE SCOPES
        $UserPathEnvironmentVariable = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::User)
        $MachinePathEnvironmentVariable = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)

       
        Write-Host "PATH VALUES in" -f DarkGray -n 
        Write-Host " MACHINE SCOPE" -f DarkRed
        Write-Host "----------------------------" -f DarkGray

        $MachinePathValues = $MachinePathEnvironmentVariable.Split(';')
        $MachinePathValuesCount = $MachinePathValues.Count
        Write-Host "[INFO] " -f DarkBlue -n
        Write-Host "Machine Path Values Before drive switch: $MachinePathValuesCount" -f Gray

        # Array containing the final path values for the machine scope
        $NewPathValues_MachineScope = @()

        # Loop in the path values
        $MachinePathValues | % {
            $TmpValue = $_
            $NewValue = $_
            # Remove the '\' at the end of the value 
            $TmpValue = $TmpValue.ToUpper()

            # If the value is a Users directory, it needs to be transfered to the User Scope 
            if($TmpValue.Contains('C:\PROGRAMS\') -eq $True){
                Write-Host "[WARN] " -f DarkRed -n
                Write-Host "Found Programs value to be changed `"$NewValue`"" -f DarkYellow
                $NewValue = "{0}{1}" -f $NewDrive, ($NewValue.Substring(1,$NewValue.Length-1))
                $NewPathValues_MachineScope += $NewValue
            }else{
                $NewPathValues_MachineScope += $NewValue
            }
        }
        #######################################
        # Sort the values and remove duplicates
        $NewPathValues_MachineScope = $NewPathValues_MachineScope  | Select -Unique | Sort -Descending


        $NewPathValues_MachineScopeCount = $NewPathValues_MachineScope.Count
        Write-Host "[INFO] " -f DarkBlue -n
        Write-Host "Machine Path Values AFTER drive switch: $NewPathValues_MachineScopeCount`n" -f Gray

        Write-Host "PATH VALUES in" -f DarkGray -n 
        Write-Host " USER SCOPE" -f DarkGreen
        Write-Host "----------------------------" -f DarkGray

        $UserPathValues = $UserPathEnvironmentVariable.Split(';')
        $UserPathValuesCount = $UserPathValues.Count
        Write-Host "[INFO] " -f DarkBlue -n
        Write-Host "User Scope Path Values Before drive switch : $UserPathValuesCount" -f Gray


        $NewPathValues_UserScope = @()
        $UserPathValues | % {
            $TmpValue = $_
            $NewValue = $_
            # Remove the '\' at the end of the value 
            $TmpValue = $TmpValue.ToUpper()

            # If the value is a Users directory, it needs to be transfered to the User Scope 
            if($TmpValue.Contains('C:\PROGRAMS\') -eq $True){
                Write-Host "[WARN] " -f DarkRed -n
                Write-Host "Found Programs value to be changed `"$NewValue`"" -f DarkYellow
                $NewValue = "{0}{1}" -f $NewDrive, ($NewValue.Substring(1,$NewValue.Length-1))
                $NewPathValues_UserScope += $NewValue
            }else{
                $NewPathValues_UserScope += $NewValue
            }
            
        }
        #######################################
        # Sort the values and remove duplicates
        $NewPathValues_UserScope = $NewPathValues_UserScope | Select -Unique | Sort -Descending
        $NewPathValues_UserScopeCount = $NewPathValues_UserScope.Count
        Write-Host "[INFO] " -f DarkBlue -n
        Write-Host "User Scope Path Values AFTER drive switch : $NewPathValues_UserScopeCount" -f Gray
  
        $NewUserPathValues = ''
        $NewPathValues_UserScope | % {
             $Value = $_
             $NewUserPathValues += "$Value;"
         }

        $NewMachinePathValues = ''
        $NewPathValues_MachineScope | % {
             $Value = $_
             $NewMachinePathValues += "$Value;"
         }

         $NewUserPathValues = $NewUserPathValues.Trim(';')
         $NewMachinePathValues = $NewMachinePathValues.Trim(';')

         Write-Host "================================================================" -f DarkGray
         Write-Host "MACHINE PATH VALUES ($($NewMachinePathValues.Length) chars)" -f Yellow
         Write-Host "---------------------------------------------------------------" -f DarkGray
         Write-Host "$NewMachinePathValues" -f Cyan
         Write-Host "================================================================`n" -f DarkGray

         Write-Host "`n================================================================" -f DarkGray
         Write-Host "USER PATH VALUES ($($NewUserPathValues.Length) chars)" -f Yellow
         Write-Host "---------------------------------------------------------------" -f DarkGray
         Write-Host "$NewUserPathValues" -f Cyan
         Write-Host "================================================================" -f DarkGray

         if($ConfirmNewValues){
            Set-EnvironmentVariable -Name "Path" -Value "$NewUserPathValues" -Scope User
            Set-EnvironmentVariable -Name "Path" -Value "$NewMachinePathValues" -Scope Machine
        }
    }catch{
        Show-ExceptionDetails $_
    }
    return $Null
}

