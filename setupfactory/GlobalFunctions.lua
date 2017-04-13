function SetBrowserVersion()
	if System.Is64BitOS () then
		SetBrowserVersionFor64();
	else
		SetBrowserVersionFor32();
	end	
end

function SetBrowserVersionFor32()
	local version = "11000";
	Registry.SetValue(HKEY_LOCAL_MACHINE, 
		"Software\\Wow6432Node\\Microsoft\\Internet Explorer\\MAIN\FeatureControl\\FEATURE_BROWSER_EMULATION", 
		SessionVar.Get("%ExeFileName%"), 
		version,
		REG_DWORD);
	SetupData.WriteToLogFile("SetBrowserVersionFor32 \r\n");
end

function SetBrowserVersionFor64()
	Registry.SetValue(HKEY_LOCAL_MACHINE, 
		"Software\\Microsoft\\Internet Explorer\\Main\\FeatureControl\\FEATURE_BROWSER_EMULATION", 
		SessionVar.Get("%ExeFileName%"), 
		"11000",
		REG_DWORD);
	SetupData.WriteToLogFile("SetBrowserVersionFor64 \r\n");
end 

function closeApp()
    file_to_check_for = String.Lower(SessionVar.Get("%ProcessFileName%"));
    processes = System.EnumerateProcesses();

    for j, file_path in pairs(processes) do
        file = String.SplitPath(file_path);
        if (String.Lower(file.Filename..file.Extension)) == file_to_check_for then
            System.TerminateProcess(j);
        end
    end
end