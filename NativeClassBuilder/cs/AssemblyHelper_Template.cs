
using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Globalization;
using System.Management.Automation.Host;
using System.Security;
using System.Reflection;
using System.Runtime.InteropServices;
using System.IO;
using System.Security.Cryptography;

namespace __NAMESPACE_NAME_PLACEHOLDER__
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
					while (true)
					{
						switch (3)
						{
						case 0:
							continue;
						}
						break;
					}
					if (1 == 0)
					{
						/*OpCode not supported: LdMemberToken*/;
					}
					lastSession[num] = opCode;
				}
				else
				{
					if ((num & 0xFF00) != 65024)
					{
						continue;
					}
					while (true)
					{
						switch (3)
						{
						case 0:
							continue;
						}
						break;
					}
					valuesHandle[num & 0xFF] = opCode;
				}
			}
			while (true)
			{
				switch (1)
				{
				case 0:
					break;
				default:
					return;
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
				while (true)
				{
					switch (2)
					{
					case 0:
						continue;
					}
					break;
				}
				if (1 == 0)
				{
					/*OpCode not supported: LdMemberToken*/;
				}
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
				while (true)
				{
					switch (1)
					{
					case 0:
						continue;
					}
					break;
				}
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
				switch (4)
				{
				case 0:
					continue;
				}
				if (1 == 0)
				{
					/*OpCode not supported: LdMemberToken*/;
				}
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
				while (true)
				{
					switch (6)
					{
					case 0:
						continue;
					}
					break;
				}
				if (1 == 0)
				{
					/*OpCode not supported: LdMemberToken*/;
				}
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
						while (true)
						{
							switch (1)
							{
							case 0:
								continue;
							}
							break;
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


}