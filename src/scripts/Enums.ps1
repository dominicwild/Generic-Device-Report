enum CPUArchitecture {
    x86; MIPS; Alpha; PowerPC; ARM; ia64; x64 = 9;
}

enum CPUAvailability {
    Other = 1; Unknown; RunningOrFullPower; Warning; InTest; NotApplicable; 
    PowerOff; OffLine; OffDuty; Degraded; NotInstalled; InstallError; 
    PowerSaveUnknown; PowerSaveLowPower; PowerSaveStandby; PowerCycle; 
    PowerSaveWarning; Paused; NotReady; NotConfigured; Quiesced;
}
 
enum CPUStatus {
    Unknown;Enabled;DisabledByUserFromBIOS;DisabledByBIOS;Idle;Reserved1;Reserved2;Other
}

Function ConvertTo-SplitOnCapitalLetters($string) {
    $split = $string -csplit "([A-Z][a-z]+)" | ? { $_ }
    return $split -join " "
}
