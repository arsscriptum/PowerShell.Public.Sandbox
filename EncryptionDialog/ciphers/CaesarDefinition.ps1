<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

$Caesar = @"

using System;
using System.Text;
namespace Cryptography {
    public static class Caesar
    {
        public static String Encrypt(String text, String pass)
        {
            var passwordBytes = Encoding.UTF8.GetBytes(pass);
            var cipherBytes = Encipher(passwordBytes, Encoding.UTF8.GetBytes(text));
            var cipherText = Convert.ToBase64String(cipherBytes);
            return cipherText;
        }
        public static String Decrypt(String cipherText, String pass)
        {
            var passwordBytes = Encoding.UTF8.GetBytes(pass);
            var plaintext = Encoding.UTF8.GetString(Decipher(passwordBytes, Convert.FromBase64String(cipherText)));
            return plaintext;
        }
        private static byte[] Encipher(byte[] key, byte[] plaindata)
        {
            return Crypt(key, plaindata, 1);
        }

        private static byte[] Decipher(byte[] key, byte[] cipherdata)
        {
            return Crypt(key, cipherdata, -1);
        }

       
        static byte[] Crypt(byte[] key, byte[] dataIn, int switcher)
        {
            //Initialize return array at same length as incoming array
            var dataOut = new byte[dataIn.Length];

            var i = 0;
            var u = 0;
            var mod = dataIn.Length % key.Length;

            for (; i < dataIn.Length - mod; i = i + key.Length ){
                for (u = 0; u < key.Length; u++){
                    var c = dataIn[i + u];
                    c = (byte)(c + (key[u] * switcher));
                    dataOut[i + u] = c;
                }
            }

            if (u == key.Length) u = 0;

            //Second pass: Iterate over the remaining bytes beyond the final block.
            for (; i < dataIn.Length; i++){
                var c = dataIn[i];
                c = (byte)(c + (key[u] * switcher));
                dataOut[i] = c;
                u++;
            }

            return dataOut;
        }
    }
}
"@
