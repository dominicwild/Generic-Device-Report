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

$a = Get-PowerConfig | Convertto-Json -Depth 4
$a | Set-Content "C:\Users\dwild8\Documents\VsCode\Generic Device Report\test.json"