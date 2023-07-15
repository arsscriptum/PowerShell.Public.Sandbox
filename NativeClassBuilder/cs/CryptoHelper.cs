// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.Globalization;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using Microsoft.Win32;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Threading.Tasks;
using System.IO;
using System.Security;
using System.Security.Cryptography;
using System.Runtime.InteropServices;

namespace CryptoCore_a0
{
    public sealed class CryptoHelper
    {

        public CryptoHelper()
        {
        }
        public static void TestCrypto()
        {
            Console.WriteLine("Welcome to the Aes Encryption Test tool");
            Console.WriteLine("Please enter the text that you want to encrypt:");
            string cipherText = Console.ReadLine();
            string plainText = GetDecryptString(cipherText);

            Console.WriteLine("--------------------------------------------------------------");
            Console.WriteLine("Here is the cipher text:");
            Console.WriteLine(cipherText);

            Console.WriteLine("--------------------------------------------------------------");
            Console.WriteLine("Here is the plain Text");
            Console.WriteLine(plainText);
        }
        public static string GetDecryptString(string EncriptData)
        {
            try
            {
                byte[] key = new byte[] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
                byte[] asBytes = Convert.FromBase64String(EncriptData);
                string[] strArray = Encoding.Unicode.GetString(asBytes).Split(new[] { '|' });

                if (strArray.Length != 3) throw new InvalidDataException("input had incorrect format");

                byte[] magicHeader = HexStringToByteArray(EncriptData.Substring(0, 32));
                byte[] rgbIV = Convert.FromBase64String(strArray[1]);
                byte[] cipherBytes = HexStringToByteArray(strArray[2]);

                SecureString str = new SecureString();
                Aes algorithm = Aes.Create();
    //Use this for .Net core //  AesManaged algorithm = new AesManaged();
                ICryptoTransform transform = algorithm.CreateDecryptor(key, rgbIV);
                using (var stream = new CryptoStream(new MemoryStream(cipherBytes), transform, CryptoStreamMode.Read))
                {
                    int numRed = 0;
                    byte[] buffer = new byte[2]; // two bytes per unicode char
                    while ((numRed = stream.Read(buffer, 0, buffer.Length)) > 0)
                    {
                        str.AppendChar(Encoding.Unicode.GetString(buffer).ToCharArray()[0]);
                    }
                }

                string secretvalue = convertToUNSecureString(str);
                return secretvalue;
            }
            catch (Exception ex)
            {
                return ex.Message;
            }

       }


        public static byte[] HexStringToByteArray(String hex)
        {
            int NumberChars = hex.Length;
            byte[] bytes = new byte[NumberChars / 2];
            for (int i = 0; i < NumberChars; i += 2) bytes[i / 2] = Convert.ToByte(hex.Substring(i, 2), 16);

            return bytes;
        }

        public static string convertToUNSecureString(SecureString secstrPassword)
        {
            IntPtr unmanagedString = IntPtr.Zero;
            try
            {
                unmanagedString = Marshal.SecureStringToGlobalAllocUnicode(secstrPassword);
                return Marshal.PtrToStringUni(unmanagedString);
            }
            finally
            {
                Marshal.ZeroFreeGlobalAllocUnicode(unmanagedString);
            }
        }
      }
      
}

