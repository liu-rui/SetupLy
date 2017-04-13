function isVC2013x64_Installed()
		--Make sure OS is  64-bit (x64).
	if (not System.Is64BitOS()) then
		SetupData.WriteToLogFile("Info\tVisual C++ 2013 (64-bit) Module: os is not 64-bit,exit.\r\n",true);
		return true;
	end

    -- Write to logfile that detection has started.
	SetupData.WriteToLogFile("Info\tVisual C++ 2013 (64-bit) Module: Detection script started.\r\n",true);
	-- Get the state of the runtime
	install_state = MSI.QueryProductState("{A749D8E6-B613-3BE3-8F5F-045C84EBA29B}");
	-- Is it instlled
	if (install_state == INSTALLSTATE_DEFAULT) then
		SetupData.WriteToLogFile("Info\tVisual C++ 2013 (64-bit) Module: Visual C++ 2013 runtime detected.\r\n",true);
		return true;
	end
	
	-- If we got here it's not installed
	SetupData.WriteToLogFile("Info\tVisual C++ 2013 (64-bit) Module: Visual C++ 2013 runtime not installed.\r\n",true);
	return false
end