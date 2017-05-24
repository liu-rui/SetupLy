
-- Check to see if this is a valid operating system for .NET 4.5.2
function isValidDotNet4OS()
	SetupData.WriteToLogFile("Info\t.NET 4.5.2.5 Module: Entering compatible OS detection.\r\n",true);

	local tblOSInfo = System.GetOSVersionInfo();
	local strOSName = System.GetOSName();
	local b64BitOs = System.Is64BitOS();

	
	-- Check Windows XP SP3
	if (tblOSInfo.MajorVersion == "5") and (tblOSInfo.MinorVersion == "1") then
		-- Check service pack:
		if (tblOSInfo.ServicePackMajor < 3) then
			SetupData.WriteToLogFile("Info\t.NET 4.5.2 Module: Windows XP SP3+ required.\r\n",true);
			return false;
		else
			-- Windows XP SP3+ acceptable
			return true;
		end
	end
	
	-- Check Windows Server 2003 SP2/Windows XP Professional x64 Edition SP2
	if (tblOSInfo.MajorVersion == "5") and (tblOSInfo.MinorVersion == "2") then
		-- Check service pack:
		if (tblOSInfo.ServicePackMajor < 2) then
			SetupData.WriteToLogFile("Info\t.NET 4.5.2 Module: Windows Server 2003 SP2+/Windows XP Professional x64 Edition SP2+ required.\r\n",true);
			return false;
		else
			-- Windows Server 2003 SP2+/Windows XP Professional x64 Edition SP2+ acceptable
			return true;
		end
	end
	
	-- Check Windows Vista SP1
	if ((tblOSInfo.MajorVersion == "6") and (tblOSInfo.MinorVersion == "0") and (tblOSInfo.ProductType == 1)) then
		-- Check service pack:
		if (tblOSInfo.ServicePackMajor < 1) then
			SetupData.WriteToLogFile("Info\t.NET 4.5.2 Module: Windows Vista SP1+ required.\r\n",true);
			return false;
		else
			-- Windows Vista SP1+ acceptable
			return true;
		end
	end
	
	-- Check Windows Server 2008
	if ((tblOSInfo.MajorVersion == "6") and (tblOSInfo.MinorVersion == "0") and (tblOSInfo.ProductType ~= 1)) then
		return true;
	end
	
	-- Check Windows 7 / Windows Server 2008 R2
	if ((tblOSInfo.MajorVersion == "6") and (tblOSInfo.MinorVersion == "1")) then
		return true;
	end
		
	return false;
end


if(not isDotNet_Installed())then
	-- Variables used in the installation actions:
	local strMessage = [[Setup has detected that your Microsoft .NET run-time files are out of date.
Click OK to install this technology now or Cancel to abort the setup.]];
	local strDialogTitle = "Technology Required";
	local bShowUserPrompt = true; -- set this to true to ask user whether to install the module
	local bRunInstallFile = true; -- The default of whether or not to run the setup
	local bRequirementFail = false;
	local tbRequirementFailStrings = {};
	local strAbortQuestion = [[

Due to this requirement failure, it is recommended that you abort the install.

Click OK to abort the setup, or Cancel to continue with the application install.]];
	local strRequirementString = [[.NET 4.5.2 cannot be installed due to the following requirements:

]];
	local strRuntimeSupportFolder = SessionVar.Expand("%TempLaunchFolder%\\dotnet452");
	local strExtractInstallerToPath = strRuntimeSupportFolder.."\\NDP452-KB2901907-x86-x64-AllOS-ENU.exe";
	local strMessageFail = "";
	local strCmdArgs = "";
	local bSilentMode = false; -- Should this be silent?;
	local bVital = true; -- Is .Net 4.5.2 vital?
	
	-- Output to the log that the .NET installation script has started.
	SetupData.WriteToLogFile("Success\t.NET 4.5.2.5 Module: Installation script started.\r\n", true);
	
	------------------------------------------------------------------------------------------------------------
	---- Requires Internet Explorer 6.0 SP1 or greater  (6.00.2800.1106)                                    ----
	------------------------------------------------------------------------------------------------------------	
	
	-- Read the version of Internet Explorer (if installed).
	strIEVersion = Registry.GetValue(HKEY_LOCAL_MACHINE, "Software\\Microsoft\\Internet Explorer", "Version", false);
	
	-- If Internet Explorer Version is less than 6.00.2800.1106 , or cannot be found,
	-- set the failure variable and failure string table.
	if ((String.CompareFileVersions(strIEVersion, "6.00.2800.1106")== -1) or (strIEVersion == "")) then
		bRequirementFail = true;
		strTemp = "- .NET 4.5.2 requires Internet Explorer version 6.0 SP1 or greater.";
		Table.Insert(tbRequirementFailStrings, Table.Count(tbRequirementFailStrings) + 1, strTemp);
	end
	
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
			strTemp ="- You do not have the required administrative permissions to install .NET 4.5.2.";
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
		strTemp = "- The .NET 4.5.2 runtime module requires Windows Installer 3.1. Please install this technology then run the setup again.";
		Table.Insert(tbRequirementFailStrings, Table.Count(tbRequirementFailStrings) + 1, strTemp);
	end
	
	------------------------------------------------------------------------------------------------------------
	---- Operating System Check        
	--Windows Server 2003;  (SP2)
	--Windows XP            (SP3)  
	--Windows Vista         (SP1)
	--Windows Server 2008
	--Windows 7
	--Windows Server 2008 R2                                                 
	------------------------------------------------------------------------------------------------------------
	
	-- Check if OS is valid.
	if (not isValidDotNet4OS()) then
		bRequirementFail = true;
		--.NET 4.5.2 isn't supported on the OS that was detected.
		strTemp = "- .NET 4.5.2 cannot be installed on this operating system. Requires Windows XP SP3, Windows Server 2003 SP2, Windows XP Professional x64 Edition SP2, Windows Server 2008, Windows Vista SP1, Windows Server 2008 R2 or Windows 7.";
		Table.Insert(tbRequirementFailStrings, Table.Count(tbRequirementFailStrings) + 1, strTemp);
	end

	
	-- Check if the dialog should be displayed asking whether or not they want to install the module.
	--if(bShowUserPrompt)then
	--	local nDialogResult = Dialog.Message(strDialogTitle,strMessage,MB_OKCANCEL,MB_ICONEXCLAMATION);
	--	if(nDialogResult == IDOK)then
	--		-- The user chose to install the module.
	--		bRunInstallFile = true;
	--	else
	--		-- The user chose not to install the module.
	--		bRunInstallFile = false;
	--	end
	--end
	bRunInstallFile = true;
	
	if (not bRequirementFail) then
		-- Check if the user wants to install the runtime.
		if(bRunInstallFile)then
			-- The following are command line options that can be used when launching the install file dotNetFx40_Full_x86_x64.exe.
			-- /q  - Sets quiet mode.
			-- /norestart - Prevents the Setup program from rebooting automatically. (Redistributable installer returns ERROR_SUCCESS_REBOOT_REQUIRED (3010) if a reboot is required.)
			-- /repair - Repairs all .NET Framework 4 components that are installed.
			-- /LCID - Installs the language pack specified by lcid and forces the displayed UI to be shown in that language (unless in quiet mode).
			-- /passive - Displays the progress bar to indicate that installation is in progress, but does not display any prompts or errors to the user. Error handling must be handled by the setup program.
			-- /showfinalerror - Sets passive mode, but displays errors if the installation is not successful. This option requires user interaction if the installation is not successful.
			-- /promptrestart - In passive mode, if the setup program requires a reboot to complete, it prompts the user. This option requires user interaction if a reboot is required.
			-- /CEIPConsent - Overwrites the default behavior and sends anonymous feedback to Microsoft to improve future deployment experiences. This option can be used only if the application Setup program prompts for consent and if the user grants permission to send anonymous feedback to Microsoft.
			-- /chainingpackagePackageName - Specifies the name of the executable that is doing the chaining. This information is sent to Microsoft as anonymous feedback to help improve future deployment experiences. If the package name includes spaces, use double quotation marks as delimiters; for example: /chainingpackage "Chaining Product". For an example of a chaining package, see Getting Progress Information from an Installation Package in the MSDN Library.
			--/? - Displays this list of options.


			if (bSilentMode) then
				-- Passing quite mode, and no restart.
				strCmdArgs = strCmdArgs.."/q /norestart ";
			else
				-- Passing no restart.
				strCmdArgs = strCmdArgs.."/norestart ";
			end

			-- Output to the log that the .NET installation is being launched.
			SetupData.WriteToLogFile("Info\t.NET 4.5.2 Module: .NET 4.5.2 installation file "..strExtractInstallerToPath.." is being launched.\r\n");
			local nResult = File.Run(strExtractInstallerToPath, strCmdArgs, "", SW_SHOWNORMAL, true);
				if ((nResult == 3010) or (nResult == 1614)) then
					-- .NET install indicated that it needs reboot to be complete
					-- Set Setup Factory's reboot variable so that the reboot is just
					-- performed at the end of the install.
					_NeedsReboot = true;
				elseif (nResult == 1602) then
					-- The user canceled the setup program.
					strMessageFail = [[You have cancelled the installation for .NET 4.5.2. It is not recommended that you continue with the setup.

Click OK to abort the setup, or Cancel to continue with the application install.]];
				elseif (nResult == 1603) then
					-- A fatal error occurred during installation.
					strMessageFail = [[A fatal error occurred during installation of the .NET 4.5.2 runtime. It is not recommended that you continue with the setup.

Click OK to abort the setup, or Cancel to continue with the application install.]];
				elseif (nResult == 5100) then
					-- The user's computer does not meet system requirements.
					strMessageFail = [[This computer does not meet the system requirements for the .NET 4.5.2 installation. It is not recommended that you continue with the setup.

Click OK to abort the setup, or Cancel to continue with the application install.]];
				elseif (nResult == 5101) then
					-- Internal state failure.
					strMessageFail = [[An internal state failure occurred in the .NET 4.5.2 installation. It is not recommended that you continue with the setup.
					
Click OK to abort the setup, or Cancel to continue with the application install.]];
				elseif (nResult == 0) then
					-- The .NET setup was successful, so do nothing.
				else
					-- The .NET setup program was not completed successfully.
					strMessageFail = [[An unknown error occurred during the installation of the .NET 4.5.2 runtime. It is not recommended that you continue with the setup.

Click OK to abort the setup, or Cancel to continue with the application install.]];
				end

				-- Check to see if an error message was generated.
				if (strMessageFail ~= "") then
					-- Display the error notification dialog.
					
					-- Output to the log .NET error message.
					SetupData.WriteToLogFile("Error\t.NET 4.5.2 Module: Dialog error shown- "..strMessageFail..".\r\n");
					
					if (bShowUserPrompt) then
						nDialogResult = Dialog.Message(".NET 4.5.2 Installation" ,strMessageFail,MB_OKCANCEL,MB_ICONEXCLAMATION);
						if (nDialogResult == IDOK) then
							bAbortInstall = true;
						end
					end
				end
		
			-- Delete the run time installer file and remove the temp folder
			File.Delete(strExtractInstallerToPath);
			Folder.Delete(strRuntimeSupportFolder);
			
			-- If the user chose to abort the install after the failure of .NET install, exit the setup.
			if (bAbortInstall) then
				-- Output to the log that the user chose to abort the setup after .NET failure.
				SetupData.WriteToLogFile("Error\t.NET 4.5.2 Module: User chose to abort setup after .NET failure. Exiting setup.\r\n");
				Application.Exit(EXIT_REASON_USER_ABORTED);	
			end
			
		else
			-- The user chose not to install the runtime so delete the run time installer file,
			-- remove the temp folder and then exit the setup.
			
			-- Output to the log that the user chose to abort the setup.
			SetupData.WriteToLogFile("Error\t.NET 4.5.2 Module: User chose to abort setup. Exiting setup.\r\n");
			
			File.Delete(strExtractInstallerToPath);
			Folder.Delete(strRuntimeSupportFolder);
			if bVital then
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
			SetupData.WriteToLogFile("Error\t.NET 4.5.2 Module: Requirement failure dialog: "..strFullErrorString.."\r\n");
			
			-- Delete the runtime installer file and remove the temp folder
			File.Delete(strExtractInstallerToPath);
			Folder.Delete(strRuntimeSupportFolder);
			
			-- The user chose to abort the install due to the requirement failure of .NET.
			if (nDialogResult == IDOK) then
			
				-- Output to the log that the user chose to abort the install due to requirement failure.
				SetupData.WriteToLogFile("Error\t.NET 4.5.2 Module: User aborted setup due to requirement failure. Exiting setup.\r\n");
			
				-- Abort the install.
				Application.Exit(EXIT_REASON_USER_ABORTED);
			end
		else
			-- The user chose not to install the runtime so delete the run time installer file,
			-- remove the temp folder and then exit the setup.
			
			-- Output to the log that the user chose to abort the setup.
			SetupData.WriteToLogFile("Error\t.NET 4.5.2 Module: User chose to abort setup. Exiting setup.\r\n");
			
			File.Delete(strExtractInstallerToPath);
			Folder.Delete(strRuntimeSupportFolder);
			
			if bVital then
				Application.Exit(EXIT_REASON_USER_ABORTED);
			else
				Application.ExitScript();
			end
		
		end
	end	
	
	-- Output to the log that the installation script has finished.
	SetupData.WriteToLogFile("Success\t.NET 4.5.2 Module: Installation script finished.\r\n");
end
