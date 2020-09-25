$regSoftware = @()

$regSoftware += Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | % { Get-ItemProperty $_.Name.Replace("HKEY_LOCAL_MACHINE", "HKLM:") }
$regSoftware += Get-ChildItem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | % { Get-ItemProperty $_.Name.Replace("HKEY_LOCAL_MACHINE", "HKLM:") }

$regSoftware = $regSoftware | Sort-Object -Unique -Property DisplayName

$props = @{}
$propNames = @()

foreach ($software in $regSoftware) {
    $members = $software | Get-Member | ? { $_.MemberType -eq "NoteProperty" }
    foreach ($member in $members) {
        $props."$($member.Name)" += 1
        $propNames += $member.Name
    }
}

$propNames = $propNames | Sort-Object -Unique
$tally = @()

foreach($member in $propNames){
    $count = ($regSoftware |? {$_.$member}).Count
    $tally += [PSCustomObject]@{Name = $member; Count = $count;}
}

$tally | Sort-Object -Property Count