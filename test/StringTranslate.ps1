$test = Get-WindowsCapability -Online

$state = @{
    n = "State";
    e = {
        return [string]$_.State
    }
}

$test2 = $test | Select -Property * 