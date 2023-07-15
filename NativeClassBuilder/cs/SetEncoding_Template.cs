// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.Globalization;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using Microsoft.Win32;

namespace __NAMESPACE_NAME_PLACEHOLDER__
{
    public sealed class __CLASS_NAME_PLACEHOLDER__
    {

        public __CLASS_NAME_PLACEHOLDER__()
        {
        }
        public static void SetEncodingUtf8()
        {
            System.Console.OutputEncoding = Encoding.UTF8;
        }
        public static void SetEncodingUnicode()
        {
            System.Console.OutputEncoding = Encoding.GetEncoding(1200);
        }
        public static void SetEncodingWindows1252()
        {
            System.Console.OutputEncoding = Encoding.GetEncoding(1252);
        }
        public static Encoding GetCurrentEncoding()
        {
            return System.Console.OutputEncoding;
        }        
        public static string ConvertStringFromUtf8(string srcString)
        {
            // get the correct encodings 
            var srcEncoding = Encoding.UTF8; // utf-8
            var destEncoding = Encoding.GetEncoding(1252); // windows-1252

            // convert the source bytes to the destination bytes
            var destBytes = Encoding.Convert(srcEncoding, destEncoding, srcEncoding.GetBytes(srcString));

            // process the byte[]
            
            var destString = destEncoding.GetString(destBytes);
            return destString;
        }
    }
}
