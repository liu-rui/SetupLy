-- Check to see if this is a valid operating system for VC 2013 x86
function isValidOS()
	SetupData.WriteToLogFile("Info\tVisual C++ 2013 (32-bit) Module: Entering compatible OS detection.\r\n",true);

	local tblOSInfo = System.GetOSVersionInfo();
	
	-- Failure check for less than Windows XP
	local nMajorVersion = String.ToNumber(tblOSInfo.MajorVersion);
	local nMinorVersion = String.ToNumber(tblOSInfo.MinorVersion);
	if ((nMajorVersion < 5) or ((tblOSInfo.MajorVersion == "5") and (nMinorVersion < 1))) then
		SetupData.WriteToLogFile("Info\tVisual C++ 2013 (32-bit) Module: Operating systems less than Windows XP SP3 are not supported.\r\n",true);
		return false;
	end
	
	-- Check Windows XP SP3 or later and not Starter Edition.
	if ((tblOSInfo.MajorVersion == "5") and (tblOSInfo.MinorVersion == "1")) then
		-- Check service pack.
		if (tblOSInfo.ServicePackMajor < 3) then
			SetupData.WriteToLogFile("Info\tVisual C++ 2013 (32-bit) Module: Windows XP SP3+ required.\r\n",true);
			return false;
		else
			-- Check to make sure not Starter Edition.
			if (tblOSInfo.StarterEdition) then
				SetupData.WriteToLogFile("Info\tVisual C++ 2013 (32-bit) Module: Windows XP Starter Edition not supported.\r\n",true);
				return false;
			else
				-- Windows XP SP3+ and not Starter Edition acceptable.
				return true;
			end
		end
	end
	
	-- Check Windows Server 2003 SP2 or later
	if ((tblOSInfo.MajorVersion == "5") and (tblOSInfo.MinorVersion == "2") and (not tblOSInfo.Server2003R2)) then
		-- Check service pack.
		if (tblOSInfo.ServicePackMajor < 2) then
			SetupData.WriteToLogFile("Info\tVisual C++ 2013 (32-bit) Module: Windows Server 2003 SP2+ required.\r\n",true);
			return false;
		else
			-- Windows Server 2003 SP2+ acceptable
			return true;
		end
	end
	
	-- Check Windows Server 2003 R2 or later
	if ((tblOSInfo.MajorVersion == "5") and (tblOSInfo.MinorVersion == "2") and (tblOSInfo.Server2003R2)) then
		-- Windows Server 2003 R2 acceptable.
		return true;
	end
	
	-- Check Windows Vista / Windows Server 2008 SP2+ or later.
	if ((tblOSInfo.MajorVersion == "6") and (tblOSInfo.MinorVersion == "0")) then
		if (tblOSInfo.ServicePackMajor < 2) then
			SetupData.WriteToLogFile("Info\tVisual C++ 2013 (32-bit) Module: Windows Vista SP2+ / Windows Server 2008 SP2+ required.\r\n",true);
			return false;
		else
			-- Check to make sure not Starter Edition.
			if (tblOSInfo.StarterEdition) then
				SetupData.WriteToLogFile("Info\tVisual C++ 2013 (32-bit) Module: Windows Vista Starter Edition not supported.\r\n",true);
				return false;
			else
				-- Windows Vista SP2+ / Windows Server 2008 SP2+ acceptable.
				return true;
			end
		end
	end
	
	-- Check Windows 7 / (no x86 Windows Server 2008 R2 version)
	if ((tblOSInfo.MajorVersion == "6") and (tblOSInfo.MinorVersion == "1") and (tblOSInfo.ProductType == 1)) then
		-- Windows 7 acceptable.
		return true;
	end

	if (tblOSInfo.MajorVersion >= "6") then
		return true;
	end
	
	return false
end

-- Variables used in the installation actions:
local strMessage = [[Setup has detected that your Visual C++ 2013 runtime files are out of date.
Click OK to install this technology now or Cancel to abort the setup.]];
local strDialogTitle = "Technology Required";
local bShowUserPrompt = true; -- set this to true to ask user whether to install the module
local bRunInstallFile = true; -- The default of whether or not to run the setup
local bRequirementFail = false;
local tbRequirementFailStrings = {};
local strAbortQuestion = [[

Due to this requirement failure, it is recommended that you abort the install.

Click OK to abort the setup, or Cancel to continue with the application install.]];
local strRequirementString = [[Visual C++ 2013 runtime cannot be installed due to the following requirements:

]];
local strRuntimeSupportFolder = SessionVar.Expand("%TempLaunchFolder%\\vc2013x86");
local strExtractInstallerToPath = strRuntimeSupportFolder.."\\vcredist_x86.exe";
local strMessageFail = ""; 
local strCmdArgs = "";
local bSilentMode = false; -- Should this be silent?;
local bVital = true; -- Is this vital?

-- Output to the log that the installation script has started.
SetupData.WriteToLogFile("Success\tVisual C++ 2013 (32-bit) Module: Installation script started.\r\n", true);

------------------------------------------------------------------------------------------------------------
---- Requires Admin permissions                                                                         ----
------------------------------------------------------------------------------------------------------------

-- Check if the user is logged in with administrative permissions.
-- If the user doesn't have admin permissions, set the failure variable
-- and failure string table.
tbUserInfo = System.GetUserInfo();
if (tbUserInfo ~= nil) then
	if (not tbUserInfo.IsAdmin) then
		bRequirementFail = true;
		strTemp ="- You do not have the required administrative permissions to install the Visual C++ runtime.";
		Table.Insert(tbRequirementFailStrings, Table.Count(tbRequirementFailStrings) + 1, strTemp);
	end
end

------------------------------------------------------------------------------------------------------------
---- Requires MSI 3.1                                       						----
------------------------------------------------------------------------------------------------------------
-- Get the operating system name.
local strOSName = System.GetOSName();
local strMSIVersion = MSI.GetMSIVersion();

-- need MSI 3.1
if (String.CompareFileVersions(strMSIVersion,"3.1.4000.2435") == -1) or (not strMSIVersion) then
	-- MSI 3.1 is not installed
	bRequirementFail = true;
	strTemp = "- The Visual C++ 2013 runtime module requires Windows Installer 3.0. Please install this technology then run the setup again.";
	Table.Insert(tbRequirementFailStrings, Table.Count(tbRequirementFailStrings) + 1, strTemp);
end


------------------------------------------------------------------------------------------------------------
---- Operating System Check   
-- Windows 7
-- Windows Vista Service Pack 2 (SP2) or later (all editions except Starter Edition)
-- Windows Server 2008 Service Pack 2 (SP2) or later
-- Windows XP with Service Pack 3 (SP3) (all editions except Starter Edition)
-- Windows Server 2003 R2 or later (all editions)
-- Windows Server 2003 Service Pack 2 (SP2) or later (all editions)                                             
------------------------------------------------------------------------------------------------------------


-- Check if OS is valid.
if (not isValidOS()) then
	bRequirementFail = true;
	--VC 2013 isn't supported on the OS that was detected.
	strTemp = "- The Visual C++ 2013 runtime cannot be installed on this operating system. Requires Windows 7, Windows Vista SP2+, Windows Server 2008 SP2+, Windows XP SP3+, Windows Server 2003 SP2, or Windows Server 2003 R2.";
	Table.Insert(tbRequirementFailStrings, Table.Count(tbRequirementFailStrings) + 1, strTemp);
end


-- Check if the dialog should be displayed asking whether or not they want to install the module.
-- if (bShowUserPrompt) then
-- 	local nDialogResult = Dialog.Message(strDialogTitle,strMessage,MB_OKCANCEL,MB_ICONEXCLAMATION);
-- 	if (nDialogResult == IDOK) then
-- 		-- The user chose to install the module.
-- 		bRunInstallFile = true;
-- 	else
-- 		-- The user chose not to install the module.
-- 		bRunInstallFile = false;
-- 	end
-- end
bRunInstallFile = true;

if (not bRequirementFail) then
	-- Check if the user wants to install the runtime.
	if (bRunInstallFile) then
		-- The following are command line options that can be used when launching the install file vcredist_x86.exe.
		---------------------------
		--	/l <logname.txt> :Name of verbose msi log
		--	/lang <xxxx>     :4-digit language code
		--	/q               :Quiet install mode
		--	/qu              :Quiet uninstall mode
		--	/?               :Show the Usage dialog

		if (bSilentMode) then
			-- Passing quite mode, and no restart.
			strCmdArgs = strCmdArgs.."/q";
		end

		-- Output to the log that the Visual C++ installation is being launched.
		SetupData.WriteToLogFile("Info\tVisual C++ 2013 (32-bit) Module: Visual C++ runtime installation file "..strExtractInstallerToPath.." is being launched.\r\n");
		local nResult = File.Run(strExtractInstallerToPath, strCmdArgs, "", SW_SHOWNORMAL, true);
		if (nResult == 3010) then
			-- VC 2013 install indicated that it needs reboot to be complete
			-- Set Setup Factory's reboot variable so that the reboot is just
			-- performed at the end of the install.
			_NeedsReboot = true;
		elseif (nResult == 1602) then
			-- The user canceled the setup program.
			strMessageFail = [[You have cancelled the installation for the Visual C++ 2013 runtime. It is not recommended that you continue with the setup.

Click OK to abort the setup, or Cancel to continue with the application install.]];
		elseif (nResult == 1603) then
			-- A fatal error occurred during installation.
			strMessageFail = [[A fatal error occurred during installation of the Visual C++ 2013 runtime. It is not recommended that you continue with the setup.

Click OK to abort the setup, or Cancel to continue with the application install.]];
		elseif (nResult == 1605) then
			-- This action is only valid for products that are currently installed.
			strMessageFail = [[Error during installation of the Visual C++ 2013 runtime. This action is valid only for products that are currently installed. It is not recommended that you continue with the setup.

Click OK to abort the setup, or Cancel to continue with the application install.]];
		elseif (nResult == 1636) then
			-- The patch package could not be opened or the patch was not applicable to the Visual C++ 2013 runtime.
			strMessageFail = [[The patch package could not be opened or the patch was not applicable to the Visual C++ 2013 runtime. It is not recommended that you continue with the setup.

Click OK to abort the setup, or Cancel to continue with the application install.]];
		elseif (nResult == 1639) then
			-- Invalid command line argument.
			strMessageFail = [[An invalid command line argument was passed to the Visual C++ 2013 runtime installation. It is not recommended that you continue with the setup.

Click OK to abort the setup, or Cancel to continue with the application install.]];
		elseif (nResult == 1643) then
			-- The patch package is not permitted by system policy.
			strMessageFail = [[The Visual C++ 2013 patch package is not permitted by system policy. It is not recommended that you continue with the setup.

Click OK to abort the setup, or Cancel to continue with the application install.]];
		elseif (nResult == 0) then
			-- The setup was successful, so do nothing.
			SetupData.WriteToLogFile("Success\tVisual C++ 2013 (32-bit) Module: Visual C++ 2013 runtime installed.\r\n");
		else
			-- The setup program was not completed successfully.
			strMessageFail = [[An unknown error occurred during the installation of the Visual C++ 2013 runtime. It is not recommended that you continue with the setup.

Click OK to abort the setup, or Cancel to continue with the application install.]];
			strMessageFail = strMessageFail..nResult.."\r\n";
		end

		-- Check to see if an error message was generated.
		if (strMessageFail ~= "") then
			-- Display the error notification dialog.
			
			-- Output to the log error message.
			SetupData.WriteToLogFile("Error\tVisual C++ 2013 (32-bit) Module: Dialog error shown- "..strMessageFail..".\r\n");
			
			if (bShowUserPrompt) then
				nDialogResult = Dialog.Message("Visual C++ 2013 Runtime Installation" ,strMessageFail,MB_OKCANCEL,MB_ICONEXCLAMATION);
				if (nDialogResult == IDOK) then
					bAbortInstall = true;
				end
			end
		end
	
		-- Delete the run time installer file and remove the temp folder
		File.Delete(strExtractInstallerToPath);
		Folder.Delete(strRuntimeSupportFolder);
		
		-- If the user chose to abort the install after the failure of install, exit the setup.
		if (bAbortInstall) then
			-- Output to the log that the user chose to abort the setup after failure.
			SetupData.WriteToLogFile("Error\tVisual C++ 2013 (32-bit) Module: User chose to abort setup after Visual C++ 2013 install failure. Exiting setup.\r\n");
			Application.Exit(EXIT_REASON_USER_ABORTED);	
		end
		
	else
		-- The user chose not to install the runtime so delete the run time installer file,
		-- remove the temp folder and then exit the setup.
		
		-- Output to the log that the user chose to abort the setup.
		SetupData.WriteToLogFile("Error\tVisual C++ 2013 (32-bit) Module: User chose to abort setup. Exiting setup.\r\n");
		
		File.Delete(strExtractInstallerToPath);
		Folder.Delete(strRuntimeSupportFolder);
		if (bVital) then
			Application.Exit(EXIT_REASON_USER_ABORTED);
		else
			Application.ExitScript();
		end
	end
else
-- A requirement failed

	-- If the user didn't cancel...
	if (bRunInstallFile) then 
		-- One or more of the requirements failed. Notify the user and ask if they wish
		-- to abort the installation.
		strFullErrorString = Table.Concat(tbRequirementFailStrings, "\r\n", 1, TABLE_ALL);
		nDialogResult = Dialog.Message("Notice", strRequirementString..strFullErrorString..strAbortQuestion, MB_OKCANCEL, MB_ICONINFORMATION, MB_DEFBUTTON1);
		
		-- Output the requirement failure string to the log.
		SetupData.WriteToLogFile("Error\tVisual C++ 2013 (32-bit) Module: Requirement failure dialog: "..strFullErrorString.."\r\n");
		
		-- Delete the runtime installer file and remove the temp folder.
		File.Delete(strExtractInstallerToPath);
		Folder.Delete(strRuntimeSupportFolder);
		
		-- The user chose to abort the install due to the requirement failure of Visual C++ 2013.
		if (nDialogResult == IDOK) then
		
			-- Output to the log that the user chose to abort the install due to requirement failure.
			SetupData.WriteToLogFile("Error\tVisual C++ 2013 (32-bit) Module: User aborted setup due to requirement failure. Exiting setup.\r\n");
		
			-- Abort the install.
			Application.Exit(EXIT_REASON_USER_ABORTED);
		end
	else
		-- The user chose not to install the runtime so delete the run time installer file,
		-- remove the temp folder and then exit the setup.
		
		-- Output to the log that the user chose to abort the setup.
		SetupData.WriteToLogFile("Error\tVisual C++ 2013 (32-bit) Module: User chose to abort setup. Exiting setup.\r\n");
		
		File.Delete(strExtractInstallerToPath);
		Folder.Delete(strRuntimeSupportFolder);
		
		if (bVital) then
			Application.Exit(EXIT_REASON_USER_ABORTED);
		else
			Application.ExitScript();
		end
	
	end
end

-- Output to the log that the installation script has finished.
SetupData.WriteToLogFile("Success\tVisual C++ 2013 (32-bit) Module: Installation script finished.\r\n");