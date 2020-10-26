Function Get-Ivanti {

    $ivantiServiceName = "Ivanti Device and Application Control Command and Control"
    $ivantiProcessName = "RTNotify"

    $ivantiService = Get-Service | ? { $_.DisplayName -eq $ivantiServiceName } 

    $sxPublicKeyExists = Test-Path "C:\Windows\sxdata\sx-public.key" 

    $ivantiProcess = Get-Process | ? { $_.ProcessName -eq $ivantiProcessName } 

    $ivantiServers = Get-ItemPropertyValue "HKLM:\SYSTEM\CurrentControlSet\Services\scomc\Parameters" -Name "Servers" 
    $ivantiServers = if ($ivantiServers) { $ivantiServers.split(" ") } 
    $serverPings = @() 

    foreach ($server in $ivantiServers) { 
        $serverPings += @{ 
            Server = $server; 
            Ping   = Test-Connection ($server -replace ":.*", "") -Quiet; 
        } 
    } 

    $sxDataFiles = Get-ChildItem "C:\Windows\sxdata" 
    $lastUpdatedTimeSpan = $null 
    $potentialIssue = $false 

    foreach ($file in $sxDataFiles) {
        if ($file.Name -match ".cch$") {
            $lastUpdatedTimeSpan = (Get-Date) - $file.LastWriteTime 
            if ($lastUpdatedTimeSpan.Day -gt 14) { 
                $potentialIssue = $true 
            } 
        }
    }

    $ivanti = @{
        ServiceStatus             = $ivantiService.Status;
        PublicKeyExists           = $sxPublicKeyExists;
        ProcessRunning            = ($null -ne $ivantiProcess);
        ServerPings               = $serverPings;
        CCHPermissionsLastUpdated = $lastUpdatedTimeSpan;
    }

    return $ivanti
}

Get-Ivanti


