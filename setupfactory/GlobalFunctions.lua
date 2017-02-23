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

function SetIMDNSInfo()
	local hostFileName = SessionVar.Expand("%WindowsFolder%\\System32\\drivers\\etc\\hosts");
	local imDns = SessionVar.Get("%IMDNS%");
	local imIp = SessionVar.Get("%IMIP%");

	SetupData.WriteToLogFile("SetIMDNSInfo will write "..hostFileName.."; IMDNS:"..imDns.." IMIP:"..imIp..".\r\n");

	if File.DoesExist (hostFileName)  then
		local content = TextFile.ReadToString(hostFileName);	

		if String.Find(content , imIp.."	"..imDns) ~= -1 then
			SetupData.WriteToLogFile("SetIMDNSInfo DNS mapper existed.\r\n");
			return;	
		end 
	end
	Shell.Execute(SessionVar.Expand("%AppFolder%\\SetIMDNSInfo.bat") , "open","","",SW_HIDE); 
	SetupData.WriteToLogFile("SetIMDNSInfo writed "..hostFileName.."; IMDNS:"..imDns.." IMIP:"..imIp..".\r\n");
end