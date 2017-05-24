function isDotNet_Installed()
	-- .Net 4 Reg Key
	local DotNet_Key = "SOFTWARE\\Microsoft\\NET Framework Setup\\NDP\\v4\\Full";
	--Check to see if the registry key exists
	local DotNet_Registry = Registry.DoesKeyExist(HKEY_LOCAL_MACHINE, DotNet_Key);
		
	if (DotNet_Registry == false) then
		-- The registry key does not exist
		-- Run the .NET Installation script
		-- Output to the log file that .NET could not be found, so it will be installed.
		SetupData.WriteToLogFile("Info\t.NET 4 Module: No version of .NET 4.5.2 was found. .NET 4.5.2 will be installed.\r\n", true);
		return false;
	else -- The key does exist

		-- Get the .NET install success value from the registry
		local DotNet_Install_Success = Registry.GetValue(HKEY_LOCAL_MACHINE, DotNet_Key, "Install", true);

		if (DotNet_Install_Success == "1") then
			-- Check the version key.
			local DotNet_Install_Version = Registry.GetValue(HKEY_LOCAL_MACHINE, DotNet_Key, "Release", true);			
			SetupData.WriteToLogFile("current .net framework version:"..DotNet_Install_Version);
			-- Compare the returned value against the needed value
			Compare = String.CompareFileVersions(DotNet_Install_Version, "379893");
							
			if (Compare == 0 or Compare == 1) then
				-- .NET version 4 is installed already
				SetupData.WriteToLogFile("Info\t.NET 4.5.2 Module: .NET version 4.5.2 is installed already\r\n", true);
				return true;
			else 	
				SetupData.WriteToLogFile("Info\t.NET 4 Module: A lesser version of .NET 4.5.2 was found on the users system.\r\n", true);
				return false;
			end
		else
			-- The success value wasn't found
			-- Run the .NET Installation script
			-- Output to the log file that .NET could not be found, so it will be installed.
			SetupData.WriteToLogFile("Info\t.NET 4 Module: No version of .NET 4.5.2 was found. .NET 4.5.2 will be installed.\r\n", true);
			return false;
		end
	end
	return false;
end
