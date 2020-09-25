<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER XMLOnly
    BOOLEAN Used when you already have the XSL Transform and CSS Files created
    OPTIONAL Defaults to create support files

.PARAMETER FolderPath
    STRING Specifies the Folder that the output is created in
    OPTIONAL Defaults to the folder where the script is executed from

.PARAMETER NoGUI
    BOOLEAN Used to prevent the output displaying on the console
    OPTIONAL Default is to open output in Internet Explorer Window

.EXAMPLE
audit-Windows10Build.ps1

.EXAMPLE
audit-Windows10Build.ps1 -XMLONLY -FolderPath \\server\share\folder

#>
[CmdletBinding()]
Param(
    [switch]$XMLOnly = $false,
    [ValidateScript({if (Test-Path $_ -PathType 'Container'){$true}else{throw "Invalid Path Specified"}})]
        [string]$FolderPath,
    [switch]$NoGUI
)


###########################################################################################
## Revisions
###########################################################################################
## v2.1.4a - Initial Version
## v2.1.5a - 1) Modified to update versions of apps and build
## v2.1.5a - 2) Removed Globalsign Certificate Check as not present at build time
## v2.1.5b - Added TPM Manufacturer tests
## v2.1.5c - 1) Added Certificate Private Key Check
## v2.1.5c - 2) Removed Baltimore Certificate Check as not present at build time
## v2.1.5c - 3) Removed Certificate Count Check
## v2.1.5c - 4) Removed applications that are published to all users and not part of build
## v2.1.5c - 5) Added checks for calulator, photos and camera
## v2.1.5d - 1) Added more cellular information
## v2.1.5e - 1) Modifed to create subfolder based on builddate for output
## v2.1.5e - 2) Fixed Power settings to refect correct expectations

###########################################################################################

$ScriptVersion = "2.1.5e"


Function Audit-LanguageCapability() {
	
    $RequiredCapabilities = @()
    $RequiredCapabilities+=@{Name="Language.Basic~~~en-GB~0.0.1.0"}
    $RequiredCapabilities+=@{Name="Language.Handwriting~~~en-GB~0.0.1.0"}
    $RequiredCapabilities+=@{Name="Language.OCR~~~en-GB~0.0.1.0"}
    $RequiredCapabilities+=@{Name="Language.Speech~~~en-GB~0.0.1.0"}
    $RequiredCapabilities+=@{Name="Language.TextToSpeech~~~en-GB~0.0.1.0"}

    $InstalledCapabilites =  dism /online /get-capabilities /limitaccess | ? {$_ -match "Capability Identity"}

    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 

	foreach ($RequiredCapability in $RequiredCapabilities){
        $Reason = "Not Installed"
		if ($InstalledCapabilites -match $RequiredCapability.Name) {$Result="OK";$Reason="Installed"} else {$Result="Error"}
	    $RunningTest=$xml.CreateElement("TestInstance")
	    $RunningTest.SetAttribute("TestResult",$Result)
        $RunningTest.SetAttribute("TestValue",$Reason)
	    $RunningTest.SetAttribute("TestExpectedValue","Installed")
	    $RunningTest.SetAttribute("TestName",$RequiredCapability.Name)
        $Test.AppendChild($RunningTest) | Out-Null
	}

    $xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null
}


Function Audit-PowerSettings() {

    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 

## v2.1.5e - 2) - Start of Change
    $ExpectedValues = @()
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="STANDBYIDLE";PowerState="AC";ExpectedValue=0;TestName="AC Sleep after (minutes)";Models="20JJS0HD00"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="STANDBYIDLE";PowerState="DC";ExpectedValue=6;TestName="DC Sleep after (minutes)";Models="20JJS0HD00"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="HIBERNATEIDLE";PowerState="AC";ExpectedValue=0;TestName="AC Hibernate after (minutes)";Models="20JJS0HD00"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="HIBERNATEIDLE";PowerState="DC";ExpectedValue=120;TestName="DC Hibernate after (minutes)";Models="20JJS0HD00"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_VIDEO";Setting="VIDEOIDLE";PowerState="AC";ExpectedValue=6;TestName="AC Turn Display Off after (minutes)";Models="20JJS0HD00"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_VIDEO";Setting="VIDEOIDLE";PowerState="DC";ExpectedValue=6;TestName="DC Turn Display Off after (minutes)";Models="20JJS0HD00"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="STANDBYIDLE";PowerState="AC";ExpectedValue=0;TestName="AC Sleep after (minutes)";Models="Venue 8 Pro 5855"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="STANDBYIDLE";PowerState="DC";ExpectedValue=15;TestName="DC Sleep after (minutes)";Models="Venue 8 Pro 5855"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="HIBERNATEIDLE";PowerState="AC";ExpectedValue=0;TestName="AC Hibernate after (minutes)";Models="Venue 8 Pro 5855"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="HIBERNATEIDLE";PowerState="DC";ExpectedValue=120;TestName="DC Hibernate after (minutes)";Models="Venue 8 Pro 5855"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_VIDEO";Setting="VIDEOIDLE";PowerState="AC";ExpectedValue=15;TestName="AC Turn Display Off after (minutes)";Models="Venue 8 Pro 5855"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_VIDEO";Setting="VIDEOIDLE";PowerState="DC";ExpectedValue=15;TestName="DC Turn Display Off after (minutes)";Models="Venue 8 Pro 5855"}
## v2.1.5e - 2) - End of Change

	foreach ($ExpectedValue in $ExpectedValues){
        if (($ExpectedValue.Models -eq "ALL") -or ($ExpectedValue.Models -match $Global:ComputerModel)) {
            $Reason = (powercfg /Q $ExpectedValue.Scheme $ExpectedValue.SubGroup $ExpectedValue.Setting | ?{$_ -match "Current $($ExpectedValue.PowerState) Power Setting Index"}).split(":")[1]/60
            if ($Reason -match $ExpectedValue.ExpectedValue) {$Result="OK"} else {$Result="Error"}
	        $RunningTest=$xml.CreateElement("TestInstance")
	        $RunningTest.SetAttribute("TestResult",$Result)
            $RunningTest.SetAttribute("TestValue",$Reason)
	        $RunningTest.SetAttribute("TestExpectedValue",$ExpectedValue.ExpectedValue)
	        $RunningTest.SetAttribute("TestName",$ExpectedValue.TestName)
            $Test.AppendChild($RunningTest) | Out-Null
	    }
    }

    $xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null

}


Function Audit-SierraWirelessSettings() {

    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 

    $ExpectedCarrier = "Vodafone UK"
    $ExpectedFWVersion = @{}
    $ExpectedFWVersion.Add("20JJS0HD00","SWI9X30C_02.24.03.00")
    $ExpectedFWVersion.Add("Venue 8 Pro 5855","SWI9X15C_05.05")
    
    $Event11001 = Get-WinEvent "Microsoft-Windows-WWAN-SVC-Events/Operational" -FilterXPath "*[System[EventID=11001]]" | Select-Object -First 1
    $Event11013 = Get-WinEvent "Microsoft-Windows-WWAN-SVC-Events/Operational" -FilterXPath "*[System[EventID=11013]]" | Select-Object -First 1
    $Event11002 = Get-WinEvent "Microsoft-Windows-WWAN-SVC-Events/Operational" -FilterXPath "*[System[EventID=11002]]" | Select-Object -First 1


    $SWModel = $Event11001.Properties[15].Value
    if ($SWModel) {$Result = "OK"} else {$Result = "ERROR"}
	$RunningTest=$xml.CreateElement("TestInstance")
	$RunningTest.SetAttribute("TestResult",$Result)
    $RunningTest.SetAttribute("TestValue",$SWModel)
	$RunningTest.SetAttribute("TestExpectedValue","Should be present")
	$RunningTest.SetAttribute("TestName","Modem Model")
    $Test.AppendChild($RunningTest) | Out-Null
    
    $SWCarrier = $Event11013.Properties[5].Value
    if ($ExpectedCarrier.ToUpper() -eq $SWCarrier.ToUpper()) {$Result = "OK"} else {$Result = "ERROR"}
	$RunningTest=$xml.CreateElement("TestInstance")
	$RunningTest.SetAttribute("TestResult",$Result)
    $RunningTest.SetAttribute("TestValue",$SWCarrier)
	$RunningTest.SetAttribute("TestExpectedValue",$ExpectedCarrier)
	$RunningTest.SetAttribute("TestName","Carrier Name")
    $Test.AppendChild($RunningTest) | Out-Null

## v2.1.5d - 1) - Start of Change
    $IMEI=$Event11001.Properties[13].Value
	$RunningTest=$xml.CreateElement("TestInstance")
	$RunningTest.SetAttribute("TestResult","OK")
    $RunningTest.SetAttribute("TestValue",$IMEI)
	$RunningTest.SetAttribute("TestExpectedValue","IMEI Number of the adapter")
	$RunningTest.SetAttribute("TestName","IMEI Number")
    $Test.AppendChild($RunningTest) | Out-Null

    $SIMID=$Event11002.Properties[5].Value
	$RunningTest=$xml.CreateElement("TestInstance")
	$RunningTest.SetAttribute("TestResult","OK")
    $RunningTest.SetAttribute("TestValue",$SIMID)
	$RunningTest.SetAttribute("TestExpectedValue","")
	$RunningTest.SetAttribute("TestName","SIM ID")
    $Test.AppendChild($RunningTest) | Out-Null
## v2.1.5d - 1) - End of Change

    $SWFirmware = $Event11001.Properties[16].Value
    if ($ExpectedFWVersion[$Global:ComputerModel].ToUpper() -eq $SWFirmware.ToUpper()) {$Result = "OK"} else {$Result = "ERROR"}
	$RunningTest=$xml.CreateElement("TestInstance")
	$RunningTest.SetAttribute("TestResult",$Result)
    $RunningTest.SetAttribute("TestValue",$SWFirmware)
	$RunningTest.SetAttribute("TestExpectedValue",$ExpectedFWVersion[$Global:ComputerModel])
	$RunningTest.SetAttribute("TestName","Modem Firmware Version")
    $Test.AppendChild($RunningTest) | Out-Null

    $xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null


}



Function Audit-LenovoBIOSSettings() {
    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 
 
    $RequiredSettings = @()
    $RequiredSettings+=@{Name="EthernetLANAccess";Value="Enable";DisplayName="Internal Ethernet Adapter"}
    $RequiredSettings+=@{Name="WirelessLANAccess";Value="Enable";DisplayName="Internal Wi-Fi Adapter"}
    $RequiredSettings+=@{Name="WirelessWANAccess";Value="Enable";DisplayName="Internal WWAN Adapter"}
    $RequiredSettings+=@{Name="BluetoothAccess";Value="Enable";DisplayName="Bluetooth"}
    $RequiredSettings+=@{Name="USBPortAccess";Value="Enable";DisplayName="USB Port"}
    $RequiredSettings+=@{Name="MemoryCardSlotAccess";Value="Enable";DisplayName="Memory Card Slot"}
    $RequiredSettings+=@{Name="IntegratedCameraAccess";Value="Enable";DisplayName="Integrated Camera"}
    $RequiredSettings+=@{Name="MicrophoneAccess";Value="Enable";DisplayName="Internal Microphone"}
    $RequiredSettings+=@{Name="FingerprintReaderAccess";Value="Enable";DisplayName="Fingerprint Reader"}
    $RequiredSettings+=@{Name="ThunderboltAccess";Value="Enable";DisplayName="Thunderbolt Port"}
    $RequiredSettings+=@{Name="NfcAccess";Value="Disable";DisplayName="NFC Reader"}
    $RequiredSettings+=@{Name="WiGig";Value="Enable";DisplayName="Wi-Gig Port"}
 
    $CurrentSettings=@{}
    Get-WmiObject -Class Lenovo_BiosSetting -Namespace root\wmi | select -expandproperty CurrentSetting | %{try{$CurrentSettings.Add($_.Split(",")[0],$_.Split(",")[1])} catch {}}

    foreach ($RequiredSetting in $RequiredSettings) {
        if ($CurrentSettings[$RequiredSetting.Name] -eq $RequiredSetting.Value) {$Result = "OK"} else {$Result="ERROR"}
	    $RunningTest=$xml.CreateElement("TestInstance")
	    $RunningTest.SetAttribute("TestResult",$Result)
        $RunningTest.SetAttribute("TestValue",$($CurrentSettings[$RequiredSetting.Name]))
	    $RunningTest.SetAttribute("TestExpectedValue",$RequiredSetting.Value)
	    $RunningTest.SetAttribute("TestName",$RequiredSetting.DisplayName)
        $Test.AppendChild($RunningTest) | Out-Null
	}

    $xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null


}


Function Audit-InstalledHotfixes() {
    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 
 
    $RequiredSettings = @()
    $RequiredSettings+=@{Name="KB3202790"}
    $RequiredSettings+=@{Name="KB4041691"}
    
 
    $CurrentSettings=@{}
    Get-WmiObject -Class Win32_QuickFixEngineering | %{try{$CurrentSettings.Add($_.HotFixID,$_.InstalledOn)} catch {}}

    foreach ($RequiredSetting in $RequiredSettings) {
        if ($CurrentSettings[$RequiredSetting.Name]) {$Result = "OK";$Reason = $CurrentSettings[$RequiredSetting.Name].ToString("dd-MMM-yyyy")} else {$Result="ERROR";$Reason="Not Installed"}
	    $RunningTest=$xml.CreateElement("TestInstance")
	    $RunningTest.SetAttribute("TestResult",$Result)
        $RunningTest.SetAttribute("TestValue",$Reason)
	    $RunningTest.SetAttribute("TestExpectedValue","Installed")
	    $RunningTest.SetAttribute("TestName",$RequiredSetting.Name)
        $Test.AppendChild($RunningTest) | Out-Null
	}

    $xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null


}


Function Audit-RootCertificates() {
    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 

    $RequiredCertificates=@()
    $RequiredCertificates+=@{Thumbprint="70C10E74BAEEFBA0EC7DB102F7C47E9A7BF48B09";Name="Met Police Root CA"}
    $RequiredCertificates+=@{Thumbprint="D385AD64AA8053588E96BA0C4BD15F2651047246";Name="MPS - Digital Policing"}
## v2.1.5c - 2)    $RequiredCertificates+=@{Thumbprint="D4DE20D05E66FC53FE1A50882C78DB2852CAE474";Name="Baltimore CyberTrust Root"}
## v2.1.5a - 2)    $RequiredCertificates+=@{Thumbprint="B1BC968BD4F49D622AA89A81F2150152A41D829C";Name="GlobalSign Root CA"}

    $CertificateMinimumCount = 35

    $CertRegistrySettings=@()
    $CertRegistrySettings+=@{Name="HKLM:\Software\Policies\Microsoft\SystemCertificates\AuthRoot\DisableRootAutoUpdate";Value="0";TestName="Disable Root Certificate AutoUpdate"}

 
    $Certs = Get-ChildItem Cert:\LocalMachine\Root

    foreach ($RequiredCertificate in $RequiredCertificates) {
        if ($Certs.Thumbprint -match $RequiredCertificate.Thumbprint) {
            $Result = "OK"
            $Reason = "Found"
        }
        else {
            $Result = "ERROR"
            $Reason = "Missing"
        }
        $RunningTest=$xml.CreateElement("TestInstance")
        $RunningTest.SetAttribute("TestResult",$Result)
        $RunningTest.SetAttribute("TestValue",$Reason)
	    $RunningTest.SetAttribute("TestExpectedValue","Certificate $($RequiredCertificate.Thumbprint)")
	    $RunningTest.SetAttribute("TestName",$RequiredCertificate.Name)
        $Test.AppendChild($RunningTest) | Out-Null

    }

    foreach ($RegSetting in $CertRegistrySettings) {
        $RegKey = Split-Path $RegSetting.Name
        $RegValue = Split-Path $RegSetting.Name -Leaf

        $ActualSetting = [String]$(try{(Get-ItemProperty -Path $RegKey -Name $RegValue -ErrorAction Stop).$RegValue} catch {"Not Configured"})

        If ($ActualSetting -eq $RegSetting.Value) {$Result = "OK"} else {$Result="ERROR"}
        
        $RunningTest=$xml.CreateElement("TestInstance")
        $RunningTest.SetAttribute("TestResult",$Result)
        $RunningTest.SetAttribute("TestValue",$ActualSetting)
	    $RunningTest.SetAttribute("TestExpectedValue",$RegSetting.Value)
	    $RunningTest.SetAttribute("TestName",$RegSetting.TestName)
        $Test.AppendChild($RunningTest) | Out-Null
    }


## v2.1.5c - 3) Start of Change
#    if ($Certs.Count -lt $CertificateMinimumCount) {$Result = "ERROR"} else {$Result = "OK"}
#    $RunningTest=$xml.CreateElement("TestInstance")
#    $RunningTest.SetAttribute("TestResult",$Result)
#    $RunningTest.SetAttribute("TestValue",$Certs.Count)
#    $RunningTest.SetAttribute("TestExpectedValue",$CertificateMinimumCount)
#    $RunningTest.SetAttribute("TestName","Number of Root Certificates Installed")
#    $Test.AppendChild($RunningTest) | Out-Null
## v2.1.5c - 3) End of Change

    $xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null

}


Function Audit-FireWallRules() {
    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 
    $ManagedFirewallRules=@()
    $ManagedFirewallRules+=@{Profile="Public";RuleName="File and Printer Sharing (Echo Request - ICMPv4-Out)";Status="Configured";Direction="Outbound"}
    $ManagedFirewallRules+=@{Profile="Public";RuleName="File and Printer Sharing (SMB-In)";Status="Removed";Direction="Inbound"}


	foreach ($FWProfile in $(Get-NetFirewallProfile)) {
		if ($FWProfile.Enabled -eq "True") {$Result="OK"} else {$Result="Error"}
		$RunningTest=$xml.CreateElement("TestInstance")
	    $RunningTest.SetAttribute("TestResult",$Result)
        $RunningTest.SetAttribute("TestValue",$FWProfile.Enabled)
	    $RunningTest.SetAttribute("TestExpectedValue","True")
	    $RunningTest.SetAttribute("TestName",$FWProfile.Name + " Profile Enabled")
        $Test.AppendChild($RunningTest) | Out-Null
    }
	
    foreach ($Record in $ManagedFirewallRules) {
        $Result = "WARNING"
        $Reason = "Unknown"
        $Status = $(Get-NetFirewallrule -DisplayName $Record.RuleName -ErrorAction Stop | ?{$_.Direction -eq $Record.Direction -and $_.Profile -match $Record.Profile}).PrimaryStatus
        switch ($Record.Status) {
            "Configured" {
                if ($Status) {$Result="OK";$Reason="Configured"} else {$Result="ERROR";$Reason="Removed"}
            }
            "Removed" {
                if (-not $Status) {$Result="OK";$Reason="Removed"} else {$Result="ERROR";$Reason="Configured"}
            }
        }
        
        $RunningTest=$xml.CreateElement("TestInstance")
	    $RunningTest.SetAttribute("TestResult",$Result)
        $RunningTest.SetAttribute("TestValue",$Reason)
	    $RunningTest.SetAttribute("TestExpectedValue","Should be $($Record.Status)")
	    $RunningTest.SetAttribute("TestName",$Record.Profile+"\"+$Record.RuleName)
        $Test.AppendChild($RunningTest) | Out-Null
    }
	$xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null
}


Function Audit-InstalledSoftware() {
    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 
    $RequiredSoftware=@()
    $RequiredSoftware+=@{ProductName="1E NomadBranch x64";Version="6.1.100";Models="ALL"}
    $RequiredSoftware+=@{ProductName="ActivIdentity SecureLogin x64";Version="6.3";Models="ALL"}
    $RequiredSoftware+=@{ProductName="Adobe Acrobat Reader DC";Version="15.023.20070";Models="ALL"}
    $RequiredSoftware+=@{ProductName="Adobe Shockwave Player 12.1";Version="12.1.7.157";Models="ALL"}
    $RequiredSoftware+=@{ProductName="EMET 5.52";Version="5.52";Models="ALL"}            
    $RequiredSoftware+=@{ProductName="CanonPCL6Driver2170";Version="21.70";Models="ALL"}
    $RequiredSoftware+=@{ProductName="Citrix Receiver 4.7";Version="14.7.0.13011";Models="ALL"}
    $RequiredSoftware+=@{ProductName="Configuration Manager Client";Version="5.00.8412.1000";Models="ALL"}
    $RequiredSoftware+=@{ProductName="CrimintPlusPatriarch LiveShortcuts";Version="2.13.15.11";Models="ALL"}
    $RequiredSoftware+=@{ProductName="HEAT Endpoint Security Client";Version="5.0.168";Models="ALL"}
    $RequiredSoftware+=@{ProductName="iAssistU";Version="1.6.0";Models="ALL"}
    $RequiredSoftware+=@{ProductName="Icons";Version="1.0";Models="ALL"}
    $RequiredSoftware+=@{ProductName="InstallScriptMSIEngine";Version="3.00.185";Models="ALL"}        
    $RequiredSoftware+=@{ProductName="Java 8 Update 121 (64-bit)";Version="8.0.1210.13";Models="ALL"}
    $RequiredSoftware+=@{ProductName="MDOP MBAM";Version="2.5.1100.0";Models="ALL"}
    $RequiredSoftware+=@{ProductName="Microsoft Office Professional Plus 2016";Version="16.0.4266.1001";Models="ALL"}
## v2.1.5c - 4)    $RequiredSoftware+=@{ProductName="MPSGetUserInfo";Version="2.8.0";Models="ALL"}
    $RequiredSoftware+=@{ProductName="NSPIC";Version="1.0";Models="ALL"}
    $RequiredSoftware+=@{ProductName="Patriarch 2.13.15";Version="2.13.15";Models="ALL"}
    $RequiredSoftware+=@{ProductName="Sierra Wireless Lenovo Mobile Broadband INF Package";Version="7.44.4709.0102";Models="20JJS0HD00"}
    $RequiredSoftware+=@{ProductName="Sierra Wireless Dell Mobile Broadband Driver Package";Version="6.14.4316.0502";Models="Venue 8 Pro 5855"}
    $RequiredSoftware+=@{ProductName="WinZip 21.5";Version="21.5.12480";Models="ALL"}
## v2.1.5c - 4)    $RequiredSoftware+=@{ProductName="XEMD3449_MetHR_Java6u24_1.0";Version="0.0.0.1";Models="ALL"}
    $RequiredSoftware+=@{ProductName="XEMD3454_Unisys_CRIS_10.5.3";Version="0.0.0.5";Models="ALL"}
    $RequiredSoftware+=@{ProductName="XEMD3461_WinwordStub_1.0";Version="0.0.0.2";Models="ALL"}
    $RequiredSoftware+=@{ProductName="XEMD3488_Micro_Systemation_XRY_Viewer_6.16";Version="0.0.0.6";Models="20JJS0HD00","Venue 8 Pro 5855"}
    $RequiredSoftware+=@{ProductName="XEMD3490_SiraView_3.4.0.288";Version="0.0.0.1";Models="ALL"}
    $RequiredSoftware+=@{ProductName="XEMD5012_VideoLAN_VLC_224";Version="0.0.0.1";Models="ALL"}
## v2.1.5c - 4)    $RequiredSoftware+=@{ProductName="met.merlin";Version="0.68.0.0";Models="ALL"}
    $RequiredSoftware+=@{ProductName="Microsoft.Windows.Photos";Version="16.511.8780.0";Models="ALL"}    ## v2.1.5c - 5)
    $RequiredSoftware+=@{ProductName="Microsoft.WindowsCalculator";Version="10.1605.1582.0";Models="ALL"}    ## v2.1.5c - 5)
    $RequiredSoftware+=@{ProductName="Microsoft.WindowsCamera";Version="2016.404.190.0";Models="ALL"}    ## v2.1.5c - 5)

	
    $InstalledSoftware=@{}
    Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object {$_.DisplayName -ne $null} | Select DisplayName, @{Name="Version";Expression={if($_.DisplayVersion -eq $null){[string]$_.VersionMajor+"."+[string]$_.VersionMinor}else{$_.DisplayVersion}}} | %{try{$InstalledSoftware.Add($_.DisplayName,$_.Version)}catch{} }
    Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object {$_.DisplayName -ne $null} | Select DisplayName, @{Name="Version";Expression={if($_.DisplayVersion -eq $null){[string]$_.VersionMajor+"."+[string]$_.VersionMinor}else{$_.DisplayVersion}}} | %{try{$InstalledSoftware.Add($_.DisplayName,$_.Version)}catch{} }

    Get-AppvClientPackage -All | %{try{$InstalledSoftware.Add($_.Name,$_.Version)}catch{} }
    Get-AppxPackage -AllUsers  | %{try{$InstalledSoftware.Add($_.Name,$_.Version)}catch{} }
    
    
    
    
    foreach ($Product in $RequiredSoftware) {
        if (($Product.Models -eq "ALL") -or ($Product.Models -match $Global:ComputerModel)) {

            if ($Product.Version -eq $InstalledSoftware[$Product.ProductName]) {$Result="OK"} else {$Result="Error"}
	        $RunningTest=$xml.CreateElement("TestInstance")
        	$RunningTest.SetAttribute("TestResult",$Result)
            $RunningTest.SetAttribute("TestValue",$InstalledSoftware[$Product.ProductName])
	        $RunningTest.SetAttribute("TestExpectedValue",$Product.Version)
	        $RunningTest.SetAttribute("TestName",$Product.ProductName)
            $Test.AppendChild($RunningTest) | Out-Null
        }
    }
	
	$xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null

}


Function Audit-AntiVirusDefinitions() {
    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 

    try{
        $AV = Get-MpComputerStatus
        $DefinitionDate=$AV.AntiVirusSignatureLastUpdated
        $SignatureVersion=$AV.AntivirusSignatureVersion
    } catch {
        $DefinitionDate=Get-Date -Year 1900 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0
        $SignatureVersion="N/A"
    }
    If ($DefinitionDate -lt $(Get-Date).AddDays(-2)) {$Result="Warn"} else {$Result="OK"}
    $RunningTest=$xml.CreateElement("TestInstance")
    $RunningTest.SetAttribute("TestResult",$Result)
    $RunningTest.SetAttribute("TestValue",$DefinitionDate.ToString("dd-MMM-yyyy"))
	$RunningTest.SetAttribute("TestExpectedValue",$(Get-Date).ToString("dd-MMM-yyyy"))
	$RunningTest.SetAttribute("TestName","AntiVirus Definition Date")
    $Test.AppendChild($RunningTest) | Out-Null

    $RunningTest=$xml.CreateElement("TestInstance")
    $RunningTest.SetAttribute("TestResult",$Result)
    $RunningTest.SetAttribute("TestValue",$SignatureVersion)
	$RunningTest.SetAttribute("TestExpectedValue","")
	$RunningTest.SetAttribute("TestName","AntiVirus Signature Version")
    $Test.AppendChild($RunningTest) | Out-Null
    


	$xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null

}


Function Audit-TPMSettings () {
	
    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 

	$TPMChecks=@()
	$TPMChecks+=@{Name="TpmPresent";Value="True";DisplayName="TPM Present"}
	$TPMChecks+=@{Name="TpmReady";Value="True";DisplayName="TPM Ready"}
	$TPMChecks+=@{Name="LockedOut";Value="False";DisplayName="TPM Locked Out"}

    $TPM = Get-TPM

## v2.1.5b - Start of Change
    $VendorID = ([convert]::ToString($TPM.ManufacturerID,16))
    $i=0
    $Manufacturer=""
    while ($i -lt 7) {
        $Value=[convert]::ToInt32($VendorID.substring($i,2),16)
        If ($Value -ne 0) {$Manufacturer+=[char]($Value)}
        $i=$i+2
    }
    if ($Manufacturer -eq "IFX") {$Result="ERROR";$Reason="Infineon Chip"} Else {$Result="OK";$Reason="Not Infineon"}
    $RunningTest=$xml.CreateElement("TestInstance")
    $RunningTest.SetAttribute("TestResult",$Result)
    $RunningTest.SetAttribute("TestValue",$Manufacturer)
	$RunningTest.SetAttribute("TestExpectedValue",$Reason)
	$RunningTest.SetAttribute("TestName","TPM Manufacturer")
    $Test.AppendChild($RunningTest) | Out-Null

    $t = $TPM.ManufacturerVersion
    $t = ($TPM.ManufacturerVersion).split(".")
    $i=0
    while ($i -lt ($t.Count)) {
        $t[$i] = ([int]$t[$i])
        $i++
    }
    $TPMFirmwareVersion = $t -join "."

    $RunningTest=$xml.CreateElement("TestInstance")
    $RunningTest.SetAttribute("TestResult","OK")
    $RunningTest.SetAttribute("TestValue",$TPMFirmwareVersion)
	$RunningTest.SetAttribute("TestExpectedValue","Firmware Version")
	$RunningTest.SetAttribute("TestName","TPM Firmware Version")
    $Test.AppendChild($RunningTest) | Out-Null
## v2.1.5b - End of Change

    foreach ($TPMCheck in $TPMChecks) {
        $Reason = $TPMCheck.Value
        $TestResult = ($TPM | select -Property $($TPMCheck.Name)).$($TPMCheck.Name)
		IF ($TPMCheck.Value -eq $TestResult) {
            $Result = "OK"
        }
        else {
            $Result = "ERROR"
        }
    	$RunningTest=$xml.CreateElement("TestInstance")
    	$RunningTest.SetAttribute("TestResult",$Result)
    	$RunningTest.SetAttribute("TestValue",$TestResult)
		$RunningTest.SetAttribute("TestExpectedValue",$TPMCheck.Value)
		$RunningTest.SetAttribute("TestName",$TPMCheck.DisplayName)
    	$Test.AppendChild($RunningTest) | Out-Null
	}
	$xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null
}


Function Audit-DirectAccessSettings() {

    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 

	$DAExperience = Get-DAClientExperienceConfiguration
    if ($DAExperience.FriendlyName) {$Result = "OK"} else {$Result = "ERROR"}
	$RunningTest=$xml.CreateElement("TestInstance")
	$RunningTest.SetAttribute("TestResult",$Result)
	$RunningTest.SetAttribute("TestValue",$DAExperience.FriendlyName)
    $RunningTest.SetAttribute("TestExpectedValue","Should be set to something")
	$RunningTest.SetAttribute("TestName","DirectAccess Name")
	$Test.AppendChild($RunningTest) | Out-Null

    $Cert = Get-ChildItem Cert:\LocalMachine\My
    if ($Cert.Count -eq 1) {$Result = "OK"} else {$Result = "ERROR"}
	$RunningTest=$xml.CreateElement("TestInstance")
	$RunningTest.SetAttribute("TestResult",$Result)
	$RunningTest.SetAttribute("TestValue",$Cert.Count)
    $RunningTest.SetAttribute("TestExpectedValue","Should be 1")
	$RunningTest.SetAttribute("TestName","Certificate Count")
	$Test.AppendChild($RunningTest) | Out-Null

    $CertChecks = @()
    $CertChecks+=@{Name="Issuer";Value="CN=Met Police Class 2 Primary CA, OU=Met, O=Police, C=GB";DisplayName="Issuing CA"}
    $CertChecks+=@{Name="EnhancedKeyUsageList";Value="Client Authentication (1.3.6.1.5.5.7.3.2)";DisplayName="Certificate Usage"}

    ForEach ($CertCheck in $CertChecks) {
        $Reason = $CertCheck.Value
        $TestResult = ($Cert | select -Property $($CertCheck.Name)).$($CertCheck.Name)
		IF ($CertCheck.Value -eq $TestResult) {
            $Result = "OK"
        }
        else {
            $Result = "ERROR"
        }

		$RunningTest=$xml.CreateElement("TestInstance")
    	$RunningTest.SetAttribute("TestResult",$Result)
    	$RunningTest.SetAttribute("TestValue",$TestResult)
		$RunningTest.SetAttribute("TestExpectedValue",$Reason)
		$RunningTest.SetAttribute("TestName",$CertCheck.DisplayName)
    	$Test.AppendChild($RunningTest) | Out-Null
	}

## v2.1.5c - 1) - Start of Change
    $Reason = "Private Key Should Be TPM Backed"
    If (($Cert.HasPrivateKey) -and ($Cert.PrivateKey)) {
        $Result = "ERROR"
        $TestResult ="Private Key is NOT TPM Backed"
    }
    else {
        $Result = "OK"
        $TestResult ="Private Key is TPM Backed"
    }
	$RunningTest=$xml.CreateElement("TestInstance")
    $RunningTest.SetAttribute("TestResult",$Result)
    $RunningTest.SetAttribute("TestValue",$TestResult)
	$RunningTest.SetAttribute("TestExpectedValue",$Reason)
	$RunningTest.SetAttribute("TestName","Private Key Status")
    $Test.AppendChild($RunningTest) | Out-Null
## v2.1.5c - 1) - End of Change

    if ($Cert.NotAfter -gt $(Get-Date)) {$Result = "OK"} else {$Result = "ERROR"}
	$RunningTest=$xml.CreateElement("TestInstance")
  	$RunningTest.SetAttribute("TestResult",$Result)
   	$RunningTest.SetAttribute("TestValue",$Cert.NotAfter.ToString("dd-MMM-yyyy HH:mm:ss"))
	$RunningTest.SetAttribute("TestExpectedValue",$(Get-Date).ToString("dd-MMM-yyyy HH:mm:ss"))
	$RunningTest.SetAttribute("TestName","Certificate Expiry Date")
   	$Test.AppendChild($RunningTest) | Out-Null
	

	$xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null
}


Function Audit-HardwareInformation() {

    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 

	$licenseStatus=@{0="Unlicensed"; 1="Licensed"; 2="Out Of Box Grace Period"; 3="Out Of Time Grace period"; 4="Non-Genuine Grace Period"; 5="Notification Period"; 6="Extended Grace Period"}
	$ActivationStatus =$licenseStatus[[int]$(Get-WmiObject SoftwareLicensingProduct -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f' AND PartialProductKey like '%'").LicenseStatus]
	
	$ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem
    $OperatingSystem = Get-WmiObject -Class Win32_OperatingSystem
    $BIOS = Get-WmiObject -Class Win32_BIOS


    $BIOSLookups=@{}
    $BIOSLookups.Add("20JJS0HD00","R0HET33W (1.13 )")
    $BIOSLookups.Add("Venue 8 Pro 5855","1.7.0")

    $Global:ComputerModel = $ComputerSystem.Model
    $Global:ComputerMake = $ComputerSystem.Manufacturer

	$SysInfo=@()
	$SysInfo+=@{Setting="Manufacturer";Value=$Global:ComputerMake}
	$SysInfo+=@{Setting="Model";Value=$Global:ComputerModel}
	$SysInfo+=@{Setting="Serial Number";Value=$BIOS.SerialNumber}
	$SysInfo+=@{Setting="BIOS Version";Value=$BIOS.SMBIOSBIOSVersion;Validate="True";RequiredValue=$BIOSLookups[$Global:ComputerModel]}
	$SysInfo+=@{Setting="Processor Count";Value=$ComputerSystem.NumberOfProcessors}
	$SysInfo+=@{Setting="Logical Core Count";Value=$ComputerSystem.NumberOfLogicalProcessors}
	$SysInfo+=@{Setting="Physical Memory (GB)";Value=[int]($ComputerSystem.TotalPhysicalMemory/(1GB))}
	$SysInfo+=@{Setting="Installed Operating System";Value=$OperatingSystem.Caption}
    $InstallDate = Get-Date -Year  $OperatingSystem.InstallDate.ToString().SubString(0,4)`
                            -Month $OperatingSystem.InstallDate.ToString().SubString(4,2) `
                            -Day   $OperatingSystem.InstallDate.ToString().SubString(6,2) `
                            -Hour  $OperatingSystem.InstallDate.ToString().SubString(8,2) `
                            -Minute $OperatingSystem.InstallDate.ToString().SubString(10,2)
	$SysInfo+=@{Setting="Build Date";Value=$InstallDate.ToString("dd-MMM-yyyy HH:mm")}
    $Global:BuildDate = $OperatingSystem.InstallDate.ToString().SubString(0,8) + "-" + $OperatingSystem.InstallDate.ToString().SubString(8,4)
	
	ForEach ($Record in $SysInfo) {
		$RunningTest=$xml.CreateElement("TestInstance")
        if ($Record.Validate) {
            if (-not ($Record.Value -eq $Record.RequiredValue)) {
            	$RunningTest.SetAttribute("TestResult","ERROR")
        		$RunningTest.SetAttribute("TestExpectedValue",$Record.RequiredValue)
            }
            else {

            	$RunningTest.SetAttribute("TestResult","OK")
    		    $RunningTest.SetAttribute("TestExpectedValue",$Record.Value)
            }
        }
        else {
            $RunningTest.SetAttribute("TestResult","OK")
		    $RunningTest.SetAttribute("TestExpectedValue",$Record.Value)
        }
        $RunningTest.SetAttribute("TestValue",$Record.Value)
	    $RunningTest.SetAttribute("TestName",$Record.Setting)
    	$Test.AppendChild($RunningTest) | Out-Null
	}

	If ($licenseStatus[1] -eq $ActivationStatus) {$Result="OK"} else {$Result="ERROR"}
	$RunningTest=$xml.CreateElement("TestInstance")
	$RunningTest.SetAttribute("TestResult",$Result)
	$RunningTest.SetAttribute("TestValue",$ActivationStatus)
	$RunningTest.SetAttribute("TestExpectedValue",$licenseStatus[1])
	$RunningTest.SetAttribute("TestName","Activation Status")
	$Test.AppendChild($RunningTest) | Out-Null

	
	$xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null
}


Function Audit-SOETaskSequence() {

    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 

	$SOE = Get-ItemProperty "HKLM:\SOFTWARE\CSC\Installation"
	
    $SOETests=@()
    $SOETests+=@{Name="TSPackageName";Value="Client Installation 2.1.5";DisplayName="Task Sequence Name"}
    $SOETests+=@{Name="TSVersion";Value="2.1.5";DisplayName="Task Sequence Version"}
    $SOETests+=@{Name="ImagePackageID";Value="MFN0038D";DisplayName="WIM Version"}
    $SOETests+=@{Name="SMSMP";Value=$(($SOE | select -Property SMSMP).SMSMP);DisplayName="SCCM Management Server"}

	ForEach ($SOETest in $SOETests) {
        $Reason = $SOETest.Value
        $TestResult = ($SOE | select -Property $($SOETest.Name)).$($SOETest.Name)
		IF ($SOETest.Value -eq $TestResult) {
            $Result = "OK"
        }
        else {
            $Result = "ERROR"
        }

		$RunningTest=$xml.CreateElement("TestInstance")
    	$RunningTest.SetAttribute("TestResult",$Result)
    	$RunningTest.SetAttribute("TestValue",$TestResult)
		$RunningTest.SetAttribute("TestExpectedValue",$Reason)
		$RunningTest.SetAttribute("TestName",$SOETest.DisplayName)
    	$Test.AppendChild($RunningTest) | Out-Null
	}
	$xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null

}


Function Audit-NetworkConnections() {

    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 

    $ConfigureNICS=@{}
    $ConfigureNICS.Add("Cellular","800")
    $ConfigureNICS.Add("Wi-Fi","100")
    
   
	$NICS = Get-NetAdapter | Where-Object {$_.AdminStatus -eq "Up"} | Select Name, InterfaceDescription, @{Name="InterfaceMetric";Expression={(Get-NetIPInterface -InterfaceIndex $_.InterfaceIndex -AddressFamily IPv4).InterfaceMetric}},MacAddress
	
    foreach ($NIC in $NICS) {
        $Reason = ""
		if ($ConfigureNICS[$NIC.Name.Split(" ")[0]]) {
            $Reason=$ConfigureNICS[$NIC.Name.Split(" ")[0]]
            if ($ConfigureNICS[$NIC.Name.Split(" ")[0]] -eq $NIC.InterfaceMetric) {$Result = "OK"} else {$Result = "ERROR"}
        }
        else {
            $Reason = "Not Set"
            $Result = "OK"
        }
		$RunningTest=$xml.CreateElement("TestInstance")
    	$RunningTest.SetAttribute("TestResult",$Result)
    	$RunningTest.SetAttribute("TestValue","Metric: " + $NIC.InterfaceMetric + "`r`n" + "MacAddress: "+ $NIC.MACAddress)
		$RunningTest.SetAttribute("TestExpectedValue",$Reason)
		$RunningTest.SetAttribute("TestName",$NIC.Name + "`r`n" + $NIC.InterfaceDescription)
    	$Test.AppendChild($RunningTest) | Out-Null
	}
    foreach ($NIC in $ConfigureNICS.Keys) {
        if (-not ($NICS -match $NIC)) {
		    $RunningTest=$xml.CreateElement("TestInstance")
    	    $RunningTest.SetAttribute("TestResult","ERROR")
    	    $RunningTest.SetAttribute("TestValue","Not Found")
		    $RunningTest.SetAttribute("TestExpectedValue","Found")
		    $RunningTest.SetAttribute("TestName",$NIC)
    	    $Test.AppendChild($RunningTest) | Out-Null
        }
    }
	$xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null
			
}


Function Audit-HardDiskSettings() {

    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 

	$FreePercentExpected = 75
	$Volumes = Get-Volume | Where-Object {($_.DriveType -eq "Fixed") -and ($_.DriveLetter -ne $null)} | Select-Object DriveLetter, FileSystemLabel , @{Name="Capacity";Expression={[int]($_.Size/(1GB))}}, @{Name="FreeSpace";Expression={[int]($_.SizeRemaining/(1GB))}}, @{Name="FreePercent";Expression={[int](($_.SizeRemaining/$_.Size)*100)}}
	
	ForEach ($Volume in $Volumes) {
        #$Reason = "Free Space should be at least " + $FreePercentExpected + "%"
		#IF ($Volume.FreePercent -lt $FreePercentExpected) {$Result = "ERROR"} else {$Result = "OK"}
        $BitLockerStatus = ((manage-bde.exe -status "$($Volume.DriveLetter):") -match "Conversion Status:").split(":")[1].trim()
        If (-not ($BitLockerStatus -eq "Fully Encrypted")) {$Result = "ERROR";$Reason="Drive NOT Encrypted"} else {$Result = "OK";$Reason="Drive Encrypted"}
		$RunningTest=$xml.CreateElement("TestInstance")
    	$RunningTest.SetAttribute("TestResult",$Result)
    	$RunningTest.SetAttribute("TestValue","Free Space (GB): " + $Volume.FreeSpace + "`r`n" + "Free Space %: " + $Volume.FreePercent)
		$RunningTest.SetAttribute("TestExpectedValue",$Reason)
		$RunningTest.SetAttribute("TestName",$Volume.DriveLetter + ": " + $Volume.FileSystemLabel + "`r`nCapacity (GB): " + $Volume.Capacity+ "`r`n" + $BitLockerStatus)
    	$Test.AppendChild($RunningTest) | Out-Null
	}

	$xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null

}


Function Create-XSLTransform() {
    $XSLT=@"
<?xml version="1.0" encoding="UTF-16"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
<html>
<head>
<link type="text/css" rel="stylesheet" href="BuildAudit.css" />
</head>
<body class="Normal">
<xsl:for-each select="Tests">
<table ID="Heading">
	<tr>
		<td class="Title">Windows 10 Build Audit - <xsl:value-of select="@ScriptVersion"/></td>
		<td class="logo">&#160;</td>
	</tr>
</table>
	<table ID="Top">
		<tr class="Subtitle">
			<td class="Subtitle">&#160;</td>
		</tr>
		<tr class="Subtitle">
			<td class="Subtitle">Machine Name</td><td> <xsl:value-of select="@System"/> </td>
		</tr>
		<tr class="Subtitle">
			<td class="Subtitle">Audit Date</td><td> <xsl:value-of select="@RunDate"/> </td>
		</tr>
		<tr class="Subtitle">
			<td class="Subtitle">Run By</td><td> <xsl:value-of select="@RunBy"/> </td>
		</tr>
		<tr class="Subtitle">
			<td class="Subtitle">Test Success Rate</td><td> <xsl:value-of select="@TotalTests - @TotalErrors - @TotalWarnings"/>/<xsl:value-of select="@TotalTests"/></td>
		</tr>
		<tr class="Subtitle">
			<td class="Subtitle">Total Test Errors</td><td> <xsl:value-of select="@TotalErrors"/> </td>
		</tr>
		<tr class="Subtitle">
			<td class="Subtitle">Total Test Warnings</td><td> <xsl:value-of select="@TotalWarnings"/> </td>
		</tr>
		<tr class="TableFooter"><td>&#160;</td></tr>
	</table>
	<table ID="TOC">
		<xsl:for-each select="Test">
			<tr class="TOC">
				<td class="TOC">
				<xsl:element name="a">
					<xsl:attribute name="href">
						<xsl:value-of select="concat('#',@Family)"/>
					</xsl:attribute>
					<xsl:attribute name="class">TOC</xsl:attribute>
				<xsl:value-of select="@Family"/>
				</xsl:element>
				</td>
				<td>
					<xsl:value-of select="count(TestInstance[@TestResult='OK'])" />/<xsl:value-of select="count(TestInstance)" />
				</td>
			</tr>
		</xsl:for-each>
		<tr class="TableFooter"><td>&#160;</td></tr>
	</table>
	<xsl:for-each select="Test">
		<table>
				<xsl:element name="tr">
					<xsl:attribute name="class">Header</xsl:attribute>
					<xsl:attribute name="ID">
						<xsl:value-of select="@Family"/>
					</xsl:attribute>
					<td><xsl:value-of select="@Family"/></td>
					<td align="right"><a href="#top" class="Header">top</a></td>
				</xsl:element>
		</table>
		<table>
			<tr class="TableHeader">
				<th class="col1">Test</th>
				<th class="col2">Result</th>
			</tr>
			<xsl:for-each select="TestInstance">
				<xsl:element name="tr">
					<xsl:attribute name="class">
						<xsl:value-of select="concat('TableRow',@TestResult)"/>
					</xsl:attribute>
					<xsl:element name="td">
						<xsl:attribute name="class">col1</xsl:attribute>
						<xsl:attribute name="title"><xsl:value-of select="@TestExplanation"/></xsl:attribute>
						<xsl:call-template name="replace-br">
							<xsl:with-param name="text" select="@TestName" />
						</xsl:call-template>
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">col2</xsl:attribute>
						<xsl:attribute name="title"><xsl:value-of select="@TestExpectedValue"/></xsl:attribute>
						<xsl:call-template name="replace-br">
							<xsl:with-param name="text" select="@TestValue"/>
						</xsl:call-template>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
			<tr class="TableFooter"><td>&#160;</td></tr>
		</table>
	</xsl:for-each>
</xsl:for-each>
</body>
</html>
</xsl:template>

<xsl:template name="replace-br">
	<xsl:param name="text"/>
	<xsl:choose>
		<xsl:when test="contains(`$text, '&#xD;&#xA;')">
			<xsl:value-of select="substring-before(`$text, '&#xD;&#xA;')"/>
			<br/>
			<xsl:call-template name="replace-br">
				<xsl:with-param name="text" select="substring-after(`$text,'&#xD;&#xA;')"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="`$text"/>
		</xsl:otherwise>
	</xsl:choose>	
</xsl:template>

</xsl:stylesheet> 
"@


$XSLT.Replace("xxx_StyleSheetRef_xxx",$CSSFile) | Out-File $($FolderPath + $XSLTransformFile)

}


Function Create-StyleSheet() {
    $CSS=@"
.Normal
	{
	font-size:11.0pt;
	font-family:"Vodafone Rg","Arial","sans-serif";
	color:black;
	a:link{color:black};
	a:visited{color:black};
	width:300px;
	min-width:300px;
	min-width:300px;
	}
tr.TableRowOK
	{
	font-size:10.0pt;
	background-color:#7CFF7F;
	}
tr.TableRowError
	{
	font-size:10.0pt;
	background-color:#FF1500
	}
tr.TableRowWarn
	{
	font-size:10.0pt;
	background-color:#FF9707
	}
tr.TableHeader
	{
	page-break-after:avoid;
	font-size:12.0pt;
	color:#0032AA;
	background-color:#AEA79F;
	}
tr.TableFooter
	{
	page-break-before:avoid;
	font-size:4.0pt;
	color:white;
	background-color:white;
	}
.Header
	{
	page-break-after:avoid;
	font-size:14.0pt;
	color:#FFFFFF;
	background-color:#0032A0;
	border-top:10px white;
	a:link{color:white};
	a:visited{color:white};
	}
.Title
	{
	border-bottom:2px solid #0032AA;
	padding:0cm;
	font-size:26.0pt;
	color:#0032AA;
	}
.Subtitle
	{
	font-size:14.0pt;
	color:#0032AA;
	width:300px;
	min-width:300px;
	min-width:300px;
	}
.TOC
	{
	font-size:11.0pt;
	color:#007C92;
	a:link{color:#007C92};
	a:visited{color:#007C92};
	width:300px;
	min-width:300px;
	min-width:300px;
}
.col1
	{
	width:800px;
	min-width:800px;
	max-width:800px;
	word-wrap:break-word;
	text-align:left;
	border-bottom:2px solid #AEA79F;
	}
.col2, .col3
	{
	width:270px;
	min-width:270px;
	max-width:270px;
	word-wrap:break-word;
	text-align:left;
	border-bottom:2px solid #AEA79F;
	padding-left:10px
	}
table
	{
	width:1080px;
	table-layout:fixed;
	border-collapse:collapse;
	border-bottom:5px white;
	}
.logo
	{
	padding-left:0px;
	padding-right:60px;
	padding-bottom:0px;
	height:60px;
	width:60px;
	background-repeat:no-repeat;
	
	}
"@

$CSS | Out-File $($FolderPath+$CSSFile)

}


If (-not $FolderPath) {$FolderPath=split-path -parent $MyInvocation.MyCommand.Definition}
If (-not ($FolderPath.Substring($FolderPath.Length-1,1) -eq "\")) {$FolderPath+="\"}
$XSLTransformFile = "BuildAudit.xsl"
$CSSFile = "BuildAudit.css"


$xmlHeader=@()
$xmlHeader+='<?xml version="1.0" encoding="utf-16"?>'
$xmlHeader+='<?xml-stylesheet type="text/xsl" href="' + $XSLTransformFile +'"?>'
$xmlHeader+='<Tests></Tests>'
$xml = New-Object xml
$xml.LoadXml($xmlHeader)
$RootItemNumber=$xmlHeader.Count-1


Audit-HardwareInformation
if ($Global:ComputerMake -eq "LENOVO") {Audit-LenovoBIOSSettings}

Audit-SOETaskSequence
Audit-TPMSettings
Audit-PowerSettings
Audit-LanguageCapability
Audit-AntiVirusDefinitions
Audit-HardDiskSettings
Audit-FireWallRules
Audit-InstalledSoftware
Audit-InstalledHotfixes
Audit-RootCertificates
Audit-DirectAccessSettings
Audit-SierraWirelessSettings
Audit-NetworkConnections


$TotalTests=$($xml.Tests.Test.TestInstance | Measure-Object).Count
$TotalErrors=$($xml.Tests.Test.TestInstance | Where-Object {$_.TestResult -eq "Error"} | Measure-Object).Count
$TotalWarnings=$($xml.Tests.Test.TestInstance | Where-Object {$_.TestResult -eq "Warn"} | Measure-Object).Count
$Summary=$xml.Tests
$Summary.SetAttribute("ScriptVersion",$ScriptVersion)
$Summary.SetAttribute("RunBy",$env:USERDOMAIN+"\"+$env:USERNAME)
$Summary.SetAttribute("RunDate",$(Get-Date -Format "dd-MMM-yyyy HH:mm"))
$Summary.SetAttribute("System",$env:COMPUTERNAME)
$Summary.SetAttribute("TotalTests",$TotalTests)
$Summary.SetAttribute("TotalErrors",$TotalErrors)
$Summary.SetAttribute("TotalWarnings",$TotalWarnings)

$XMLFile = $Global:BuildDate + "-" + $env:COMPUTERNAME +  "-AuditReport.xml"

## v2.1.5e - 1) Start of Change
if (Test-Path ($FolderPath+$Global:BuildDate.Substring(0,8) + "\") -PathType 'Container') {
    $FolderPath+=$Global:BuildDate.Substring(0,8) + "\"
    if (-not $XMLONLY) {
        Create-StyleSheet
        Create-XSLTransform
    }
}
else {
    New-Item -Type Directory -Path ($FolderPath+$Global:BuildDate.Substring(0,8) + "\") | Out-Null
    $FolderPath+=$Global:BuildDate.Substring(0,8) + "\"
    Create-StyleSheet
    Create-XSLTransform
}
## v2.1.5e - 1) End of Change


$xml.Save($($FolderPath+$XMLFile)) 


Write-Host "Finished Auditing $env:COMPUTERNAME"
Write-Host "Ran $TotalTests tests, found $TotalErrors Errors and $TotalWarnings Warnings"
Write-Host "Check $FolderPath$XMLFile for details"
if (-not $NoGUI) { Start-Process "iexplore.exe" $($FolderPath + $XMLFile)}