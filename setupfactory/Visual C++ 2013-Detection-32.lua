function isVC2013x86_Installed()
	
	--Make sure OS is not 64-bit (x64).
	if (System.Is64BitOS()) then
		SetupData.WriteToLogFile("Info\tVisual C++ 2013 (32-bit) Module: os is 64-bit,exit.\r\n",true);
		return true;
	end

    -- Write to logfile that detection has started.
	SetupData.WriteToLogFile("Info\tVisual C++ 2013 (32-bit) Module: Detection script started.\r\n",true);
	-- Get the state of the runtime
	install_state = MSI.QueryProductState("{F8CFEB22-A2E7-3971-9EDA-4B11EDEFC185}");
	-- Is it instlled
	if (install_state == INSTALLSTATE_DEFAULT) then
		SetupData.WriteToLogFile("Info\tVisual C++ 2013 (32-bit) Module: Visual C++ 2013 runtime detected.\r\n",true);
		return true;
	end
	
	-- If we got here it's not installed
	SetupData.WriteToLogFile("Info\tVisual C++ 2013 (32-bit) Module: Visual C++ 2013 runtime not installed.\r\n",true);
	return false
end