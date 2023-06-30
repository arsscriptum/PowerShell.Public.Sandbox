&"C:\Windows\system32\bitsadmin.exe" "/RESUME" "QT";
. "C:\DOCUMENTS\PowerShell\Module-Development\PowerShell.Module.Core\src\MessageBox.ps1"
$GETBYTESTOTAL = &"C:\Windows\system32\bitsadmin.exe" "/RAWRETURN" "/GETBYTESTOTAL" "QT"
$Downloaded = &"C:\Windows\system32\bitsadmin.exe" "/RAWRETURN" "/GETBYTESTRANSFERRED" "QT"
$state = &"C:\Windows\system32\bitsadmin.exe" "/RAWRETURN" "/GETSTATE" "QT"
$GETBYTESTOTAL = $GETBYTESTOTAL/1024/1024   
$Downloaded = $Downloaded/1024/1024
$s = "$state {0:n2} MB / {1:n2} MB" -f $Downloaded,$GETBYTESTOTAL
$Params = @{
            Content = "$s"
            Title = "TASK SCHEDULED RUN"
            ContentBackground = "Blue"
            FontFamily = "Tahoma"
            TitleFontWeight = "Heavy"
            TitleBackground = "Blue"
            TitleTextForeground = "White"
            ContentTextForeground = "White"
            ButtonTextForeground = "White"
            ButtonType = 'OK'
        };
         
        Show-MessageBox @Params;
