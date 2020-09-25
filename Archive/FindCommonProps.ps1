$regSoftware = @()

$regSoftware += Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | % { Get-ItemProperty $_.Name.Replace("HKEY_LOCAL_MACHINE", "HKLM:") }
$regSoftware += Get-ChildItem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | % { Get-ItemProperty $_.Name.Replace("HKEY_LOCAL_MACHINE", "HKLM:") }

$regSoftware = $regSoftware | Sort-Object -Unique -Property DisplayName

$props = @{}

foreach ($software in $regSoftware) {
    $members = $software | Get-Member | ? { $_.MemberType -eq "NoteProperty" }
    foreach ($member in $members) {
        $props."$($member.Name)" += 1
    }
}

foreach ($software in $regSoftware2) {
    $members = $software | Get-Member | ? { $_.MemberType -eq "NoteProperty" }
    foreach ($member in $members) {
        $props."$($member.Name)" += 1
    }
}

foreach ($prop in $props) {
    if ($prop.Value -eq $regSoftware.Count) {
        Write-Host $props.Name
    }
}