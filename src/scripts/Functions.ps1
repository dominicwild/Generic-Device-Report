function Write-Log($logLine) {
    $dateString = (Get-Date).GetDateTimeFormats("g")[0]
    $log = "[$dateString] $logLine"
    Add-Content "log.log" $log
    Write-Host $log
}

Function Get-InstalledSoftware {
    Write-Log "Searching for software on $env:COMPUTERNAME"

    $regSoftware = @()
    $software = @()

    $uninstallRegLocation1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall";
    $uninstallRegLocation2 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall";

    Write-Log "Searching registry '$uninstallRegLocation1' for software."
    $regSoftware += Get-ChildItem "$uninstallRegLocation1\*" | % { Get-ItemProperty $_.Name.Replace("HKEY_LOCAL_MACHINE", "HKLM:") }
    $count = $regSoftware.Count
    Write-Log "Found $count pieces of software."

    Write-Log "Searching registry '$uninstallRegLocation2' for software."
    $regSoftware += Get-ChildItem "$uninstallRegLocation2\*" | % { Get-ItemProperty $_.Name.Replace("HKEY_LOCAL_MACHINE", "HKLM:") }
    $count = $regSoftware.Count - $count
    Write-Log "Found $count pieces of software."

    $regSoftware = $regSoftware |? {$_.DisplayName} |  Sort-Object -Unique -Property DisplayName


    foreach ($installedSoftware in $regSoftware) {
        $software += [PSCustomObject]@{
            Name             = $installedSoftware.DisplayName;
            Version          = $installedSoftware.Version;
            VersionMinor     = $installedSoftware.VersionMinor;
            VersionMajor     = $installedSoftware.VersionMajor;
            SystemComponent  = $installedSoftware.SystemComponent;
            Readme           = $installedSoftware.Readme; # Not Common
            WindowsInstaller = $installedSoftware.WindowsInstaller; # Not Common
            InstallSource    = $installedSoftware.InstallSource;
            HelpTelephone    = $installedSoftware.HelpTelephone; # Not Common
            Contact          = $installedSoftware.Contact; # Not Common
            Language         = $installedSoftware.Language;
            URLUpdateInfo    = $installedSoftware.URLUpdateInfo; # Not Common
            Comments         = $installedSoftware.Comments; # Not Common
            InstallDate      = $installedSoftware.InstallDate;
            HelpLink         = $installedSoftware.HelpLink; # Not Common
            ModifyPath       = $installedSoftware.ModifyPath; 
            URLInfoAbout     = $installedSoftware.URLInfoAbout; # Not Common
            InstallLocation  = $installedSoftware.InstallLocation; # Not Common
            EstimatedSize    = $installedSoftware.EstimatedSize;
            Publisher        = $installedSoftware.Publisher; 
            UninstallString  = $installedSoftware.UninstallString;
            Size             = $installedSoftware.Size
        }
    }
   
    Write-Log "Detected $($software.Count) pieces of software on $env:COMPUTERNAME."

    return $software
}

Function Get-AppXSoftware {
    Write-Log "Searching AppX packages."
    try {
        return Get-AppxPackage -AllUsers
    } catch {
        Write-Log "Unable to get AppX packages."
        Write-Log $_
    }
}

Function Get-AppVSoftware {
    Write-Log "Searching AppV packages."
    try {
        return Get-AppvClientPackage -All
    } catch {
        Write-Log "Unable to get AppV packages."
        Write-Log $_
    }
}

Function Get-WMIInfo ($class) {
    return  Get-WmiObject -Class $class | Select-Object -Property *
}

Function Get-System {
    $system = Get-WMIInfo Win32_ComputerSystem;
    return $system
}

Function Get-ActivationStatus {
    $licenseStatus = @{0 = "Unlicensed"; 1 = "Licensed"; 2 = "Out Of Box Grace Period"; 3 = "Out Of Time Grace period"; 4 = "Non-Genuine Grace Period"; 5 = "Notification Period"; 6 = "Extended Grace Period" }
    $ActivationStatus = $licenseStatus[[int]$(Get-WmiObject SoftwareLicensingProduct -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f' AND PartialProductKey like '%'").LicenseStatus]
    return $ActivationStatus
}

Function Get-OperatingSystem {
    $OperatingSystem = Get-WMIInfo Win32_OperatingSystem;

    $date = $OperatingSystem.InstallDate.ToString()
    $dateArgs = @{Year = $date.SubString(0, 4); Month = $date.SubString(4, 2); Day = $date.SubString(6, 2); Hour = $date.SubString(8, 2); Minute = $date.SubString(10, 2) }
    $InstallDate = Get-Date @dateArgs
    $OperatingSystem.InstallDate = $InstallDate
    
    return $OperatingSystem 
}

Function Get-RegValues ($location){
    return Get-ChildItem $location -Recurse | Get-ItemProperty
}

Function Get-BitLocker {
    # Needs parsing
    (manage-bde.exe -status)
}