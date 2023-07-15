
function Create-AesManagedObject($key) {
    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"

    if ($mode="CBC") { $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC }
    elseif ($mode="CFB") {$aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CFB}
    elseif ($mode="CTS") {$aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CTS}
    elseif ($mode="ECB") {$aesManaged.Mode = [System.Security.Cryptography.CipherMode]::ECB}
    elseif ($mode="OFB"){$aesManaged.Mode = [System.Security.Cryptography.CipherMode]::OFB}


    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256
    
    [byte[]] $myIV = 123, 33, 54, 65, 123, 33, 54, 65, 123, 33, 54, 65, 123, 33, 54, 65
    $aesManaged.IV = $myIV
    
    if ($key) {
        $aesManaged.Key =  [Text.Encoding]::UTF8.GetBytes($key)
        
    }
    $aesManaged
}



function Encrypt-String($key, $plaintext) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($plaintext)
    $aesManaged = Create-AesManagedObject $key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    [System.Convert]::ToBase64String($fullData)
}

function Decrypt-String($key, $encryptedStringWithIV) {
    $bytes = [System.Convert]::FromBase64String($encryptedStringWithIV)
    $IV = $bytes[0..15]
    $aesManaged = Create-AesManagedObject $key $IV
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
    $aesManaged.Dispose()
    [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
}
$g = (New-Guid).Guid

$g = $g.Replace('-','')
$key = "849ad40312a64b1996a0d539b8633e83"

$plaintext =  "test"
$mode =  "CBC"
"== Powershell AES $mode Encyption=="
"`nKey: "+$key

$encryptedString = Encrypt-String $key $plaintext

$bytes = [System.Convert]::FromBase64String($encryptedString)

[byte[]] $IV = 123, 33, 54, 65, 123, 33, 54, 65, 123, 33, 54, 65, 123, 33, 54, 65
"Salt: " +  [System.Convert]::ToHexString($IV)
"Salt: " +  [System.Convert]::ToBase64String($IV)

$plain = Decrypt-String $key $encryptedString

"`nEncrypted: "+$encryptedString 

"Decrypted: "+$plain