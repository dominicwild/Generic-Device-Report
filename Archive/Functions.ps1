Function Get-PowerConfig { 
    $powerSettingsString = powercfg /q

    Enum States {
        SCHEME = 1; POWER_SETTING = 2; SUB_GROUP = 3; POWER_OPTIONS = 4
    }

    $state = ""
    $scheme = $null
    $subgroup = $null
    $powerSetting = $null    
    $schemes = @()

    foreach ($line in ($powerSettingsString | Select-String '.')) {

        switch -Regex ($line) {
            "Power Scheme GUID: (?<GUID>.*)  \((?<Scheme>.*)\)" {

                if ($scheme) {
                    $schemes += $scheme
                }

                $scheme = @{
                    Name      = $matches.Scheme;
                    GUID      = $matches.GUID;
                    SubGroups = @();
                }   

                $state = [States]::SCHEME
                break
            }
            
            "Subgroup GUID: (?<GUID>.*)  \((?<Subgroup>.*)\)" {
                
                if ($subgroup) {
                    $scheme.Subgroups += $subgroup
                }
                
                $subgroup = @{
                    GUID     = $matches.GUID;
                    Name     = $matches.Subgroup;
                    Settings = @();
                }

                $state = [States]::SUB_GROUP
                break
            }

            "Power Setting GUID: (?<GUID>.*)  \((?<PowerSetting>.*)\)" {

                if ($powerSetting) {
                    $subgroup.Settings += $powerSetting;
                }

                $powerSetting = @{
                    GUID = $matches.GUID;
                    Name = $matches.PowerSetting;
                }

                $state = [States]::POWER_SETTING
                break
            }

            "GUID Alias: (?<Alias>.*)" {
                switch ($state) {
                    ([States]::SCHEME) {
                        $scheme.Alias = $matches.Alias
                    }
                    ([States]::SUB_GROUP) {
                        $subgroup.Alias = $matches.Alias
                    }
                    ([States]::POWER_SETTING) {
                        $powerSetting.Alias = $matches.Alias
                    }
                }
                break
            }

            "Minimum Possible Setting: (?<Min>.*)" {
                $powerSetting.Minimum = $matches.Min
                break
            }

            "Maximum Possible Setting: (?<Max>.*)" {
                $powerSetting.Maximum = $matches.Max
                break
            }

            "Possible Setting Friendly Name: (?<Name>.*)" {
                if ($options) {
                    $options += $matches.Name
                } else {
                    $options = @($matches.Name)
                }
                break
            }

            "Possible Settings increment: (?<Increment>.*)" {
                $powerSetting.Increment = $matches.Increment
                break
            }

            "Possible Settings units: (?<Unit>.*)" {
                $powerSetting.Unit = $matches.Unit
                break
            }

            "Current AC Power Setting Index: (?<ACValue>.*)" {
                if ($options) {
                    $powerSetting.ACValue = $options[$matches.ACValue]
                } else {
                    $powerSetting.ACValue = $matches.ACValue
                }
                break
            }

            "Current DC Power Setting Index: (?<DCValue>.*)" {
                if ($options) {
                    $powerSetting.DCValue = $options[$matches.DCValue]
                } else {
                    $powerSetting.DCValue = $matches.DCValue
                }

                $subgroup.Settings += $powerSetting
                $powerSetting = $null
                $options = $null
                break
            }
        }
        
    }

    return $scheme
}

# $a = Get-PowerConfig | Convertto-Json -Depth 4
# $a | Set-Content "C:\Users\dwild8\Documents\VsCode\Generic Device Report\test.json"


# LogName=<String[]>
# ProviderName=<String[]>
# Path=<String[]>
# Keywords=<Long[]>
# ID=<Int32[]>
# Level=<Int32[]>
# StartTime=<DateTime>
# EndTime=<DateTime>
# UserID=<SID>
# Data=<String[]>
# <named-data>=<String[]>
# SuppressHashFilter=<Hashtable>

$unexpectedReboot = @{
    LogName  = "System";
    Provider = "Microsoft-Windows-Kernel-Power";
    ID       = 41;
}

$applicationHang = @{
    LogName  = "Application";
    Provider = "Application Hang";
    ID       = 1002;
}

$serviceFailedToStart = @{
    LogName  = "System";
    Provider = "Service Control Manager";
    ID       = 7000;
}

$applicationFault = @{
    LogName  = "Application";
    Provider = "Application Error";
    ID       = 1000;
}

$events = @(
    @{ # Application Fault
        LogName      = "Application";
        ProviderName = "Application Error";
        ID           = 1000;
    }, 
    @{ # Service Failed to Restart
        LogName      = "System";
        ProviderName = "Service Control Manager";
        ID           = 7000;
    }, 
    @{ # Application Hang
        LogName      = "Application";
        ProviderName = "Application Hang";
        ID           = 1002;
    }, 
    @{ # Service Timeout
        LogName      = "System";
        ProviderName = "Service Control Manager";
        ID           = 7009;
    },
    @{ # Windows Update Failure
        LogName      = "System";
        ProviderName = "Microsoft-Windows-WindowsUpdateClient";
        ID           = 20;
    },
    @{ # Scheduled Task Delayed or Failed
        LogName = "Microsoft-Windows-TaskScheduler/Operational";
        ID      = 201;
    },
    @{ # Unexpected Reboot
        LogName      = "System";
        ProviderName = "Microsoft-Windows-Kernel-Power";
        ID           = 41;
    },
    @{ # System Logs Critical
        LogName = "System";
        Level   = 1;
    },
    @{ # Application Logs Critical
        LogName = "Application";
        Level   = 1;
    }
)

Get-WinEvent -FilterHashtable $events