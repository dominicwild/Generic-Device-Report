const {
  WindowsProductName,
  WindowsInstallDateFromRegistry,
  WindowsRegisteredOrganization,
  WindowsVersion,
  OsVersion,
  OsArchitecture,
  OsLanguage,
  BiosName,
  BiosReleaseDate,
  BiosSeralNumber,
  BiosSMBIOSMajorVersion,
  BiosSMBIOSMinorVersion,
  BiosStatus,
  BiosVersion,
  BiosManufacturer,
  CsPhyicallyInstalledMemory,
  CsTotalPhysicalMemory,
  CsDescription,
  CsDNSHostName,
  CsDomain,
  CsPartOfDomain,
  CsManufacturer,
  CsModel,
  CsSystemSKUNumber,
  CsSystemType,
  CsStatus,
} = window.data.MSInfo32;

const Ivanti = window.data.Ivanti;

const ivantiServerPings = [];

for (const serverPing of Ivanti.ServerPings) {
  ivantiServerPings.push({
    Name: `Can Ping ${serverPing.Server}`,
    Value: serverPing.Ping,
  });
}

const GPO = window.data.GPO;

const bitLocker = window.data.BitLocker;
let bitLockerKeyProtection = [];
if (bitLocker) {
  for (const key of bitLocker.KeyProtector) {
    bitLockerKeyProtection.push(key.KeyProtectorType);
  }
}
if (bitLockerKeyProtection.length >= 1) {
  bitLockerKeyProtection = bitLockerKeyProtection.join(", ");
} else {
  bitLockerKeyProtection = "None";
}

const antivirus = window.data.AntiVirus;

const directAccessSettings = window.data.DirectAccess.Setting;

const { TotalVisibleMemorySize } = window.data.Computer.OperatingSystem;

const activationStatus = window.data.Computer.ActivationStatus;

const processor = window.data.MSInfo32.CsProcessors;

const license = {
  0: "Unlicensed",
  1: "Licensed",
  2: "OOB Grace",
  3: "OOT Grace",
  4: "Non Genuine Grace",
  5: "Notification",
  6: "Extended Grace",
};

function parseMSDate(jsonDate) {
  try {
    var date = new Date(parseInt(jsonDate.substr(6)));

    return date.toUTCString();
  } catch {
    return null;
  }
}

function parseADPublisher(adString) {
  const names = adString.split(",").map((item) => {
    return item.trim();
  });
  const types = {};
  let adMappings;
  for (name of names) {
    adMappings = name.split("=");
    if (!types[adMappings[0]]) {
      types[adMappings[0]] = adMappings[1];
    }
  }
  if (types.OU) {
    // Possible values in LDAP CN=Build.net, OU=Microsoft etc
    return types.OU;
  } else if (types.O) {
    return types.O;
  } else if (types.CN) {
    return types.CN;
  } else if (types.E) {
    return types.E;
  } else {
    return "Unknown";
  }
}

function toGB(bytes) {
  const gb = bytes / 1024 ** 3;
  return `${gb.toFixed(2)}`;
}

let ram = 0;
if (CsModel === "Virtual Machine") {
  ram = `${(TotalVisibleMemorySize / 1024 ** 2).toFixed(2)}GB`;
} else {
  ram = `${CsPhyicallyInstalledMemory / 1024 ** 2}GB`;
}

const powerSchemeSubGroups = window.data.Power.Scheme.SubGroups;
const powerSettings = [];

for (const group of powerSchemeSubGroups) {
  for (const setting of group.Settings) {
    let ACValue = setting.ACValue;
    let DCValue = setting.DCValue;

    if (!isNaN(parseInt(setting.ACValue))) {
      ACValue = +setting.ACValue;
    }

    if (!isNaN(parseInt(setting.DCValue))) {
      DCValue = +setting.DCValue;
    }

    powerSettings.push({
      GroupName: group.Name,
      GroupAlias: group.Alias,
      ACValue,
      DCValue,
      SettingName: setting.Name,
      SettingUnit: setting.Unit,
      SettingAlias: setting.Alias,
    });
  }
}

window.config = {
  Overview: [
    {
      title: "Windows",
      data: [
        {
          Name: "OS Installed",
          Value: WindowsProductName,
        },
        {
          Name: "Activation Status",
          Value: activationStatus,
        },
        {
          Name: "Installed Date",
          Value: parseMSDate(WindowsInstallDateFromRegistry),
        },
        {
          Name: "Registered Organisation",
          Value: WindowsRegisteredOrganization,
        },
        {
          Name: "OS Version",
          Value: `${OsVersion} (${WindowsVersion})`,
        },
        {
          Name: "Architecture",
          Value: OsArchitecture,
        },
        {
          Name: "Language",
          Value: OsLanguage,
        },
      ],
    },
    {
      title: "BIOS",
      data: [
        {
          Name: "BIOS Name",
          Value: BiosName,
        },
        {
          Name: "Manufacturer",
          Value: BiosManufacturer,
        },
        {
          Name: "Release Date",
          Value: parseMSDate(BiosReleaseDate),
        },
        {
          Name: "Serial Number",
          Value: BiosSeralNumber,
        },
        {
          Name: "Version",
          Value: `${BiosVersion} (${BiosSMBIOSMajorVersion}.${BiosSMBIOSMinorVersion})`,
        },
        {
          Name: "Status",
          Value: BiosStatus,
        },
      ],
    },
    {
      title: "Computer",
      data: [
        {
          Name: "Host Name",
          Value: CsDNSHostName,
        },
        {
          Name: "Domain",
          Value: CsDomain,
        },
        {
          Name: "Part of Domain",
          Value: CsPartOfDomain,
        },
        {
          Name: "Total RAM",
          Value: `${ram}`,
        },
        {
          Name: "Description",
          Value: CsDescription,
        },
        {
          Name: "Manufacturer",
          Value: CsManufacturer,
        },
        {
          Name: "Model",
          Value: CsModel,
        },
        {
          Name: "SKU",
          Value: CsSystemSKUNumber,
        },
        {
          Name: "System Type",
          Value: CsSystemType,
        },
        {
          Name: "Status",
          Value: CsStatus,
        },
      ],
    },
    {
      title: "Processor",
      data: [
        {
          Name: "Name",
          Value: processor.Name,
        },
        {
          Name: "Manufacturer",
          Value: processor.Manufacturer,
        },
        {
          Name: "Max Clock Speed",
          Value: processor.MaxClockSpeed,
        },
        {
          Name: "Current Clock Speed",
          Value: processor.CurrentClockSpeed,
        },
        {
          Name: "Cores",
          Value: processor.NumberOfCores,
        },
        {
          Name: "Logical Processors",
          Value: processor.NumberOfLogicalProcessors,
        },
        {
          Name: "Status",
          Value: processor.Status,
        },
      ],
    },

    {
      title: "BitLocker",
      data: [
        {
          Name: "Volume",
          Value: bitLocker.MountPoint,
        },
        {
          Name: "Encryption Method",
          Value: bitLocker.EncryptionMethod,
        },
        {
          Name: "Auto Unlock Key Stored",
          Value: bitLocker.AutoUnlockedKeyStored,
        },
        {
          Name: "Status",
          Value: bitLocker.VolumeStatus,
        },
        {
          Name: "Protection Status",
          Value: bitLocker.ProtectionStatus,
        },
        {
          Name: "Lock Status",
          Value: bitLocker.LockStatus,
        },
        {
          Name: "Encryption %",
          Value: bitLocker.EncryptionPercentage,
        },
        {
          Name: "Volume Type",
          Value: bitLocker.VolumeType,
        },
        {
          Name: "Capacity",
          Value: `${+bitLocker.CapacityGB.toFixed(2)}GB`,
        },
        {
          Name: "Key Protector",
          Value: bitLockerKeyProtection,
        },
      ],
    },

    {
      title: "Direct Access Settings",
      data: [
        {
          Name: "Description",
          Value: directAccessSettings.Description,
        },
        {
          Name: "Instance ID",
          Value: directAccessSettings.InstanceID,
        },
        {
          Name: "Manual Entry Point Selection Allowed",
          Value: directAccessSettings.ManualEntryPointSelectionAllowed,
        },
        {
          Name: "Passive Mode",
          Value: directAccessSettings.PassiveMode,
        },
        {
          Name: "Protection Status",
          Value: directAccessSettings.ProtectionStatus,
        },
        {
          Name: "Policy Store",
          Value: directAccessSettings.PolicyStore,
        },
        {
          Name: "Prefer Local Names Allowed",
          Value: directAccessSettings.PreferLocalNamesAllowed,
        },
        {
          Name: "User Interface",
          Value: directAccessSettings.UserInterface,
        },
      ],
    },

    {
      title: "Antivirus",
      data: [
        {
          Name: "Version",
          Value: antivirus.AMProductVersion,
        },
        {
          Name: "Status",
          Value: antivirus.AMRunningMode,
        },
        {
          Name: "Service Enabled",
          Value: antivirus.AMServiceEnabled,
        },
        {
          Name: "Antispyware Enabled",
          Value: antivirus.AntispywareEnabled,
        },
        {
          Name: "Antispyware Last Updated",
          Value: parseMSDate(antivirus.AntispywareSignatureLastUpdated),
        },
        {
          Name: "Antivirus Enabled",
          Value: antivirus.AntivirusEnabled,
        },
        {
          Name: "Antivirus Last Updated",
          Value: parseMSDate(antivirus.AntivirusSignatureLastUpdated),
        },
        {
          Name: "Behaviour Monitor Enabled",
          Value: antivirus.BehaviorMonitorEnabled,
        },
        {
          Name: "Real Time Protection Enabled",
          Value: antivirus.RealTimeProtectionEnabled,
        },
        {
          Name: "On Access Protection Enabled",
          Value: antivirus.OnAccessProtectionEnabled,
        },
        {
          Name: "NIS Enabled",
          Value: antivirus.NISEnabled,
        },
        {
          Name: "NIS Last Updated",
          Value: parseMSDate(antivirus.NISSignatureLastUpdated),
        },
        {
          Name: "Last Quick Scan",
          Value: parseMSDate(antivirus.QuickScanEndTime),
        },
        {
          Name: "Is Virtual Machine",
          Value: antivirus.IsVirtualMachine,
        },
      ],
    },

    {
      title: "GPO",
      data: [
        {
          Name: "Name",
          Value: GPO.Name,
        },
        {
          Name: "Domain",
          Value: GPO.Domain,
        },
        {
          Name: "Site",
          Value: GPO.Site,
        },
        {
          Name: "Version",
          Value: GPO.Version,
        },
        {
          Name: "Scope of Management (OU)",
          Value: GPO.SOM,
        },
        {
          Name: "Slow Link",
          Value: GPO.SlowLink,
        },
      ],
    },

    {
      title: "Ivanti",
      data: [
        {
          Name: "Service Status",
          Value: Ivanti.ServiceStatus != null ? Ivanti.ServiceStatus : "Service Not Detected",
        },
        {
          Name: "Public Key Exists",
          Value: Ivanti.PublicKeyExists,
        },
        {
          Name: "Process Running",
          Value: Ivanti.ProcessRunning,
        },
        {
          Name: "CCH Permissions Last Updated",
          Value: Ivanti.CCHPermissionsLastUpdated,
          modify: (value) => {
            let metric = "";
            let amount = 0;
            if (Math.round(value.TotalDays >= 1)) {
              metric = "day";
              amount = Math.round(value.TotalDays);
            } else if (Math.round(value.TotalHours >= 1)) {
              metric = "hour";
              amount = Math.round(value.TotalHours);
            } else if (Math.round(value.TotalMinutes >= 1)) {
              metric = "minute";
              amount = Math.round(value.TotalMinutes);
            } else if (Math.round(value.TotalSeconds >= 1)) {
              metric = "second";
              amount = Math.round(value.TotalSeconds);
            }

            if (amount > 1) {
              metric = metric + "s";
            }

            return `${amount} ${metric} ago`;
          },
        },
        ...ivantiServerPings,
      ],
    },
  ],

  Tables: [
    {
      title: "Network",
      data: window.data.Network.Interfaces,
      columns: [
        {
          Name: "Name",
          Value: "Name",
        },
        {
          Name: "Description",
          Value: "ifDesc",
        },
        {
          Name: "Link Speed (Mbps)",
          Value: "LinkSpeed",
          function: (value) => {
            return parseInt(value);
          },
        },
        {
          Name: "Status",
          Value: "Status",
        },
        {
          Name: "Driver Version",
          Value: "DriverVersion",
        },
        {
          Name: "Driver File Name",
          Value: "DriverFileName",
        },
        {
          Name: "Driver Provider",
          Value: "DriverProvider",
        },
        {
          Name: "MAC Address",
          Value: "MacAddress",
        },
      ],
    },

    {
      title: "Group Policies (GPO)",
      data: window.data.GPO.GPO,
      columns: [
        {
          Name: "Name",
          Value: "Name",
        },
        {
          Name: "Enabled",
          Value: "Enabled",
        },
        {
          Name: "Path",
          Value: "Link",
          function: (value) => {
            return value.SOMPath;
          },
        },
        {
          Name: "Security Filter",
          Value: "SecurityFilter",
        },
        {
          Name: "Valid",
          Value: "IsValid",
        },
        {
          Name: "Version Directory",
          Value: "VersionDirectory",
        },
        {
          Name: "Version Sysvol",
          Value: "VersionSysvol",
        },
        {
          Name: "Access Denied",
          Value: "AccessDenied",
        },
        {
          Name: "Filter Allowed",
          Value: "FilterAllowed",
        },
      ],
    },

    {
      title: "Security Groups",
      data: window.data.GPO.SecurityGroup,
      columns: [
        {
          Name: "Name",
          Value: "Name",
        },
        {
          Name: "SID",
          Value: "SID",
        },
      ],
    },

    {
      title: "Scope of Management",
      data: window.data.GPO.SearchedSOM,
      columns: [
        {
          Name: "Order",
          Value: "Order",
        },
        {
          Name: "Path",
          Value: "Path",
        },
        {
          Name: "Type",
          Value: "Type",
        },
        {
          Name: "Blocks Inheritance",
          Value: "BlocksInheritance",
        },
        {
          Name: "Blocked",
          Value: "Blocked",
        },
        {
          Name: "Reason",
          Value: "Reason",
        },
      ],
    },

    {
      title: "Storage",
      data: window.data.Storage,
      columns: [
        {
          Name: "File System Label",
          Value: "FileSystemLabel",
        },
        {
          Name: "Driver Letter",
          Value: "DriveLetter",
        },
        {
          Name: "Type",
          Value: "FileSystemType",
        },
        {
          Name: "Drive Type",
          Value: "DriveType",
        },
        {
          Name: "Allocation Unit Size",
          Value: "AllocationUnitSize",
        },
        {
          Name: "Size (GB)",
          Value: "Size",
          function: (value) => {
            return toGB(value);
          },
        },
        {
          Name: "Size Remaining (GB)",
          Value: "SizeRemaining",
          function: (value) => {
            return toGB(value);
          },
        },
        {
          Name: "Status",
          Value: "OperationalStatus",
        },
      ],
    },

    {
      title: "CSC Applications (Registry)",
      data: window.data.Registry.CSC.Applications,
      columns: [
        {
          Name: "Name",
          Value: "PSChildName",
        },
        {
          Name: "Installed",
          Value: "Installed",
        },
        {
          Name: "Account",
          Value: "Account",
        },
        {
          Name: "Deployment Method",
          Value: "DeploymentMethod",
        },
        {
          Name: "Start Time",
          Value: "StartTime",
        },
        {
          Name: "Finish Time",
          Value: "FinishTime",
        },
        {
          Name: "Install Time",
          Value: "InstallTime",
        },
        {
          Name: "Install Date",
          Value: "InstallDate",
        },
        {
          Name: "Exit Code",
          Value: "ExitCode",
        },
        {
          Name: "Exit Description",
          Value: "ExitDescription",
        },
      ],
    },

    {
      title: "CSC Packages (Registry)",
      data: window.data.Registry.CSC.Packages,
      columns: [
        {
          Name: "Name",
          Value: "PSChildName",
        },
        {
          Name: "Description",
          Value: "(default)",
        },
        {
          Name: "Installed",
          Value: "Installed",
        },
        {
          Name: "Install Date",
          Value: "InstallDate",
        },
      ],
    },

    {
      title: "Windows Capabilities",
      data: window.data.WindowsCapabilities,
      columns: [
        {
          Name: "Name",
          Value: "Name",
        },
        {
          Name: "State",
          Value: "State",
        },
      ],
    },

    {
      title: "Event Logs",
      data: window.data.Logs,
      options: {
        columnDefs: [{ width: "100px", targets: [3] }],
      },
      columns: [
        {
          Name: "ID",
          Value: "Id",
        },
        {
          Name: "Level",
          Value: "LevelDisplayName",
        },
        {
          Name: "Provider",
          Value: "ProviderName",
        },
        {
          Name: "Date",
          Value: "TimeCreated",
          function: (value) => {
            return parseMSDate(value);
          },
        },
        {
          Name: "Description",
          Value: "Message",
        },
      ],
    },

    {
      title: "Power Settings",
      data: powerSettings,
      columns: [
        {
          Name: "Name",
          Value: "SettingName",
        },
        {
          Name: "AC Value",
          Value: "ACValue",
        },
        {
          Name: "DC Value",
          Value: "DCValue",
        },
        {
          Name: "Unit",
          Value: "SettingUnit",
        },
        {
          Name: "Setting Alias",
          Value: "SettingAlias",
        },
        {
          Name: "Group Name",
          Value: "GroupName",
        },
        {
          Name: "Group Alias",
          Value: "GroupAlias",
        },
      ],
    },

    {
      title: "Hot Fixes",
      data: window.data.HotFixes,
      options: {
        dateFormat: "dddd, MMMM Do, YYYY",
      },
      columns: [
        {
          Name: "Hot Fix ID",
          Value: "HotFixID",
        },
        {
          Name: "Description",
          Value: "Description",
        },
        {
          Name: "Install Date",
          Value: "InstalledOn",
          function: (value) => {
            const date = parseMSDate(value?.value);
            return date;
          },
        },
        {
          Name: "URL",
          Value: "Caption",
          function: (value) => {
            const url = `https://support.microsoft.com/en-us/help/${value.match("[0-9]+")[0]}`;
            return `${url}`;
          },
        },
      ],
    },

    {
      title: "Root Certificates",
      data: window.data.RootCertificates,
      columns: [
        {
          Name: "Name",
          Value: "FriendlyName",
          function: (value, row) => {
            if (!value) {
              return parseADPublisher(row.Issuer);
            }
            return value;
          },
        },
        {
          Name: "Thumbprint",
          Value: "Thumbprint",
        },
        {
          Name: "Serial Number",
          Value: "SerialNumber",
        },
        {
          Name: "Version",
          Value: "Version",
        },
      ],
    },

    {
      title: "Firewall Profiles",
      data: window.data.Firewall.Profiles,
      columns: [
        {
          Name: "Profile",
          Value: "Profile",
        },
        {
          Name: "Enabled",
          Value: "Enabled",
        },
        {
          Name: "Description",
          Value: "Description",
          function: (value) => {
            return value === null ? "None" : value;
          },
        },
        {
          Name: "Default Inbound Action",
          Value: "DefaultInboundAction",
        },
        {
          Name: "Default Outbound Action",
          Value: "DefaultOutboundAction",
        },
        {
          Name: "Allow Inbound Rules",
          Value: "AllowInboundRules",
        },
        {
          Name: "Allow Local Firewall Rules",
          Value: "AllowLocalFirewallRules",
        },
        {
          Name: "Allow User Apps",
          Value: "AllowUserApps",
        },
        {
          Name: "Allow User Ports",
          Value: "AllowUserPorts",
        },
        {
          Name: "Allow Unicast Response To Multicast",
          Value: "AllowUnicastResponseToMulticast",
        },
        {
          Name: "Allow Unicast Response To Multicast",
          Value: "AllowUnicastResponseToMulticast",
        },
        {
          Name: "Notify On Listen",
          Value: "NotifyOnListen",
        },
        {
          Name: "Enable Stealth Mode For IPsec",
          Value: "EnableStealthModeForIPsec",
        },
      ],
    },

    {
      title: "Firewall Rules",
      data: window.data.Firewall.Rules,
      columns: [
        {
          Name: "Name",
          Value: "DisplayName",
        },
        {
          Name: "Unique Name",
          Value: "Name",
        },
        {
          Name: "Profile",
          Value: "Profile",
        },
        {
          Name: "Enabled",
          Value: "Enabled",
        },
        {
          Name: "Direction",
          Value: "Direction",
        },
        {
          Name: "Action",
          Value: "Action",
        },
        {
          Name: "Description",
          Value: "Description",
        },
        {
          Name: "Status",
          Value: "PrimaryStatus",
        },
        {
          Name: "Status Code",
          Value: "StatusCode",
        },
      ],
    },

    {
      title: "Software (Registry)",
      data: window.data.Software.Registry,
      options: {
        columnDefs: [
          // { width: '100px', targets: [2] }
        ],
      },
      columns: [
        {
          Name: "Name",
          Value: "Name",
        },
        {
          Name: "Version",
          Value: "Version",
          function: (value, row) => {
            let version = "";
            if (row.VersionMajor) {
              version = row.VersionMajor;
              if (row.VersionMinor) {
                version += "." + row.VersionMinor;
              }
              return version;
            } else {
              return value;
            }
          },
        },
        {
          Name: "Install Source",
          Value: "InstallSource",
          function: (value, row) => {
            if (value) {
              return value;
            } else {
              return row.InstallLocation;
            }
          },
        },
        {
          Name: "Install Date",
          Value: "InstallDate",
          function: (value) => {
            return parseMSDate(value?.Date);
          },
        },
        {
          Name: "Publisher",
          Value: "Publisher",
        },
        {
          Name: "Estimated Size",
          Value: "EstimatedSize",
        },
        {
          Name: "Contact",
          Value: "HelpTelephone",
          function: (value, row) => {
            if (value) {
              return value;
            } else {
              return row.Contact;
            }
          },
        },
        // {
        //   Name: "Read Me",
        //   Value: "Readme",
        // },
        // {
        //   Name: "Help",
        //   Value: "HelpLink",
        //   function: (value, row) => {
        //     if (value) {
        //       return value;
        //     } else {
        //       return row.URLInfoAbout;
        //     }
        //   },
        // },
      ],
    },

    {
      title: "Software (AppX)",
      data: window.data.Software.AppX,
      columns: [
        {
          Name: "Name",
          Value: "Name",
        },
        {
          Name: "Version",
          Value: "Version",
        },
        {
          Name: "Publisher",
          Value: "Publisher",
          function: (value) => {
            return parseADPublisher(value);
          },
        },
        {
          Name: "Architecture",
          Value: "Architecture",
        },
        {
          Name: "Install Status",
          Value: "PackageUserInformation",
          function: (value) => {
            return value.InstallState;
          },
        },
        {
          Name: "Install Location",
          Value: "InstallLocation",
        },
        {
          Name: "Status",
          Value: "Status",
        },
      ],
    },

    {
      title: "Direct Access Certificates",
      data: window.data.DirectAccess.Certificates,
      columns: [
        {
          Name: "Name",
          Value: "FriendlyName",
          function: (value, row) => {
            if (!value) {
              return parseADPublisher(row.Issuer);
            }
            return value;
          },
        },
        {
          Name: "Thumbprint",
          Value: "Thumbprint",
        },
        {
          Name: "Serial Number",
          Value: "SerialNumber",
        },
        {
          Name: "Version",
          Value: "Version",
        },
      ],
    },

    {
      title: "Desktops",
      data: window.data.Computer.Desktops,
      columns: [
        {
          Name: "Name",
          Value: "Name",
        },
        {
          Name: "Server",
          Value: "__SERVER",
        },
      ],
    },

    {
      title: "Start Up",
      data: window.data.Startup,
      columns: [
        {
          Name: "Name",
          Value: "Name",
        },
        {
          Name: "Description",
          Value: "Description",
        },
        {
          Name: "User",
          Value: "User",
        },
        {
          Name: "Command",
          Value: "Command",
        },
      ],
    },

    {
      title: "Processes",
      data: window.data.Processes,
      columns: [
        {
          Name: "Id",
          Value: "Id",
        },
        {
          Name: "Name",
          Value: "Name",
        },
        {
          Name: "Description",
          Value: "Description",
        },
        {
          Name: "Company",
          Value: "Company",
        },
        {
          Name: "Responding",
          Value: "Responding",
          function: (value) => {
            return "" + value;
          },
        },
        {
          Name: "Private Memory (MB)",
          Value: "PrivateMemorySize",
          function: (value) => {
            return `${(value / 1024 ** 2).toFixed(2)}`;
          },
        },
        {
          Name: "Start Time",
          Value: "StartTime",
          function: (value) => {
            return parseMSDate(value);
          },
        },
      ],
    },

    {
      title: "Services",
      data: window.data.Services,
      columns: [
        {
          Name: "Name",
          Value: "DisplayName",
        },
        {
          Name: "Unique Name",
          Value: "Name",
        },
        {
          Name: "Description",
          Value: "Description",
        },
        {
          Name: "Service Type",
          Value: "ServiceType",
        },
        {
          Name: "Start Mode",
          Value: "StartMode",
        },
        {
          Name: "State",
          Value: "State",
        },
        {
          Name: "Status",
          Value: "Status",
        },
      ],
    },

    {
      title: "Drivers",
      data: window.data.Drivers,
      columns: [
        {
          Name: "Driver",
          Value: "Driver",
        },
        {
          Name: "Provider",
          Value: "ProviderName",
        },
        {
          Name: "Version",
          Value: "Version",
        },
        {
          Name: "Build",
          Value: "Build",
        },
        {
          Name: "Revision",
          Value: "Revision",
        },
        {
          Name: "Boot Critical",
          Value: "BootCritical",
          function: (value) => {
            return "" + value;
          },
        },
        {
          Name: "Restarted Needed",
          Value: "RestartNeeded",
          function: (value) => {
            return "" + value;
          },
        },
        {
          Name: "Date",
          Value: "Date",
          function: (value) => {
            return parseMSDate(value);
          },
        },
      ],
    },

    {
      title: "Licenses",
      data: window.data.Licenses,
      columns: [
        {
          Name: "Name",
          Value: "Name",
        },
        {
          Name: "Description",
          Value: "Description",
        },
        {
          Name: "ID",
          Value: "ID",
        },
        {
          Name: "License Status",
          Value: "LicenseStatus",
          function: (value) => {
            return license[value];
          },
        },
      ],
    },
  ],
};