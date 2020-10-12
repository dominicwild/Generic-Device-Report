. "$PSScriptRoot\Functions.ps1"

$jsonFileName = "$env:COMPUTERNAME.json"
$reportFolderName = "$env:COMPUTERNAME"
$reportFolderLocation = "$PSScriptRoot\$reportFolderName"
$buildFolder = "$PSScriptRoot\build"

$information = [PSCustomObject]@{
    AntiVirus           = Get-Antivirus;
    WindowsCapabilities = Get-WindowsCapabailities;
    HotFixes            = Get-WmiObject -Class Win32_QuickFixEngineering;
    RootCertificates    = Get-ChildItem Cert:\LocalMachine\Root;
    Power               = @{
        Scheme = Get-PowerConfig;
    };
    Firewall            = @{
        Rules    = Get-FirewallRules;
        Profiles = Get-FirewallProfiles;
    };
    Software            = @{
        Registry = Get-InstalledSoftware;
        AppX     = Get-AppXSoftware;
        AppV     = Get-AppVSoftware;
    };
    TPMSettings         = Get-TPMSettings;
    DirectAccess        = @{
        Setting      = Get-DAClientExperienceConfiguration;
        Certificates = Get-DirectAccessCertificates;
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
        Interfaces = Get-NetworkInterfaces;
    };
    Storage             = Get-Storage;
    Processes           = Get-Process;
    Startup             = Get-WMIInfo Win32_StartupCommand;
    MSInfo32            = Get-MSInfo32;
}

Write-Log "Creating json file."
$json = $information | ConvertTo-Json -Depth 4 -Compress
$json | Set-Content $jsonFileName

Write-Log "Creating report folder."
if (Test-Path $reportFolderLocation) {
    Write-Log "A report at $reportFolderLocation already exists. Deleting this report."
    Remove-Item $reportFolderLocation -Force
}

Write-Log "Creating the report build."
Copy-Item $buildFolder $reportFolderLocation -Recurse -Force
Set-Content "$reportFolderLocation\data.js" "window.data = $json;"

Write-Log "Created report file at $reportFolderLocation\index.html"

Invoke-Item "$reportFolderLocation\index.html"