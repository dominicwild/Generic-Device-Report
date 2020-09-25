. "$PSScriptRoot\Functions.ps1"

$information = [PSCustomObject]@{
    AntiVirus           = Get-MpComputerStatus;
    WindowsCapabilities = Get-WindowsCapability -Online;
    HotFixes            = Get-WmiObject -Class Win32_QuickFixEngineering;
    RootCertificates    = Get-ChildItem Cert:\LocalMachine\Root;
    FireWall            = @{
        FireWallRules    = Get-NetFirewallRule
        FireWallProfiles = Get-NetFirewallProfile;
    };
    Software            = @{
        RegistrySoftware = Get-InstalledSoftware;
        AppX             = Get-AppXSoftware;
        AppV             = Get-AppVSoftware;
    };
    TPMSettings         = Get-TPM;
    DirectAccess        = @{
        Setting      = Get-DAClientExperienceConfiguration;
        Certificates = Get-ChildItem Cert:\LocalMachine\My;
    };
    Computer            = @{
        ActivationStatus = Get-ActivationStatus;
        System           = Get-System;
        Processor        = Get-WMIInfo Win32_Processor;
        BIOS             = Get-WMIInfo Win32_BIOS;
        Desktops         = Get-WMIInfo Win32_Desktop;
        LogicalDisk      = Get-WMIInfo Win32_LogicalDisk;
        LogonSessions    = Get-WMIInfo Win32_LogonSession;
        OperatingSystem  = Get-WMIInfo Win32_OperatingSystem;
    };
    Services            = Get-WMIInfo Win32_Service;
    Drivers             = Get-WindowsDriver -Online -All;
    Licenses            = Get-WMIInfo SoftwareLicensingProduct;
    Registry            = @{
        CSC = Get-RegValues "HKLM:\SOFTWARE\CSC\"; 
    };
    Network             = @{
        Interfaces = Get-NetAdapter;
    };
    Storage             = Get-Volume;
    Processes           = Get-Process;
    Startup             = Get-WMIInfo Win32_StartupCommand;
    MSInfo32            = Get-ComputerInfo;
}

$information | ConvertTo-Json -Depth 100 | Set-Content "info.json"
Write-Log "Created json file."
