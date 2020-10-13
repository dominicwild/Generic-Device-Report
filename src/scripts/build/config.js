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
// Name: "Total RAM",
//           Value: `${(CsPhyicallyInstalledMemory / 1024 ** 2)}GB`,
//           function: value => {
//             if(CsModel === "Virtual Machine"){
//               return `${(TotalVisibleMemorySize / 1024 ** 2)}GB`
//             }
//             return value;
//           },

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

console.log(powerSettings);

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
      title: "Storage",
      data: window.data.Storage,
      columns: [
        {
          Name: "File System Label",
          Value: "FileSystemLabel",
        },
        {
          Name: "Driver Letter",
          Value: "DriverLetter",
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
      title: "Power Settings",
      // GroupName: group.Name,
      // GroupAlias: group.Alias,
      // ACValue: setting.ACValue,
      // DCValue: setting.DCValue,
      // SettingName: setting.Name,
      // SettingUnit: setting.Unit,
      // SettingAlias: setting.Alias
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
            const date = parseMSDate(value.value);
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
