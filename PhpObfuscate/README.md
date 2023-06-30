# Obfuscate PHP code with PowerShell

Here's a small PowerShell script that I use to obfucate PHP code. It uses the [https://www.gaijin.at/en/tools/php-obfuscator](https://www.gaijin.at/en/tools/php-obfuscator) website.

### Use Case
```
    cd scripts
    . .\run_obfuscate.ps1
```


### Important Note regarding Function Rename

The function rename functionality is implemented locally and doesn't rely on the online obfuscation system. Although there is such a functionality and it works fine, the problem I have with it is that most ```php``` code contains not only php, but also html. And the html often contains references to php functions.

Since we send only the block of php code to the online obfuscation system, our html code is not updated with the new function names and there's n easy way to fix that after the fact.

So I have implemented the functionality locally and the functions are renamed in both the php and html code blocks. Then we send the php code for additional obfuscation using the other methods available to us:

- RemoveComments 
- ObfuscateVariables 
- EncodeStrings 
- UseHexValuesForNames 
- RemoveWhitespaces

### Obfuscation Level 1 - Obfuscate Variables

```
	Invoke-PhpObfuscator $Src $Dst -RemoveComments -ObfuscateVariables 
```

### Obfuscation Level 2 - Obfuscate Variables + Encode Strings

```
	Invoke-PhpObfuscator $Src $Dst -RemoveComments -ObfuscateVariables -EncodeStrings 
```

### Obfuscation Level 3 - Level 2 + Use Hex Values For Names + Remove Whitespaces

```
	Invoke-PhpObfuscator $Src $Dst -RemoveComments -ObfuscateVariables -EncodeStrings -UseHexValuesForNames -RemoveWhitespaces
```

### Obfuscation Level 4 - Level 3 + Rename all Functions

```
	Invoke-PhpObfuscator $Src $Dst -RemoveComments -ObfuscateVariables -EncodeStrings -UseHexValuesForNames -RemoveWhitespaces -RenameFunctions -RenamingMethod "MD5" -Md5Length 24 -PrefixLength 8
```

### Demo Full Obfuscation

![Full Obfuscation Demo](gif/demo_full.gif)


### Demo the 4 different Obfuscation levels


![Full 4 different Obfuscation levels](gif/demo_4levels.gif)