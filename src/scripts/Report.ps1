. "$PSScriptRoot\Functions.ps1"

# Email Settings
$sendEmail = $false
$title = "Device Report"
$body = "Device report from machine $env:COMPUTERNAME"
$recipients = @("dwild8@dxc.com")

# General configuration
$jsonFileName = "$env:COMPUTERNAME.json" # Name of the output JSON file containing all the data for the report
$reportFolderName = "$env:COMPUTERNAME" # Name of the report folder generate, that has the report index.html within it.
$reportFolderLocation = "$PSScriptRoot\$reportFolderName" # Where to place the report folder.
$buildFolder = "$PSScriptRoot\build" # The folder containing the template HTML Report to input data into

$information = [PSCustomObject]@{
    AntiVirus           = Get-Antivirus;
    WindowsCapabilities = Get-WindowsCapabailities;
    HotFixes            = Get-WMIInfo Win32_QuickFixEngineering;
    RootCertificates    = Get-RootCertificates;
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
    Logs                = Get-Logs;
    BitLocker           = Get-BitLocker;
    GPO                 = Get-GPO;
}

Write-Log "Creating json file."
$json = $information | ConvertTo-Json -Depth 6 -Compress
$json | Set-Content $jsonFileName

Write-Log "Creating report folder."
if (Test-Path $reportFolderLocation) {
    Write-Log "A report at $reportFolderLocation already exists. Deleting this report."
    Remove-Item $reportFolderLocation -Force -Recurse
}

Write-Log "Creating the report build."
Copy-Item $buildFolder $reportFolderLocation -Recurse -Force
Set-Content "$reportFolderLocation\data.js" "window.data = $json;"

gpresult /f /h "$reportFolderLocation\gpo.html"
Write-Log "Created report file at $reportFolderLocation\index.html"

if ($sendEmail -and (Test-Path $reportFolderLocation)) {
    Send-Email -Recipients $recipients -Title $title -Body $body -Report $reportFolderLocation
}

# Invoke-Item -LiteralPath "$reportFolderLocation\index.html"




