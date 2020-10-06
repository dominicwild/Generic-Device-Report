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

    $regSoftware = $regSoftware | ? { $_.DisplayName } |  Sort-Object -Unique -Property DisplayName


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
            InstallDate      = ConvertTo-DateTime $installedSoftware.InstallDate;
            InstallLocation  = $installedSoftware.InstallLocation; # Not Common
            UninstallString  = $installedSoftware.UninstallString;
            HelpTelephone    = $installedSoftware.HelpTelephone; # Not Common
            Contact          = $installedSoftware.Contact; # Not Common
            Language         = $installedSoftware.Language;
            URLUpdateInfo    = $installedSoftware.URLUpdateInfo; # Not Common
            Comments         = $installedSoftware.Comments; # Not Common
            HelpLink         = $installedSoftware.HelpLink; # Not Common
            ModifyPath       = $installedSoftware.ModifyPath; 
            URLInfoAbout     = $installedSoftware.URLInfoAbout; # Not Common
            EstimatedSize    = $installedSoftware.EstimatedSize;
            Publisher        = $installedSoftware.Publisher; 
            Size             = $installedSoftware.Size
        }
    }
   
    Write-Log "Detected $($software.Count) pieces of software on $env:COMPUTERNAME."

    return $software
}

Function Get-AppXSoftware {
    Write-Log "Searching AppX packages."
    try {
        return Get-AppxPackage -AllUsers | Select-Object -Property * -ExcludeProperty PackageUserInformation | ConvertTo-EnumsAsStrings -Depth 4 
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

Function Get-TPMSettings {
    Write-Log "Getting TPM Settings."
    return Get-TPM | ConvertTo-EnumsAsStrings
}

Function Get-WMIInfo ($class) {
    Write-Log "Getting information from WMI Object '$class'."
    $exclude = @("Scope", "Path", "Options", "ClassPath", "Properties", "SystemProperties", "__GENUS", "__CLASS", 
        "__SUPERCLASS", "__DYNASTY", "__RELPATH", "__PROPERTY_COUNT", "__DERIVATION" , 
        "__SERVER", "__NAMESPACE", "__PATH", "PSComputerName")
    return  Get-WmiObject -Class $class | Select-Object -Property * -ExcludeProperty $exclude
}

Function Get-Antivirus {
    Write-Log "Getting antivirus data."
    return Get-MpComputerStatus | Select-Object -Property * -ExcludeProperty CimClass, CimInstanceProperties, CimSystemProperties, PSComputerName
}

Function Get-System {
    Write-Log "Getting System information."
    $system = Get-WMIInfo Win32_ComputerSystem;
    return $system
}

Function Get-NetworkInterfaces {
    Write-Log "Getting network interfaces."
    return Get-NetAdapter | Select-Object -Property * -ExcludeProperty CimClass, CimInstanceProperties, CimSystemProperties, PSComputerName, HigherLayerInterfaceIndices
}

Function Get-ActivationStatus {
    Write-Log "Getting Activation Status."

    $licenseStatus = @{0 = "Unlicensed"; 1 = "Licensed"; 2 = "Out Of Box Grace Period"; 3 = "Out Of Time Grace period"; 4 = "Non-Genuine Grace Period"; 5 = "Notification Period"; 6 = "Extended Grace Period" }
    $ActivationStatus = $licenseStatus[[int]$(Get-WmiObject SoftwareLicensingProduct -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f' AND PartialProductKey like '%'").LicenseStatus]
    return $ActivationStatus
}

Function Get-Storage {
    Write-Log "Getting storage information."
    return Get-Volume | Select-Object -Property * -ExcludeProperty CimClass, CimInstanceProperties, CimSystemProperties, PSComputerName
}

Function Get-OperatingSystem {
    Write-Log "Getting Operating System Information."
    $OperatingSystem = Get-WMIInfo Win32_OperatingSystem

    $InstallDate = ConvertTo-DateTime $OperatingSystem.InstallDate.ToString()
    $OperatingSystem.InstallDate = $InstallDate
    
    return $OperatingSystem 
}

Function Get-RegValues ($location) {
    Write-Log "Getting registry values from '$location'."
    return Get-ChildItem $location -Recurse | Get-ItemProperty | Select-Object -Property * -Exclude PSProvider
}

Function Get-BitLocker {
    # Needs parsing
    (manage-bde.exe -status)
}

Function Get-Logs {
    # Get System logs from software and filter based on useful ones
}

Function Get-RootCertificates {
    Write-Log "Getting root certificates."
    return Get-Certificates Cert:\LocalMachine\Root
}

Function Get-DirectAccessCertificates {
    Write-Log "Getting direct access certificates."
    return Get-Certificates Cert:\LocalMachine\My
}

Function Get-Certificates ($location) {
    return Get-ChildItem $location | Select-Object -Property * -ExcludeProperty PSDrive, PSProvider, PSChildName, PSPath, PSParentPath
}

Function ConvertTo-DateTime([string]$dateString) {
    switch -Regex ($dateString) {

        "^\d{14}\.\d{6}\+\d{3}$" {
            $dateArgs = @{Year = $date.SubString(0, 4); Month = $date.SubString(4, 2); Day = $date.SubString(6, 2); Hour = $date.SubString(8, 2); Minute = $date.SubString(10, 2) }
            $date = Get-Date @dateArgs
            return $date | Select-Object -Property *
        }

        "^\d{8}$" {
            $dateArgs = @{Year = $dateString.SubString(0, 4); Month = $dateString.SubString(4, 2); Day = $dateString.SubString(6, 2); }
            $date = Get-Date @dateArgs
            return $date | Select-Object -Property *
        }

        default {
            try {
                return ([DateTime]$dateString) | Select-Object -Property *
            } catch {
                return $null
            }
        }
    }
}

Function Get-MSInfo32 {
    Write-Log "Getting MSInfo32 info."
    $MSInfo32 = Get-ComputerInfo

    return $MSInfo32 | ConvertTo-EnumsAsStrings -Depth 4
}

Function Get-WindowsCapabailities {
    Write-Log "Getting Windows capabilities."
    return Get-WindowsCapability -Online  | ConvertTo-EnumsAsStrings -Depth 4
}

Function Get-FirewallRules {
    Write-Log "Getting firewall rules."
    return Get-NetFirewallRule | Select-Object -Property * -ExcludeProperty CimClass, CimInstanceProperties, CimSystemProperties, PSComputerName | ConvertTo-EnumsAsStrings
}

Function Get-FirewallProfiles {
    Write-Log "Getting firewall profiles."
    return Get-NetFirewallProfile | Select-Object -Property * -ExcludeProperty CimClass, CimInstanceProperties, CimSystemProperties | ConvertTo-EnumsAsStrings
}

Filter ConvertTo-EnumsAsStrings ([int] $Depth = 2, [int] $CurrDepth = 0) {
    if ($_ -is [enum]) {
        # enum value -> convert to symbolic name as string
        $_.ToString() 
    } elseif ($null -eq $_ -or $_.GetType().IsPrimitive -or $_ -is [string] -or $_ -is [decimal] -or $_ -is [datetime] -or $_ -is [datetimeoffset]) {
        $_
    } elseif ($_ -is [Collections.IEnumerable]) {
        , ($_ | ConvertTo-EnumsAsStrings -Depth $Depth -CurrDepth ($CurrDepth + 1))
    } else {
        # non-primitive type -> recurse on properties
        if ($CurrDepth -gt $Depth) {
            # depth exceeded -> return .ToString() representation
            "$_"
        } else {
            $oht = [ordered] @{}
            foreach ($prop in $_.psobject.properties) {
                if ($prop.Value -is [Collections.IEnumerable] -and -not $prop.Value -is [string]) {
                    $oht[$prop.Name] = @($prop.Value | ConvertTo-EnumsAsStrings -Depth $Depth -CurrDepth ($CurrDepth + 1))
                } else {      
                    $oht[$prop.Name] = $prop.Value | ConvertTo-EnumsAsStrings -Depth $Depth -CurrDepth ($CurrDepth + 1)
                }
            }
            $oht
        }
    }
}