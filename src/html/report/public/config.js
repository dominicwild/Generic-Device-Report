const Ivanti = window.data.Ivanti;

const ivantiServerPings = [];

for (const serverPing of Ivanti.ServerPings) {
  ivantiServerPings.push({
    Name: `Can Ping ${serverPing.Server}`,
    Value: serverPing.Ping,
    Literal: true,
  });
}

const activationStatus = window.data.Computer.ActivationStatus;

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
  if (types.OU) { // Possible values in LDAP CN=Build.net, OU=Microsoft etc
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

function getProcessors() {
  const processorData = window.data.MSInfo32?.CsProcessors;
  if (!processorData) {
    return [makeProcessorObject(processorData, 0)];
  }
  if (Array.isArray(processorData)) {
    const processors = [];
    let i = 0;
    for (const processor of processorData) {
      processors.push(makeProcessorObject(processor, i));
      i++;
    }
    return processors;
  } else {
    return [makeProcessorObject(processorData, 0)];
  }
}

function makeProcessorObject(processor, num) {
  return {
    title: "CPU" + num,
    data: processor,
    rows: [
      {
        Name: "Name",
        Value: "Name",
      },
      {
        Name: "Manufacturer",
        Value: "Manufacturer",
      },
      {
        Name: "Max Clock Speed",
        Value: "MaxClockSpeed",
      },
      {
        Name: "Current Clock Speed",
        Value: "CurrentClockSpeed",
      },
      {
        Name: "Cores",
        Value: "NumberOfCores",
      },
      {
        Name: "Logical Processors",
        Value: "NumberOfLogicalProcessors",
      },
      {
        Name: "Status",
        Value: "Status",
      },
      {
        Name: "CPU Status",
        Value: "CpuStatus",
      },
    ],
  };
}

const powerSchemeSubGroups = window.data.Power?.Scheme?.SubGroups;
let powerSettings;

if (powerSchemeSubGroups) {
  powerSettings = [];
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
}

const processors = getProcessors();
console.log(processors);

window.config = {
  Overview: [
    {
      title: "Windows",
      data: window.data.MSInfo32,
      rows: [
        {
          Name: "OS Installed",
          Value: "WindowsProductName",
        },
        {
          Name: "Activation Status",
          Value: "activationStatus",
          modify: () => {
            return activationStatus;
          },
        },
        {
          Name: "Installed Date",
          Value: "WindowsInstallDateFromRegistry",
          modify: (val) => {
            return parseMSDate(val);
          },
        },
        {
          Name: "Registered Organisation",
          Value: "WindowsRegisteredOrganization",
        },
        {
          Name: "OS Version",
          Value: "OSVersion",
          modify: (val, data) => {
            const OsVersion = data.OsVersion;
            const WindowsVersion = data.WindowsVersion;
            return `${OsVersion} (${WindowsVersion})`;
          },
        },
        {
          Name: "Architecture",
          Value: "OsArchitecture",
        },
        {
          Name: "Language",
          Value: "OsLanguage",
        },
      ],
    },
    {
      title: "BIOS",
      data: window.data.MSInfo32,
      rows: [
        {
          Name: "BIOS Name",
          Value: "BiosName",
        },
        {
          Name: "Manufacturer",
          Value: "BiosManufacturer",
        },
        {
          Name: "Release Date",
          Value: "BiosReleaseDate",
          modify: (val) => {
            return parseMSDate(val);
          },
        },
        {
          Name: "Serial Number",
          Value: "BiosSeralNumber",
        },
        {
          Name: "Version",
          Value: "BiosVersion",
          modify: (val, data) => {
            const BiosVersion = data.BiosVersion;
            const BiosSMBIOSMajorVersion = data.BiosSMBIOSMajorVersion;
            const BiosSMBIOSMinorVersion = data.BiosSMBIOSMinorVersion;
            return `${BiosVersion} (${BiosSMBIOSMajorVersion}.${BiosSMBIOSMinorVersion})`;
          },
        },
        {
          Name: "Status",
          Value: "BiosStatus",
        },
      ],
    },

    {
      title: "Computer",
      data: window.data.MSInfo32,
      rows: [
        {
          Name: "Host Name",
          Value: "CsDNSHostName",
        },
        {
          Name: "Domain",
          Value: "CsDomain",
        },
        {
          Name: "Part of Domain",
          Value: "CsPartOfDomain",
        },
        {
          Name: "Total RAM",
          Value: "TotalVisibleMemorySize",
          modify: (val, data) => {
            const { CsModel, TotalVisibleMemorySize, CsPhyicallyInstalledMemory } = data;
            let ram = 0;
            if (CsModel === "Virtual Machine") {
              ram = `${(TotalVisibleMemorySize / 1024 ** 2).toFixed(2)}GB`;
            } else {
              ram = `${CsPhyicallyInstalledMemory / 1024 ** 2}GB`;
            }
            return ram;
          },
        },
        {
          Name: "Description",
          Value: "CsDescription",
        },
        {
          Name: "Manufacturer",
          Value: "CsManufacturer",
        },
        {
          Name: "Model",
          Value: "CsModel",
        },
        {
          Name: "SKU",
          Value: "CsSystemSKUNumber",
        },
        {
          Name: "System Type",
          Value: "CsSystemType",
        },
        {
          Name: "Status",
          Value: "CsStatus",
        },
      ],
    },

    ...processors,

    {
      title: "Direct Access Settings",
      data: window.data.DirectAccess?.Setting,
      rows: [
        {
          Name: "Description",
          Value: "Description",
        },
        {
          Name: "Instance ID",
          Value: "InstanceID",
        },
        {
          Name: "Manual Entry Point Selection Allowed",
          Value: "ManualEntryPointSelectionAllowed",
        },
        {
          Name: "Passive Mode",
          Value: "PassiveMode",
        },
        {
          Name: "Protection Status",
          Value: "ProtectionStatus",
        },
        {
          Name: "Policy Store",
          Value: "PolicyStore",
        },
        {
          Name: "Prefer Local Names Allowed",
          Value: "PreferLocalNamesAllowed",
        },
        {
          Name: "User Interface",
          Value: "UserInterface",
        },
      ],
    },

    {
      title: "Antivirus",
      data: window.data.AntiVirus,
      rows: [
        {
          Name: "Version",
          Value: "AMProductVersion",
        },
        {
          Name: "Status",
          Value: "AMRunningMode",
        },
        {
          Name: "Service Enabled",
          Value: "AMServiceEnabled",
        },
        {
          Name: "Antispyware Enabled",
          Value: "AntispywareEnabled",
        },
        {
          Name: "Antispyware Last Updated",
          Value: "AntispywareSignatureLastUpdated",
          modify: (val) => {
            return parseMSDate(val);
          },
        },
        {
          Name: "Antivirus Enabled",
          Value: "AntivirusEnabled",
        },
        {
          Name: "Antivirus Last Updated",
          Value: "AntivirusSignatureLastUpdated",
          modify: (val) => {
            return parseMSDate(val);
          },
        },
        {
          Name: "Behaviour Monitor Enabled",
          Value: "BehaviorMonitorEnabled",
        },
        {
          Name: "Real Time Protection Enabled",
          Value: "RealTimeProtectionEnabled",
        },
        {
          Name: "On Access Protection Enabled",
          Value: "OnAccessProtectionEnabled",
        },
        {
          Name: "NIS Enabled",
          Value: "NISEnabled",
        },
        {
          Name: "NIS Last Updated",
          Value: "NISSignatureLastUpdated",
          modify: (val) => {
            return parseMSDate(val);
          },
        },
        {
          Name: "Last Quick Scan",
          Value: "QuickScanEndTime",
          modify: (val) => {
            return parseMSDate(val);
          },
        },
        {
          Name: "Is Virtual Machine",
          Value: "IsVirtualMachine",
        },
      ],
    },

    {
      title: "GPO",
      data: window.data.GPO,
      rows: [
        {
          Name: "Name",
          Value: "Name",
        },
        {
          Name: "Domain",
          Value: "Domain",
        },
        {
          Name: "Site",
          Value: "Site",
        },
        {
          Name: "Version",
          Value: "Version",
        },
        {
          Name: "Scope of Management (OU)",
          Value: "SOM",
        },
        {
          Name: "Slow Link",
          Value: "SlowLink",
        },
      ],
    },

    {
      title: "Ivanti",
      data: window.data.Ivanti,
      rows: [
        {
          Name: "Service Status",
          Value: "ServiceStatus",
          modify: (val) => {
            return val != null ? val : "Service Not Detected";
          },
        },
        {
          Name: "Public Key Exists",
          Value: "PublicKeyExists",
        },
        {
          Name: "Process Running",
          Value: "ProcessRunning",
        },
        {
          Name: "CCH Permissions Last Updated",
          Value: "CCHPermissionsLastUpdated",
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
      data: window.data.Network?.Interfaces,
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
      data: window.data.GPO?.GPO,
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
      data: window.data.GPO?.SecurityGroup,
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
      data: window.data.GPO?.SearchedSOM,
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
      title: "BitLocker",
      data: window.data.BitLocker,
      columns: [
        {
          Name: "Volume",
          Value: "MountPoint",
        },
        {
          Name: "Encryption Method",
          Value: "EncryptionMethod",
        },
        {
          Name: "Auto Unlock Key Stored",
          Value: "AutoUnlockKeyStored",
        },
        {
          Name: "Status",
          Value: "VolumeStatus",
        },
        {
          Name: "Protection Status",
          Value: "ProtectionStatus",
        },
        {
          Name: "Lock Status",
          Value: "LockStatus",
        },
        {
          Name: "Encryption %",
          Value: "EncryptionPercentage",
        },
        {
          Name: "Volume Type",
          Value: "VolumeType",
        },
        {
          Name: "Capacity",
          Value: "Capacity",
          function: (val, data) => {
            const { CapacityGB } = data;
            return `${+CapacityGB.toFixed(2)}GB`;
          },
        },
        {
          Name: "Key Protector",
          Value: "Key Protector",
          function: (val, data) => {
            let bitLockerKeyProtection = [];

            for (const key of data.KeyProtector) {
              bitLockerKeyProtection.push(key.KeyProtectorType);
            }

            if (bitLockerKeyProtection.length >= 1) {
              return bitLockerKeyProtection.join(", ");
            } else {
              return "None";
            }
          },
        },
      ],
    },

    {
      title: "CSC Applications (Registry)",
      data: window.data?.Registry?.CSC?.Applications,
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
      data: window.data?.Registry?.CSC?.Packages,
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
      data: window.data?.WindowsCapabilities,
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
      data: window.data.Firewall?.Profiles,
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
      data: window.data.Firewall?.Rules,
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
      data: window.data.Software?.Registry,
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
      data: window.data.Software?.AppX,
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
      data: window.data.DirectAccess?.Certificates,
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
      data: window.data.Computer?.Desktops,
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
