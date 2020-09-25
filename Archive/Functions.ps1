Function Get-PowerCfg {
    $powerSettingsString = powercfg /q

    $powerSettings = @{}
    
    foreach ($line in ($powerSettingsString | Select-String '.')) {

        switch -Regex ("Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced)") {
            "Power Scheme GUID: (?<GUID>.*)  \((?<Scheme>.*)\)" {
                $powerSettings.Scheme = @{
                    Name = $matches.Scheme;
                    GUID = $matches.GUID;
                    SubGroups = @();
                }   
            }
            
            "Subgroup GUID: (?<GUID>.*)  \((?<Subgroup>.*)\)" {
                
                if($subgroup){
                    $powerSettings.Scheme.Subgroups += $subgroup
                }
                
                $subgroup = @{
                    GUID = $matches.GUID;
                    Name = $matches.Subgroup;
                }
            }

            "" {

            }
        }
        
    }
    
}