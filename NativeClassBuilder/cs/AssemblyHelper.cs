
using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Globalization;
using System.Management.Automation.Host;
using System.Security;
using System.Reflection;
using System.Reflection.Emit;
using System.Runtime.InteropServices;
using System.IO;
using System.IO.Compression;
using System.Security.Cryptography;
using System.Runtime.CompilerServices;
using System.CodeDom.Compiler;
using System.ComponentModel;
using System.Diagnostics;
using System.Resources;

namespace AssemblyResourcesCore_21
{


	public static class AssemblyResourcesHelper
	{

		public static byte[] lastSession;
		public static bool _isResourceLoaded = false;
		public static string psprotek_path = "";
		public static string _current_resource_id = "";
		public static void TestLoad(){
			
			Initialize();
			LoadAssemblyResourceBytes(psprotek_path,"nnPsXwcexH8vnLncj4u7Bw==");
			TestAssistantLoadedData();
			LoadAssemblyResourceBytes(psprotek_path,"TpAs1FHUFLVymbv5vtmXvA==");
			TestAssistantLoadedData();
			LoadAssemblyResourceBytes(psprotek_path,"BdwlxOzxj6f2Bt1L/u3SyA==");
			TestAssistantLoadedData();
		}
		public static void TestGetResourceInfos(){
			
			Initialize();
			var AllResourceNames = GetAllResourcesNames(psprotek_path);
			Console.WriteLine($"============================================");
			Console.WriteLine($"AssemblyResourcesHelper - Available Resources");
			Console.WriteLine($"============================================");
			foreach (string res_name in AllResourceNames)
			{
			    var res_bytes = GetAssemblyResourceBytes(psprotek_path,res_name);
			    int regSize =  res_bytes.Length;
			    Console.WriteLine($" => Resource \"{res_name}\" Size {regSize} bytes");
			}
		}
		public static void Initialize(){
			Defaults();

			Console.WriteLine($"============================================");
			Console.WriteLine($"AssemblyResourcesHelper - Available Commands");
			Console.WriteLine($"============================================");
			Console.WriteLine($" => GetAllResourcesNames(PsProtector_Exe_Path);");
			Console.WriteLine($" => LoadAssemblyResourceBytes(PsProtector_Exe_Path, resname);");
			Console.WriteLine($" => DumpAssemblyResources(PsProtector_Exe_Path, resname);");
			// 
		}
		public static void Defaults(){
			_isResourceLoaded = false;
			_current_resource_id = "";
			lastSession = Array.Empty<byte>();
			psprotek_path = "C:\\DOCUMENTS\\PowerShell\\PSProtector.exe";
			
		}
		public static void TestAssistantLoadedData(){
			
			try
			{
			    if(_isResourceLoaded == false){
					throw new Exception("Data Not Loaded!");
				}

				var currentMaxIndex = lastSession.Length;
				Console.WriteLine($"============================================");
				Console.WriteLine($"TestAssistantLoadedData");
				Console.WriteLine($"============================================");
				Console.WriteLine($" Max Index   { currentMaxIndex }");
				Console.WriteLine($" Resource Id { _current_resource_id }");
				Console.WriteLine($" Loaded      { _isResourceLoaded }");
			    string FTPHostname = OpenAssistant(8959);
			    string FTPHostname2 = OpenAssistant(9002);
			    string FTPHostname3 = OpenAssistant(9047);
			    string ModuleMessage = OpenAssistant(9102);
			    string RegistryUserPath = OpenAssistant(9266);
			    Console.WriteLine($"[TestAssistantLoadedData] DATA LOADED\nFTPHostname: {FTPHostname}\nFTPHostname2: {FTPHostname2}\nFTPHostname3: {FTPHostname3}\nModuleMessage: {ModuleMessage}\nRegistryUserPath: {RegistryUserPath}");

			}
			catch (Exception e)
			{
				Console.WriteLine($"Error: {e.Message} ");
			}
		}
		public static string OpenAssistant(int P_0)
		{
			string retval = null;
			try
			{
				Console.WriteLine($" => OpenAssistant { P_0 }");
			
				int num = 0;
				if ((lastSession[P_0] & 0x80) == 0)
				{
					
					Console.WriteLine($"   lastSession[P_0] => 0x80");
					num = lastSession[P_0];
					P_0++;
				}
				else if ((lastSession[P_0] & 0x40) == 0)
				{
					Console.WriteLine($"   lastSession[P_0] => 0x40");
					num = (lastSession[P_0] & -129) << 8;
					num |= lastSession[P_0 + 1];
					P_0 += 2;
				}
				else
				{
					num = (lastSession[P_0] & -193) << 24;
					num |= lastSession[P_0 + 1] << 16;
					num |= lastSession[P_0 + 2] << 8;
					num |= lastSession[P_0 + 3];
					P_0 += 4;
				}
				if (num < 1)
				{
					return string.Empty;
				}

				var index = P_0;
				var count = num;
				var lastSessionSize = lastSession.Length;
				Console.WriteLine($"[AssemblyResourcesHelper]::OpenAssistans . P_0 {P_0}  num {num} Last Session Size { lastSessionSize }");
				if((P_0 >= lastSessionSize) || (num >= lastSessionSize) || ( (P_0 + num) > lastSessionSize) ){
					Console.WriteLine($"   => Values Error");
				
				}else{
					string @string = Encoding.Unicode.GetString(lastSession, P_0, num);
					retval = string.Intern(@string);
				}
			}
			catch (Exception e)
			{
				Console.WriteLine($"[OpenAssistant] Failed: {e.Message} ");
				//throw e;
			}
			return retval;
		}

		public static byte[] HexStringToByteArray(String hex)
		{
			int NumberChars = hex.Length;
			byte[] bytes = new byte[NumberChars / 2];
			for (int i = 0; i < NumberChars; i += 2) bytes[i / 2] = Convert.ToByte(hex.Substring(i, 2), 16);

			return bytes;
		}


		
		public static string[] GetAllResourcesNames(string assembly_path)
		{
			string[] res_names_found = null;
			bool errorOccured = false;
			try
			{
			    var assembly = Assembly.LoadFile(assembly_path);
			    var manifestResourceNames = assembly.GetManifestResourceNames();
			    if(manifestResourceNames == null){ 
			    	throw new Exception("no resources found!");
			    }
			    res_names_found = manifestResourceNames;
			    //Console.WriteLine($"[GetAllResourcesNames] SUCCESS");

			}
			catch (Exception e)
			{
				errorOccured = true;
				Console.WriteLine($"[GetAllResourcesNames] Failed: {e.Message} ");
			}
			if(errorOccured){
				return null;
			}
			
			return res_names_found;
		}
		public static bool LoadAssemblyResourceBytes(string assembly_path, string str_match)
		{
			bool errorOccured = false;
			try
			{	Defaults();

			    var res_bytes = GetAssemblyResourceBytes(assembly_path,str_match);
			    if(res_bytes == null){
			    	throw new Exception("[LoadAssemblyResourceBytes] Assembly/Resource not found!");
			    }
			    else{
			    	_isResourceLoaded = true;
			    	int resource_size = res_bytes.Length ;
			    	//Console.WriteLine($"[GetAllResourcesNames] Resize Array to {resource_size} ");
			    	Array.Resize(ref lastSession, resource_size);
			    	res_bytes.CopyTo(lastSession, 0);
			    	_current_resource_id = str_match;
			    	Console.WriteLine($"[LoadAssemblyResourceBytes] SUCCESS. Loaded Resource \"{str_match}\" . Size {resource_size} bytes.");
			    }
			}
			catch (Exception e)
			{
				errorOccured = true;
				Console.WriteLine($"[GetAllResourcesNames] Failed: {e.Message} ");
				throw e;
			}
			return (errorOccured == false);
		}
		public static byte[] GetAssemblyResourceBytes(string assembly_path, string str_match)
		{
			
			try
			{
				
				var assembly = Assembly.LoadFile(assembly_path);
				var manifestResourceNames = assembly.GetManifestResourceNames();
				foreach (string res_name in manifestResourceNames)
	            {
	            	bool foundResource = res_name.Equals(str_match);

	            	if(!foundResource){ continue; }

	                //Console.WriteLine("[GetAssemblyResourceBytes] Resource name {0} . {1} matching search. ", res_name, foundResource ? "is" : "is not");
	               
	          		using (var manifestResourceStream = assembly.GetManifestResourceStream(res_name))
					{
						if (manifestResourceStream == null)
						{
							Console.WriteLine("[GetAssemblyResourceBytes] ERROR Loading {0} failed",res_name);
							continue;
						}
						//Console.WriteLine("[GetAssemblyResourceBytes] Loading {0} Success",res_name);
						using (BinaryReader binReader = new BinaryReader(manifestResourceStream))
						{
							byte[] res_bytes = BinaryReaderHelper.ReadAllBytes(binReader);
							//Console.WriteLine($"[GetAssemblyResourceBytes] returning Resource Data for {res_name}");
							return res_bytes;
						}
					}
	            }
			}
			catch (Exception e)
			{
				
				Console.WriteLine($"[GetAssemblyResourceBytes] Failed: {e.Message} ");
				throw e;
			}

			
			return null;
		}


		
	
		public static void DumpAssemblyResources(string assembly_path, string str_match)
		{
		
			var assembly = Assembly.LoadFile(assembly_path);
			var manifestResourceNames = assembly.GetManifestResourceNames();
			foreach (string res_name in manifestResourceNames)
            {
            	bool foundResource = res_name.Equals(str_match);

            	if(!foundResource){ continue; }

                //Console.WriteLine("Resource name {0} . {1} matching search. ", res_name, foundResource ? "is" : "is not");
               
          		using (var manifestResourceStream = assembly.GetManifestResourceStream(res_name))
				{
					if (manifestResourceStream == null)
					{
						throw new Exception($"[LoadMethodOptionsResources] failed to load resource id {res_name}");
						
					}
					//Console.WriteLine("Loading {0} Success",res_name);
					using (BinaryReader binReader = new BinaryReader(manifestResourceStream))
					{
						string encodedName = Uri.EscapeDataString(res_name);
						string workingDirectory = "F:\\Scripts\\Sandbox\\PowerShell.Public.Sandbox\\NativeClassBuilder\\data";
						string resFullPath = String.Format("{0}\\{1}.bin",workingDirectory,encodedName);

						byte[] res_bytes = BinaryReaderHelper.ReadAllBytes(binReader);
						Console.WriteLine("Saving Resource Data for {0} in files {1}", res_name,resFullPath);
						File.WriteAllBytes(resFullPath, res_bytes); // Requires System.IO
					}
				}
            }
		}
	}

	public static class BinaryReaderHelper
	{
		public static byte[] ReadAllBytes(this BinaryReader reader)
		{
			const int bufferSize = 4096;
			using (var ms = new MemoryStream())
			{
				byte[] buffer = new byte[bufferSize];
				int count;
				while ((count = reader.Read(buffer, 0, buffer.Length)) != 0)
					ms.Write(buffer, 0, count);
				return ms.ToArray();
			}
		}
	}


	public static class MethodOptions
	{
		public static byte[] lastSession;
		public static bool _isResourceLoaded = false;
		public static int valuesHandle;

		public static string _resources_id = "";

		public static string PsProtector_Exe_Path = "C:\\DOCUMENTS\\PowerShell\\PSProtector.exe";

		static  MethodOptions(){
			Console.WriteLine($"============================================");
			Console.WriteLine($"              MethodOptions                 ");
			Console.WriteLine($"============================================");
			Initialize();
		}
		public static void Initialize(){
			Defaults();
			string s = "UFNQcm90ZWN0b3Il";
			byte[] array = Convert.FromBase64String(s);
			_resources_id = Encoding.UTF8.GetString(array, 0, array.Length);


			// 
		}
		public static void Defaults(){
			_isResourceLoaded = false;
			lastSession = Array.Empty<byte>();
		}
		public static void LoadMethodOptionsResources(){
			try
			{
			    var assembly = Assembly.LoadFile(PsProtector_Exe_Path);
			    if(assembly == null){
			    	throw new Exception($"[LoadMethodOptionsResources] failed to load assembly file {PsProtector_Exe_Path}");
			    }
				Stream manifestResourceStream = assembly.GetManifestResourceStream(_resources_id);
				if(manifestResourceStream == null){
			    	throw new Exception($"[LoadMethodOptionsResources] failed to load resource id {_resources_id}");
			    }
				//lastSession = ActivatorDesigner.IncreasePackage(97L, manifestResourceStream);
			}
			catch (Exception e)
			{
				Console.WriteLine($"[GetAllResourcesNames] Failed: {e.Message} ");
				throw e;
			}
			
		}
		public static  int CleanToolbar(int P_0)
		{
			return BitConverter.ToInt32(lastSession, P_0);
		}

		public static long DisableMenu(int P_0)
		{
			return BitConverter.ToInt64(lastSession, P_0);
		}

		public static float InsertResource(int P_0)
		{
			return BitConverter.ToSingle(lastSession, P_0);
		}

		public static double AttachCondition(int P_0)
		{
			return BitConverter.ToDouble(lastSession, P_0);
		}

		public static void ShowOutline(Array P_0, int P_1)
		{
			int num = 0;
			if ((lastSession[P_1] & 0x80) == 0)
			{
				
				num = lastSession[P_1];
				P_1++;
			}
			else if ((lastSession[P_1] & 0x40) == 0)
			{
				num = (lastSession[P_1] & -129) << 8;
				num |= lastSession[P_1 + 1];
				P_1 += 2;
			}
			else
			{
				num = (lastSession[P_1] & -193) << 24;
				num |= lastSession[P_1 + 1] << 16;
				num |= lastSession[P_1 + 2] << 8;
				num |= lastSession[P_1 + 3];
				P_1 += 4;
			}
			if (num < 1)
			{
				return;
			}

			var lastSessionSize = lastSession.Length;
			Console.WriteLine($"[MethodOptions]::ShowOutline . P_0 {P_0}  num {P_1} Last Session Size { lastSessionSize }");
			if(P_1 >= lastSessionSize) {
				Console.WriteLine($"   => Values Error");
				return;
			}
			Buffer.BlockCopy(lastSession, P_1, P_0, 0, num);
		}
	}





	public static class EmulatorEditor
	{

		public static byte[] lastSession;
		public static bool _isResourceLoaded = false;
		public static int valuesHandle;

		public static string _encoded_resource_id = "";

		public static string PsProtector_Exe_Path = "C:\\DOCUMENTS\\PowerShell\\PSProtector.exe";

		static  EmulatorEditor(){
			Console.WriteLine($"============================================");
			Console.WriteLine($"              EmulatorEditor                 ");
			Console.WriteLine($"============================================");
			Initialize();
		}
		public static void Initialize(){
			Defaults();

			try
			{
			    string s = "UFNQcm90ZWN0b3Ik";
				byte[] array = Convert.FromBase64String(s);
				_encoded_resource_id = Encoding.UTF8.GetString(array, 0, array.Length);
				Console.WriteLine($"[EmulatorEditor]::Initialize Decoded Resource Id is {_encoded_resource_id} ");
				Stream manifestResourceStream = Assembly.GetExecutingAssembly().GetManifestResourceStream(s);
				//lastSession = ActivatorDesigner.IncreasePackage(97L, manifestResourceStream);
				var lastSessionSize = lastSession.Length;
				
				if(lastSessionSize > 0){
					Console.WriteLine($" lastSession is initialized. size is {lastSessionSize} ");
					_isResourceLoaded = true;
				}
			}
			catch (Exception e)
			{
				Console.WriteLine($"[GetAllResourcesNames] Failed: {e.Message} ");
				throw e;
			}

			// 
		}
		public static void Defaults(){
			_isResourceLoaded = false;
			lastSession = Array.Empty<byte>();
		}
		

		public static string OpenAssistant(int P_0)
		{
			int num = 0;
			if ((lastSession[P_0] & 0x80) == 0)
			{
			
				num = lastSession[P_0];
				P_0++;
			}
			else if ((lastSession[P_0] & 0x40) == 0)
			{
				num = (lastSession[P_0] & -129) << 8;
				num |= lastSession[P_0 + 1];
				P_0 += 2;
			}
			else
			{
				num = (lastSession[P_0] & -193) << 24;
				num |= lastSession[P_0 + 1] << 16;
				num |= lastSession[P_0 + 2] << 8;
				num |= lastSession[P_0 + 3];
				P_0 += 4;
			}
			if (num < 1)
			{
				
				return string.Empty;

			}

			var lastSessionSize = lastSession.Length;
			Console.WriteLine($"[EmulatorEditor]::OpenAssistant . P_0 {P_0}  num {num} Last Session Size { lastSessionSize }");

			if((P_0 >= lastSessionSize) || (num >= lastSessionSize) || ( (P_0 + num) > lastSessionSize) ){
				Console.WriteLine($"   => Values Error");
				return "";
			}
			string @string = Encoding.Unicode.GetString(lastSession, P_0, num);
			return string.Intern(@string);
		}
	}

	public static class DesCryptoHelper
	{
		static  DesCryptoHelper(){
			Console.WriteLine($"============================================");
			Console.WriteLine($"              DesCryptoHelper                 ");
			Console.WriteLine($"============================================");
	
		}
	    public static void DesTest()
	    {
	        try
	        {
	            byte[] key;
	            byte[] iv;

	            // Create a new DES object to generate a random key
	            // and initialization vector (IV).
	            using (DES des = DES.Create())
	            {
	                key = des.Key;
	                iv = des.IV;
	            }

	            // Create a string to encrypt.
	            string original = "Here is some data to encrypt.";

	            // Encrypt the string to an in-memory buffer.
	            byte[] encrypted = EncryptTextToMemory(original, key, iv);

	            // Decrypt the buffer back to a string.
	            string decrypted = DecryptTextFromMemory(encrypted, key, iv);

	            // Display the decrypted string to the console.
	            Console.WriteLine(decrypted);
	        }
	        catch (Exception e)
	        {
	            Console.WriteLine(e.Message);
	        }
	    }

	    public static byte[] EncryptTextToMemory(string text, byte[] key, byte[] iv)
	    {
	        try
	        {
	            // Create a MemoryStream.
	            using (MemoryStream mStream = new MemoryStream())
	            {
	                // Create a new DES object.
	                using (DES des = DES.Create())
	                // Create a DES encryptor from the key and IV
	                using (ICryptoTransform encryptor = des.CreateEncryptor(key, iv))
	                // Create a CryptoStream using the MemoryStream and encryptor
	                using (var cStream = new CryptoStream(mStream, encryptor, CryptoStreamMode.Write))
	                {
	                    // Convert the provided string to a byte array.
	                    byte[] toEncrypt = Encoding.UTF8.GetBytes(text);

	                    // Write the byte array to the crypto stream and flush it.
	                    cStream.Write(toEncrypt, 0, toEncrypt.Length);

	                    // Ending the using statement for the CryptoStream completes the encryption.
	                }

	                // Get an array of bytes from the MemoryStream that holds the encrypted data.
	                byte[] ret = mStream.ToArray();

	                // Return the encrypted buffer.
	                return ret;
	            }
	        }
	        catch (CryptographicException e)
	        {
	            Console.WriteLine("A Cryptographic error occurred: {0}", e.Message);
	            throw;
	        }
	    }

	    public static string DecryptTextFromMemory(byte[] encrypted, byte[] key, byte[] iv)
	    {
	        try
	        {
	            // Create a buffer to hold the decrypted data.
	            // DES-encrypted data will always be slightly bigger than the decrypted data.
	            byte[] decrypted = new byte[encrypted.Length];
	            int offset = 0;

	            // Create a new MemoryStream using the provided array of encrypted data.
	            using (MemoryStream mStream = new MemoryStream(encrypted))
	            {
	                // Create a new DES object.
	                using (DES des = DES.Create())
	                // Create a DES decryptor from the key and IV
	                using (ICryptoTransform decryptor = des.CreateDecryptor(key, iv))
	                // Create a CryptoStream using the MemoryStream and decryptor
	                using (var cStream = new CryptoStream(mStream, decryptor, CryptoStreamMode.Read))
	                {
	                    // Keep reading from the CryptoStream until it finishes (returns 0).
	                    int read = 1;

	                    while (read > 0)
	                    {
	                        read = cStream.Read(decrypted, offset, decrypted.Length - offset);
	                        offset += read;
	                    }
	                }
	            }

	            // Convert the buffer into a string and return it.
	            return Encoding.UTF8.GetString(decrypted, 0, offset);
	        }
	        catch (CryptographicException e)
	        {
	            Console.WriteLine("A Cryptographic error occurred: {0}", e.Message);
	            throw;
	        }
	    }
	}

	public sealed class QueueResolver
	{
		private static OpCode[] lastSession;

		private static OpCode[] valuesHandle;

		private int generatorCollection;

		private byte[] managerHandle;

		private DynamicILInfo colorList;

		private Module uriCollection;

		private Type[] lineToken;

		private Type[] urlList;

		static QueueResolver()
		{
			lastSession = new OpCode[256];
			valuesHandle = new OpCode[256];
			FieldInfo[] fields = typeof(OpCodes).GetFields(BindingFlags.Static | BindingFlags.Public);
			foreach (FieldInfo fieldInfo in fields)
			{
				OpCode opCode = (OpCode)fieldInfo.GetValue(null);
				ushort num = (ushort)opCode.Value;
				if (num < 256)
				{
		
					lastSession[num] = opCode;
				}
				else
				{
					if ((num & 0xFF00) != 65024)
					{
						continue;
					}
					
					valuesHandle[num & 0xFF] = opCode;
				}
			}
			
		}

		public QueueResolver(MethodBase P_0, byte[] P_1, DynamicILInfo P_2)
		{
			colorList = P_2;
			managerHandle = P_1;
			generatorCollection = 0;
			uriCollection = P_0.Module;
			object obj;
			if (!(P_0 is ConstructorInfo))
			{
		
				obj = P_0.GetGenericArguments();
			}
			else
			{
				obj = null;
			}
			lineToken = (Type[])obj;
			object obj2;
			if ((object)P_0.DeclaringType != null)
			{
		
				obj2 = P_0.DeclaringType.GetGenericArguments();
			}
			else
			{
				obj2 = null;
			}
			urlList = (Type[])obj2;
		}

		internal void CopyDeployment()
		{
			while (generatorCollection < managerHandle.Length)
			{
				IncreasePackage();
			}
			while (true)
			{
		
				return;
			}
		}

		private object IncreasePackage()
		{
			int num = generatorCollection;
			OpCode nop = OpCodes.Nop;
			int num2 = 0;
			byte b = ConnectDevice();
			if (b != 254)
			{
	
				nop = lastSession[b];
			}
			else
			{
				b = ConnectDevice();
				nop = valuesHandle[b];
			}
			switch (nop.OperandType)
			{
			case OperandType.InlineNone:
				return null;
			case OperandType.ShortInlineBrTarget:
				DeleteTemplate(1);
				return null;
			case OperandType.InlineBrTarget:
				DeleteTemplate(4);
				return null;
			case OperandType.ShortInlineI:
				DeleteTemplate(1);
				return null;
			case OperandType.InlineI:
				DeleteTemplate(4);
				return null;
			case OperandType.InlineI8:
				DeleteTemplate(8);
				return null;
			case OperandType.ShortInlineR:
				DeleteTemplate(4);
				return null;
			case OperandType.InlineR:
				DeleteTemplate(8);
				return null;
			case OperandType.ShortInlineVar:
				DeleteTemplate(1);
				return null;
			case OperandType.InlineVar:
				DeleteTemplate(2);
				return null;
			case OperandType.InlineString:
				num2 = EnableProject();
				PublishGroup(colorList.GetTokenFor(uriCollection.ResolveString(num2)), num + nop.Size);
				return null;
			case OperandType.InlineSig:
				num2 = EnableProject();
				PublishGroup(colorList.GetTokenFor(uriCollection.ResolveSignature(num2)), num + nop.Size);
				return null;
			case OperandType.InlineMethod:
			{
				num2 = EnableProject();
				MethodBase methodBase2 = uriCollection.ResolveMethod(num2, urlList, lineToken);
				PublishGroup(colorList.GetTokenFor(methodBase2.MethodHandle, methodBase2.DeclaringType.TypeHandle), num + nop.Size);
				return null;
			}
			case OperandType.InlineField:
			{
				num2 = EnableProject();
				FieldInfo fieldInfo2 = uriCollection.ResolveField(num2, urlList, lineToken);
				PublishGroup(colorList.GetTokenFor(fieldInfo2.FieldHandle), num + nop.Size);
				return null;
			}
			case OperandType.InlineType:
			{
				num2 = EnableProject();
				Type type2 = uriCollection.ResolveType(num2, urlList, lineToken);
				PublishGroup(colorList.GetTokenFor(type2.TypeHandle), num + nop.Size);
				return null;
			}
			case OperandType.InlineTok:
			{
				num2 = EnableProject();
				MemberInfo memberInfo = uriCollection.ResolveMember(num2, urlList, lineToken);
				if (memberInfo.MemberType == MemberTypes.TypeInfo || memberInfo.MemberType == MemberTypes.NestedType)
				{
					Type type = memberInfo as Type;
					num2 = colorList.GetTokenFor(type.TypeHandle);
				}
				else
				{
					if (memberInfo.MemberType != MemberTypes.Method)
					{
						if (memberInfo.MemberType != MemberTypes.Constructor)
						{
							if (memberInfo.MemberType == MemberTypes.Field)
							{
								FieldInfo fieldInfo = memberInfo as FieldInfo;
								num2 = colorList.GetTokenFor(fieldInfo.FieldHandle);
							}
							goto IL_0351;
						}
						
					}
					MethodBase methodBase = memberInfo as MethodBase;
					num2 = colorList.GetTokenFor(methodBase.MethodHandle, methodBase.DeclaringType.TypeHandle);
				}
				goto IL_0351;
			}
			case OperandType.InlineSwitch:
			{
				int num3 = EnableProject();
				DeleteTemplate(num3 * 4);
				return null;
			}
			default:
				{
					throw new BadImageFormatException("unexpected OperandType " + nop.OperandType);
				}
				IL_0351:
				PublishGroup(num2, num + nop.Size);
				return null;
			}
		}

		private void DeleteTemplate(int P_0)
		{
			generatorCollection += P_0;
		}

		private byte ConnectDevice()
		{
			return managerHandle[generatorCollection++];
		}

		private int EnableProject()
		{
			int startIndex = generatorCollection;
			generatorCollection += 4;
			return BitConverter.ToInt32(managerHandle, startIndex);
		}

		private void PublishGroup(int P_0, int P_1)
		{
			managerHandle[P_1++] = (byte)P_0;
			managerHandle[P_1++] = (byte)(P_0 >> 8);
			managerHandle[P_1++] = (byte)(P_0 >> 16);
			managerHandle[P_1++] = (byte)(P_0 >> 24);
		}
	}

	internal sealed class AssistantTree
	{
		//private static readonly int lastSession;

		//private static readonly int valuesHandle;

		//private static readonly int generatorCollection;

		//private static readonly int managerHandle;

		//private static readonly int colorList;

		//private static readonly int uriCollection;

		//private static readonly int lineToken;

		//private static readonly int urlList;

		//private static readonly int managerID;

		//private static readonly int reasonCollection;

		//private static readonly int urlHandle;

		//private static readonly int messageInitialized;

		//private static readonly int nextLog;

		//private static readonly int nameHeader;

		//private static readonly int windowDisposed;

		//private static readonly int containerList;

		//private static readonly int nextUserData;

		//private static readonly int firstManager;

		//private static readonly int previousOptions;

		//private static readonly int versionHandle;

		private static readonly ModuleHandle versionAvailable;

		static AssistantTree()
		{
			if ((object)typeof(MulticastDelegate) == null)
			{
				return;
			}
			versionAvailable = Assembly.GetExecutingAssembly().GetModules()[0].ModuleHandle;
			return;
			
		}

		public static void GenerateLine(int P_0, int P_1, int P_2)
		{
			Type typeFromHandle;
			ConstructorInfo constructorInfo;
			try
			{
				typeFromHandle = Type.GetTypeFromHandle(versionAvailable.ResolveTypeHandle(P_0));
				object methodFromHandle;
				if (P_2 == 16777215)
				{
					
				
					methodFromHandle = MethodBase.GetMethodFromHandle(versionAvailable.ResolveMethodHandle(P_1));
				}
				else
				{
					methodFromHandle = MethodBase.GetMethodFromHandle(versionAvailable.ResolveMethodHandle(P_1), versionAvailable.ResolveTypeHandle(P_2));
				}
				constructorInfo = (ConstructorInfo)methodFromHandle;
			}
			catch (Exception)
			{
				throw;
			}
			FieldInfo[] fields = typeFromHandle.GetFields(BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.GetField);
			foreach (FieldInfo fieldInfo in fields)
			{
				try
				{
					ParameterInfo[] parameters = constructorInfo.GetParameters();
					int num = parameters.Length + 1;
					Type[] array = new Type[num];
					array[0] = constructorInfo.DeclaringType.MakeByRefType();
					for (int j = 1; j < num; j++)
					{
						array[j] = parameters[j - 1].ParameterType;
					}
					while (true)
					{
						
						DynamicMethod dynamicMethod = new DynamicMethod(string.Empty, null, array, typeFromHandle, skipVisibility: true);
						ILGenerator iLGenerator = dynamicMethod.GetILGenerator();
						if (num > 0)
						{
							
							iLGenerator.Emit(OpCodes.Ldarg_0);
						}
						if (num > 1)
						{
							
							iLGenerator.Emit(OpCodes.Ldarg_1);
						}
						if (num > 2)
						{
							
							iLGenerator.Emit(OpCodes.Ldarg_2);
						}
						if (num > 3)
						{
							iLGenerator.Emit(OpCodes.Ldarg_3);
						}
						if (num > 4)
						{
							
							for (int k = 4; k < num; k++)
							{
								iLGenerator.Emit(OpCodes.Ldarg_S, k);
							}
							
						}
						iLGenerator.Emit(OpCodes.Call, constructorInfo);
						iLGenerator.Emit(OpCodes.Ret);
						Delegate value = dynamicMethod.CreateDelegate(typeFromHandle);
						fieldInfo.SetValue(null, value);
						break;
					}
				}
				catch (Exception)
				{
				}
			}
		
		}
	}

	internal sealed class NodeList
	{
		/*
		private static readonly int lastSession;

		private static readonly int valuesHandle;

		private static readonly int generatorCollection;

		private static readonly int managerHandle;

		private static readonly int colorList;

		private static readonly int uriCollection;

		private static readonly int lineToken;

		private static readonly int urlList;

		private static readonly int managerID;

		private static readonly int reasonCollection;

		private static readonly int urlHandle;

		private static readonly int messageInitialized;

		private static readonly int nextLog;

		private static readonly int nameHeader;

		private static readonly int windowDisposed;

		private static readonly int containerList;

		private static readonly int nextUserData;

		private static readonly int firstManager;

		private static readonly int previousOptions;

		private static readonly int versionHandle;
*/
		private static readonly ModuleHandle versionAvailable;
		
		static NodeList()
		{
			if ((object)typeof(MulticastDelegate) == null)
			{
				return;
			}
			
			versionAvailable = Assembly.GetExecutingAssembly().GetModules()[0].ModuleHandle;
		}

		[SpecialName]
		private int get_GenerateLine()
		{
			return 1;
		}

		public static void ExtractSymbol(int P_0, int P_1, int P_2)
		{
			Type typeFromHandle;
			MethodInfo methodInfo;
			try
			{
				typeFromHandle = Type.GetTypeFromHandle(versionAvailable.ResolveTypeHandle(P_0));
				object methodFromHandle;
				if (P_2 == 16777215)
				{
					methodFromHandle = MethodBase.GetMethodFromHandle(versionAvailable.ResolveMethodHandle(P_1));
				}
				else
				{
					methodFromHandle = MethodBase.GetMethodFromHandle(versionAvailable.ResolveMethodHandle(P_1), versionAvailable.ResolveTypeHandle(P_2));
				}
				methodInfo = (MethodInfo)methodFromHandle;
			}
			catch (Exception)
			{
				throw;
			}
			FieldInfo[] fields = typeFromHandle.GetFields(BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.GetField);
			foreach (FieldInfo fieldInfo in fields)
			{
				try
				{
					Delegate value;
					if (methodInfo.IsStatic)
					{
						
						value = Delegate.CreateDelegate(fieldInfo.FieldType, methodInfo);
					}
					else
					{
						ParameterInfo[] parameters = methodInfo.GetParameters();
						int num = parameters.Length + 1;
						Type[] array = new Type[num];
						if (methodInfo.DeclaringType.IsValueType)
						{
						
							array[0] = methodInfo.DeclaringType.MakeByRefType();
						}
						else
						{
							array[0] = typeof(object);
						}
						for (int j = 1; j < num; j++)
						{
							array[j] = parameters[j - 1].ParameterType;
						}
					
						DynamicMethod dynamicMethod = new DynamicMethod(string.Empty, methodInfo.ReturnType, array, typeFromHandle, skipVisibility: true);
						ILGenerator iLGenerator = dynamicMethod.GetILGenerator();
						iLGenerator.Emit(OpCodes.Ldarg_0);
						if (num > 1)
						{
							iLGenerator.Emit(OpCodes.Ldarg_1);
						}
						if (num > 2)
						{
							
							iLGenerator.Emit(OpCodes.Ldarg_2);
						}
						if (num > 3)
						{
							iLGenerator.Emit(OpCodes.Ldarg_3);
						}
						if (num > 4)
						{
							
							for (int k = 4; k < num; k++)
							{
								iLGenerator.Emit(OpCodes.Ldarg_S, k);
							}
						}
						OpCode opcode;
						if (!fieldInfo.IsFamilyOrAssembly)
						{
							
							opcode = OpCodes.Call;
						}
						else
						{
							opcode = OpCodes.Callvirt;
						}
						iLGenerator.Emit(opcode, methodInfo);
						iLGenerator.Emit(OpCodes.Ret);
						value = dynamicMethod.CreateDelegate(typeFromHandle);
					}
					fieldInfo.SetValue(null, value);
				}
				catch (Exception)
				{
				}
			}
		}
	}


	internal sealed class VectorTree
	{
		private static ResourceManager lastSession;

		private static CultureInfo valuesHandle;

		[EditorBrowsable(EditorBrowsableState.Advanced)]
		internal static ResourceManager ResourceManager
		{
			get
			{
				if (lastSession == null)
				{
				
					lastSession = WindowTree.OpenAssistant("PSProtector.VectorTree", StreamList.OpenAssistant(ViewResolver.OpenAssistant(typeof(VectorTree).TypeHandle)));
				}
				return lastSession;
			}
		}

	
		internal static CultureInfo Culture
		{
			get
			{
				return valuesHandle;
			}
			set
			{
				valuesHandle = value;
			}
		}

		internal VectorTree()
		{
		}
	}


	public static class StreamList
	{
		public static string lastSession;
		static StreamList()
		{
			//StreamList.lastSession;
			Console.WriteLine($"StreamList.lastSession { StreamList.lastSession }");
			StreamList.lastSession = "";
			Console.WriteLine($"StreamList.lastSession { StreamList.lastSession }");
			NodeList.ExtractSymbol(33554788, 167772473, 16777215);
		}
		public static string OpenAssistant(object P_0)
		{
			return "";
		}
		//public virtual extern Assembly Invoke(object P_0);

		//public extern StreamList(object P_0, IntPtr P_1);
	}

	public class WindowTree
	{
		public static WindowTree lastSession;
		static WindowTree()
		{
			WindowTree.lastSession = null;
			Console.WriteLine($"WindowTree.lastSession { WindowTree.lastSession }");
			PageList.GenerateLine(33554835, 167772516, 16777215);
		}

		public static void Invoke(string P_0, Assembly P_1)
		{
			return;
		}
		public static ResourceManager OpenAssistant(object P_0)
		{
			ResourceManager resmgr = new ResourceManager("MyApplication.MyResource", Assembly.GetExecutingAssembly()); 
			return resmgr;
		}
		public static ResourceManager OpenAssistant(string id, object P_0)
		{
			ResourceManager resmgr = new ResourceManager("MyApplication.MyResource", Assembly.GetExecutingAssembly()); 
			return resmgr;
		}
	}
	public class ViewResolver
	{
		public static ViewResolver lastSession;
		static ViewResolver()
		{
			//ViewResolver.lastSession;
			ViewResolver.lastSession = null;
			Console.WriteLine($"ViewResolver.lastSession { ViewResolver.lastSession }");
			NodeList.ExtractSymbol(33554831, 167772512, 16777215);
		}
		//public virtual extern Type Invoke(RuntimeTypeHandle P_0);
		public static string OpenAssistant(object P_0)
		{
			return "";
		}

	}
	public class ReferenceResolver
	{
		public static ReferenceResolver lastSession;
		static ReferenceResolver()
		{
			//ReferenceResolver.lastSession;
			ReferenceResolver.lastSession = null;
			Console.WriteLine($"ReferenceResolver.lastSession { ReferenceResolver.lastSession }");
			NodeList.ExtractSymbol(33554831, 167772512, 16777215);
		}
		//public virtual extern Exception Invoke(string P_0);
		public static void OpenAssistant(object P_0)
		{
			return;
		}

	}
	public class PanelManager
	{
		public static PanelManager lastSession;
		static PanelManager()
		{
			//PanelManager.lastSession;
			PanelManager.lastSession = null;
			Console.WriteLine($"PanelManager.lastSession { PanelManager.lastSession }");
			NodeList.ExtractSymbol(33554831, 167772512, 16777215);
		}
		//public virtual extern Exception Invoke(string P_0);
		public static string OpenAssistant(object P_0)
		{
			return "";
		}

	}
	public class AspectProvider
	{
		//internal delegate int AspectProvider(string P_0, string P_1, bool P_2);
		public static AspectProvider lastSession;
		static AspectProvider()
		{
			//AspectProvider.lastSession;
			AspectProvider.lastSession = null;
			Console.WriteLine($"AspectProvider.lastSession { AspectProvider.lastSession }");
			NodeList.ExtractSymbol(33554495, 167772193, 16777215);
		}
		//public virtual extern Exception Invoke(string P_0);
		public static int OpenAssistant(object P_0)
		{
			return 0;
		}
		public static int OpenAssistant(string text_1, string text_2, object P_0)
		{
			return 0;
		}
	}

	public class StreamDesigner
	{
		public  static StreamDesigner lastSession;
		static StreamDesigner()
		{
			//StreamDesigner.lastSession;
			StreamDesigner.lastSession = null;
			Console.WriteLine($"StreamDesigner.lastSession { StreamDesigner.lastSession }");
			NodeList.ExtractSymbol(33554786, 167772471, 16777215);
		}

		//public virtual extern int Invoke(object P_0);
		public static void OpenAssistant(object P_0)
		{
			return;
		}

	}


	public class IconScope
	{
		static  IconScope lastSession;
		static IconScope()
		{
			//IconScope.lastSession;
			IconScope.lastSession = null;
			Console.WriteLine($"IconScope.lastSession { IconScope.lastSession }");
			NodeList.ExtractSymbol(33554786, 167772471, 16777215);
		}

		//public extern IconScope(object P_0, IntPtr P_1);

		public static void OpenAssistant(object P_0)
		{
			return;
		}

	}
	internal sealed class WindowEventArgs
	{
		[StructLayout(LayoutKind.Sequential)]
		internal sealed class WindowResolver
		{
			internal IntPtr lastSession;

			internal IntPtr valuesHandle;

			internal IntPtr generatorCollection;

			internal IntPtr managerHandle;

			internal IntPtr colorList;

			internal IntPtr uriCollection;
		}

		internal delegate int StoreDictionary(IntPtr ProcessHandle, int ProcessInformationClass, WindowResolver ProcessInformation, uint ProcessInformationLength, out uint ReturnLength);

		internal delegate int DriveCollection(IntPtr ProcessHandle, int ProcessInformationClass, out uint debugPort, uint ProcessInformationLength, out uint ReturnLength);

		internal delegate int ResourceLayout();

		internal delegate void ReferenceEventArgs([MarshalAs(UnmanagedType.LPStr)] string lpOutputString);

		internal delegate int ActivityHelper(IntPtr hProcess, ref int pbDebuggerPresent);

		internal delegate int TemplateToken(IntPtr wnd, IntPtr lParam);

		internal delegate int ImageStream(TemplateToken lpEnumFunc, IntPtr lParam);

		//internal static uint lastSession;

		//internal static uint valuesHandle;

		//internal static int generatorCollection;

		//private static bool managerHandle;

		[DllImport("kernel32.dll", EntryPoint = "SetLastError", ExactSpelling = true)]
		internal static extern void InsertResource(uint P_0);

		[DllImport("kernel32.dll", EntryPoint = "CloseHandle", ExactSpelling = true)]
		internal static extern int AttachCondition(IntPtr P_0);

		[DllImport("kernel32.dll", EntryPoint = "OpenProcess", ExactSpelling = true)]
		internal static extern IntPtr ShowOutline(uint P_0, int P_1, uint P_2);

		[DllImport("kernel32.dll", EntryPoint = "GetCurrentProcessId", ExactSpelling = true)]
		internal static extern uint AddFunction();

		[DllImport("kernel32.dll", CharSet = CharSet.Auto, EntryPoint = "LoadLibrary", SetLastError = true)]
		internal static extern IntPtr CopyDeployment(string P_0);

		[DllImport("kernel32.dll", CharSet = CharSet.Ansi, EntryPoint = "GetProcAddress", ExactSpelling = true)]
		internal static extern StoreDictionary IncreasePackage(IntPtr P_0, string P_1);

		[DllImport("kernel32.dll", CharSet = CharSet.Ansi, EntryPoint = "GetProcAddress", ExactSpelling = true)]
		internal static extern DriveCollection DeleteTemplate(IntPtr P_0, string P_1);

		[DllImport("kernel32.dll", CharSet = CharSet.Ansi, EntryPoint = "GetProcAddress", ExactSpelling = true)]
		internal static extern ActivityHelper ConnectDevice(IntPtr P_0, string P_1);

		[DllImport("kernel32.dll", CharSet = CharSet.Ansi, EntryPoint = "GetProcAddress", ExactSpelling = true)]
		internal static extern ResourceLayout EnableProject(IntPtr P_0, string P_1);

		[DllImport("kernel32.dll", CharSet = CharSet.Ansi, EntryPoint = "GetProcAddress", ExactSpelling = true)]
		internal static extern ReferenceEventArgs PublishGroup(IntPtr P_0, string P_1);

		[DllImport("kernel32.dll", CharSet = CharSet.Ansi, EntryPoint = "GetProcAddress", ExactSpelling = true)]
		internal static extern ImageStream CloseQueue(IntPtr P_0, string P_1);

		private static int Print(IntPtr P_0, IntPtr P_1)
		{
			string[] array = new string[MethodOptions.CleanToolbar(2852)];
			array[MethodOptions.CleanToolbar(2856)] = EmulatorEditor.OpenAssistant(9307);
			string[] array2 = array;
			string text = SearchQueue(P_0);
			string[] array3 = array2;
			for (int i = MethodOptions.CleanToolbar(2860); i < array3.Length; i += MethodOptions.CleanToolbar(2876))
			{
				string text2 = array3[i];
				if (AspectProvider.OpenAssistant(text, text2, (byte)MethodOptions.CleanToolbar(2864) != 0) != 0)
				{
					continue;
				}
				
				
				return MethodOptions.CleanToolbar(2872);
				
			}
			return MethodOptions.CleanToolbar(2880);
		}

		[DllImport("user32.dll", CharSet = CharSet.Auto, EntryPoint = "GetClassName")]
		internal static extern int SelectQueue(IntPtr P_0, StringBuilder P_1, int P_2);

		internal static string SearchQueue(IntPtr P_0)
		{
			IconScope.OpenAssistant(260);
			StringBuilder sb = new StringBuilder(50); //string will be appended later
			StreamDesigner.OpenAssistant(sb);
			int val = 1;
			SelectQueue(P_0, sb, val);
			return PanelManager.OpenAssistant(sb);
		}

		internal static void AddMenu()
		{
			if (!ShowControl())
			{
				return;
			}
		
			//string text = "Debugger";
			//throw ReferenceResolver.OpenAssistant(VectorContext.OpenAssistant("{0} was found - this software cannot be executed under the {0}.", text));
			
		}

		internal static bool ShowControl()
		{
			try
			{
				/*if (ActivatorStack.OpenAssistant())
				{
					return true;
				}*/
				IntPtr intPtr = CopyDeployment("kernel32.dll");
				ResourceLayout resourceLayout = EnableProject(intPtr, "IsDebuggerPresent");
				/*if (resourceLayout != null && ImageSet.OpenAssistant(resourceLayout) != 0)
				{
					Console.WriteLine($"OpenAssistant worked");
				}*/
				uint num = AddFunction();
				uint num2 = 0;
				IntPtr intPtr2 = ShowOutline(1024u, 0, num);
				/*
				if (ViewService.OpenAssistant(intPtr2, IntPtr.Zero))
				{
					ActivityHelper activityHelper = ConnectDevice(intPtr, "CheckRemoteDebuggerPresent");
					if (activityHelper != null)
					{
						if (TextFileService.OpenAssistant(activityHelper, intPtr2, ref num2) == 0)
						{
							break;
						}
					}
					
					AttachCondition(intPtr2);
					
				}*/
				bool flag = false;
				try
				{
					AttachCondition(new IntPtr(305419896));
				}
				catch
				{
					flag = true;
				}
				
				if(flag){
					Console.WriteLine($"Flag { num2 }");
				}
				try
				{
					IntPtr intPtr3 = CopyDeployment("user32.dll");
					ImageStream imageStream = CloseQueue(intPtr3, "EnumWindows");
					if (imageStream != null)
					{
						bool managerHandle = false;
						//IconOptions.OpenAssistant(imageStream, Print, IntPtr.Zero);
						if (managerHandle)
						{
							return true;
						}
					}
				}
				catch
				{
				}
			}
			catch
			{
			}
			return false;
		}
	}

	public static  class PageList
	{
		/*
		private static readonly int lastSession;

		private static readonly int valuesHandle;

		private static readonly int generatorCollection;

		private static readonly int managerHandle;

		private static readonly int colorList;

		private static readonly int uriCollection;

		private static readonly int lineToken;

		private static readonly int urlList;

		private static readonly int managerID;

		private static readonly int reasonCollection;

		private static readonly int urlHandle;

		private static readonly int messageInitialized;

		private static readonly int nextLog;

		private static readonly int nameHeader;

		private static readonly int windowDisposed;

		private static readonly int containerList;

		private static readonly int nextUserData;

		private static readonly int firstManager;

		private static readonly int previousOptions;

		private static readonly int versionHandle;
		*/
		private static readonly ModuleHandle versionAvailable;
		

		static PageList()
		{
			if ((object)typeof(MulticastDelegate) == null)
			{
				return;
			}
				
			versionAvailable = Assembly.GetExecutingAssembly().GetModules()[0].ModuleHandle;
		
		}

		public static void GenerateLine(int P_0, int P_1, int P_2)
		{
			Type typeFromHandle;
			ConstructorInfo constructorInfo;
			try
			{
				typeFromHandle = Type.GetTypeFromHandle(versionAvailable.ResolveTypeHandle(P_0));
				object methodFromHandle;
				if (P_2 == 16777215)
				{
					
					methodFromHandle = MethodBase.GetMethodFromHandle(versionAvailable.ResolveMethodHandle(P_1));
				}
				else
				{
					methodFromHandle = MethodBase.GetMethodFromHandle(versionAvailable.ResolveMethodHandle(P_1), versionAvailable.ResolveTypeHandle(P_2));
				}
				constructorInfo = (ConstructorInfo)methodFromHandle;
			}
			catch (Exception)
			{
				throw;
			}
			FieldInfo[] fields = typeFromHandle.GetFields(BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.GetField);
			foreach (FieldInfo fieldInfo in fields)
			{
				try
				{
					ParameterInfo[] parameters = constructorInfo.GetParameters();
					int num = parameters.Length;
					Type[] array = new Type[num];
					for (int j = 0; j < num; j++)
					{
						array[j] = parameters[j].ParameterType;
					}
					while (true)
					{
						
						DynamicMethod dynamicMethod = new DynamicMethod(string.Empty, constructorInfo.DeclaringType, array, typeFromHandle, skipVisibility: true);
						ILGenerator iLGenerator = dynamicMethod.GetILGenerator();
						if (num > 0)
						{
							
							iLGenerator.Emit(OpCodes.Ldarg_0);
						}
						if (num > 1)
						{
							
							iLGenerator.Emit(OpCodes.Ldarg_1);
						}
						if (num > 2)
						{
							
							iLGenerator.Emit(OpCodes.Ldarg_2);
						}
						if (num > 3)
						{
							
							iLGenerator.Emit(OpCodes.Ldarg_3);
						}
						if (num > 4)
						{
							for (int k = 4; k < num; k++)
							{
								iLGenerator.Emit(OpCodes.Ldarg_S, k);
							}
							
						}
						iLGenerator.Emit(OpCodes.Newobj, constructorInfo);
						iLGenerator.Emit(OpCodes.Ret);
						Delegate value = dynamicMethod.CreateDelegate(typeFromHandle);
						fieldInfo.SetValue(null, value);
						break;
					}
				}
				catch (Exception)
				{
				}
			}
			
		}
	}

	public static class CompressionHelper
	{
	    public static byte[] CompressBytes(byte[] data)
	    {
	        byte[] compressArray = null;
	        try
	        {
	            using (MemoryStream memoryStream = new MemoryStream())
	            {
	                using (DeflateStream deflateStream = new DeflateStream(memoryStream, CompressionMode.Compress))
	                {
	                    deflateStream.Write(data, 0, data.Length);
	                }
	                compressArray = memoryStream.ToArray();
	            }
	        }
	        catch (Exception e)
	        {
	            Console.WriteLine($"[CompressBytes] failure on compression {e.Message} ");
	            throw e;
	        }
	        return compressArray;
	    }

	    public static byte[] DecompressBytes(byte[] data)
	    {
	        byte[] decompressedArray = null;
	        try
	        {
	            using (MemoryStream decompressedStream = new MemoryStream())
	            {
	                using (MemoryStream compressStream = new MemoryStream(data))
	                {
	                    using (DeflateStream deflateStream = new DeflateStream(compressStream, CompressionMode.Decompress))
	                    {
	                        deflateStream.CopyTo(decompressedStream);
	                    }
	                }
	                decompressedArray = decompressedStream.ToArray();
	            }
	        }
	        catch (Exception e)
	        {
	        	Console.WriteLine($"[CompressBytes] failure on Decompression {e.Message} ");
	            throw e;
	        }

	        return decompressedArray;
	    }

	    public static void TestFileCompress()
	    {
	    	int fileSize = 4096;
	    	string folder = @"C:\Temp\";
			// Filename
			string fileName = "BigTextFile.txt";
			string fileNameDecompressed = "BigTextFile-Decompressed.txt";
			// Fullpath. You can direct hardcode it if you like.
			string fullPath = folder + fileName;
			char c = 'z';
	    	string bigData = new string(c,fileSize);

	    	File.WriteAllText(fullPath, bigData);
	    	Console.WriteLine($"[TestFileCompression] Generated a Text file to be compressed { fullPath } . Size   { fileSize } bytes");

	    	Console.WriteLine($"[TestFileCompression] Compressing { fullPath } ...");
	    	string compressedFilePath  = CompressFile(fullPath);
	    	FileInfo compressedFileInfo = new FileInfo(compressedFilePath);
	    	long compressedFileSize = compressedFileInfo.Length;
	    	Console.WriteLine($"[TestFileCompression] Compression Completed. Output File { compressedFilePath } . New Size {compressedFileSize} . Diff {(fileSize-compressedFileSize)}");

	    	Console.WriteLine($"[TestFileCompression] Decompressing { compressedFilePath } ...");
	    	string decompresedFilePath = folder + fileNameDecompressed;
	    	DecompressFile(compressedFilePath,decompresedFilePath);
	    	FileInfo deCompressedFileInfo = new FileInfo(decompresedFilePath);
	    	long deCompressedFileSize = deCompressedFileInfo.Length;
	    	Console.WriteLine($"[TestFileCompression] Decompression Completed. Output File { decompresedFilePath } . New Size {deCompressedFileSize} . Diff {(deCompressedFileSize-compressedFileSize)}");

	    }

	    public static string CompressFile(string inputFile)
	    {
			FileInfo fileToBeDeflateZipped = new FileInfo(inputFile);
			string outFile = string.Concat(fileToBeDeflateZipped.FullName, ".cmp");
			FileInfo deflateZipFileName = new FileInfo(outFile);
			 
			using (FileStream fileToBeZippedAsStream = fileToBeDeflateZipped.OpenRead())
			{
			    using (FileStream deflateZipTargetAsStream = deflateZipFileName.Create())
			    {
			        using (DeflateStream deflateZipStream = new DeflateStream(deflateZipTargetAsStream, CompressionMode.Compress))
			        {
			            try
			            {
			                fileToBeZippedAsStream.CopyTo(deflateZipStream);
			            }
			            catch (Exception ex)
			            {
			                Console.WriteLine(ex.Message);
			            }
			        }
			    }
			}
			return outFile;
	    } 	
	    public static string DecompressFile(string inputFile, string outFile)
	    {
	    	FileInfo deflateZipFileName = new FileInfo(inputFile);
	    	//string outFile = inputFile.Replace(".cmp", "").Replace(".zip", "").Replace(".7z", "")
			using (FileStream fileToDecompressAsStream = deflateZipFileName.OpenRead())
			{
			    using (FileStream decompressedStream = File.Create(outFile))
			    {
			        using (DeflateStream decompressionStream = new DeflateStream(fileToDecompressAsStream, CompressionMode.Decompress))
			        {
			            try
			            {
			                decompressionStream.CopyTo(decompressedStream);
			            }
			            catch (Exception ex)
			            {
			                Console.WriteLine(ex.Message);
			            }
			        }
			    }
			}
			return outFile;
		}
	}
}

