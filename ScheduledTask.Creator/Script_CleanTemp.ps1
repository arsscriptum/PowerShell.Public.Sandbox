ForEach($d in (gci "$ENV:TEMP" -File).fullname){remove-item "$d" -recurse -force -errorAction Ignore | out-Null};
ForEach($d in (gci "$ENV:TEMP" -Directory).fullname){remove-item "$d" -recurse -force -errorAction Ignore | out-Null};
$s=(Get-Date).GetDateTimeFormats()[18];Set-Content "$ENV:TEMP\Clear.txt" -value "Cleared on $s";
