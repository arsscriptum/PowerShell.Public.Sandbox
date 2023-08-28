function Get-PlaintextFromSecureString([SecureString]$SecureString) {
    return (New-Object -TypeName System.Net.NetworkCredential('fake-user', $SecureString, 'fake-domain')).Password
}

function EncryptStringToBytes([String]$Plaintext, [System.Security.SecureString]$Password) {
    # C# code from:
    # https://gist.github.com/mark-adams/87aa34da3a5ed48ed0c7
    # https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.aes?view=netframework-4.8

    $Aes          = $null
    $Encryptor    = $null
    $StreamWriter = $null
    $CryptoStream = $null
    $MemoryStream = $null

    try {
        $PlaintextPassword = Get-PlaintextFromSecureString -SecureString $Password

        $Aes      = [System.Security.Cryptography.Aes]::Create()
        $Aes.Key  = [System.Security.Cryptography.HashAlgorithm]::Create('SHA256').ComputeHash([System.Text.Encoding]::UTF8.GetBytes($PlaintextPassword))
        $Aes.GenerateIV()
        $Aes.Mode = [System.Security.Cryptography.CipherMode]::CBC

        # Create an encryptor to perform the stream transform.
        $Encryptor = $Aes.CreateEncryptor($Aes.Key, $Aes.IV)

        # Create the streams used for encryption.
        $MemoryStream = [System.IO.MemoryStream]::new()
        $CryptoStream = [System.Security.Cryptography.CryptoStream]::new($MemoryStream, $Encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
        $StreamWriter = [System.IO.StreamWriter]::new($CryptoStream)

        # Write all data to the stream.
        $StreamWriter.Write($Plaintext)
        $StreamWriter.Close()
        $CryptoStream.Close()

        $EncryptedBytes = $MemoryStream.ToArray()
        $MemoryStream.Close()

        # Append the initialization vector to the encrypted bytes.
        $CipherTextWithIv = New-Object -TypeName Byte[] -ArgumentList ($Aes.IV.Length + $EncryptedBytes.Length)
        [Array]::Copy($Aes.IV, 0, $CipherTextWithIv, 0, $Aes.IV.Length)
        [Array]::Copy($EncryptedBytes, 0, $CipherTextWithIv, $Aes.IV.Length, $EncryptedBytes.Length)

        # Return the encrypted bytes with initialization vector.
        Write-Output -InputObject $CipherTextWithIv
    }
    finally {
        if ($null -ne $StreamWriter) { $StreamWriter.Dispose() }
        if ($null -ne $CryptoStream) { $CryptoStream.Dispose() }
        if ($null -ne $MemoryStream) { $MemoryStream.Dispose() }
        if ($null -ne $Encryptor) { $Encryptor.Dispose() }
        if ($null -ne $Aes) { $Aes.Dispose() }
    }
}

function DecryptStringFromBytes([byte[]]$Ciphertext, [System.Security.SecureString]$Password) {
    # C# code from:
    # https://gist.github.com/mark-adams/87aa34da3a5ed48ed0c7
    # https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.aes?view=netframework-4.8

    $Aes          = $null
    $Decryptor    = $null
    $StreamReader = $null
    $CryptoStream = $null
    $MemoryStream = $null

    try {
        $PlaintextPassword = Get-PlaintextFromSecureString -SecureString $Password

        # Use the SHA256 hash of the password as the key.
        $Aes      = [System.Security.Cryptography.Aes]::Create()
        $Aes.Key  = [System.Security.Cryptography.HashAlgorithm]::Create('SHA256').ComputeHash([System.Text.Encoding]::UTF8.GetBytes($PlaintextPassword))

        # Extract the initialization vector and encrypted bytes.
        $BitsInByte = 8
        $InitializationVector = New-Object -TypeName Byte[] -ArgumentList ($Aes.BlockSize / $BitsInByte)
        $EncryptedBytes       = New-Object -TypeName Byte[] -ArgumentList ($Ciphertext.Length - $InitializationVector.Length)

        [Array]::Copy($Ciphertext, $InitializationVector, $InitializationVector.Length)
        [Array]::Copy($Ciphertext, $InitializationVector.Length, $EncryptedBytes, 0, $EncryptedBytes.Length)

        $Aes.IV   = $InitializationVector
        $Aes.Mode = [System.Security.Cryptography.CipherMode]::CBC

        # Create a decryptor to perform the stream transform.
        $Decryptor = $Aes.CreateDecryptor($Aes.Key, $Aes.IV)

        # Create the streams used for decryption.
        $MemoryStream = [System.IO.MemoryStream]::new($EncryptedBytes)
        $CryptoStream = [System.Security.Cryptography.CryptoStream]::new($MemoryStream, $Decryptor, [System.Security.Cryptography.CryptoStreamMode]::Read)
        $StreamReader = [System.IO.StreamReader]::new($CryptoStream)

        # Read the decrypted bytes from the decrypting stream
        # and place them in a string.
        $Plaintext = $StreamReader.ReadToEnd()

        $StreamReader.Close()
        $CryptoStream.Close()
        $MemoryStream.Close()

        Write-Output -InputObject $Plaintext
    }
    finally {
        if ($null -ne $StreamReader) { $StreamReader.Dispose() }
        if ($null -ne $CryptoStream) { $CryptoStream.Dispose() }
        if ($null -ne $MemoryStream) { $MemoryStream.Dispose() }
        if ($null -ne $Decryptor) { $Decryptor.Dispose() }
        if ($null -ne $Aes) { $Aes.Dispose() }
    }
}


$Password = "secret" | ConvertTo-SecureString -AsPlainText


$Plaintext = "test"

# Encrypt file contents and save to a new file.
$EncryptedBytes = EncryptStringToBytes -Plaintext $Plaintext -Password $Password
$B64Cipher=[System.Convert]::ToBase64String($EncryptedBytes)
$B64Cipher
# Read encrypted bytes from a file, then decrypt to a string.
$cipherBytes = [System.Convert]::FromBase64String($B64Cipher)
DecryptStringFromBytes -Ciphertext $cipherBytes -Password $Password