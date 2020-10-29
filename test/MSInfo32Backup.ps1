$MSInfo32R = Get-ComputerInfo
    $properties = $MSInfo32R | Get-Member |? {$_.MemberType -eq "Property"}
    foreach($prop in $properties){
        $propName = $prop.Name
        if(-not $MSInfo32["Cs$propName"] -eq $MSInfo32R.$propName -and $MSInfo32["Cs$propName"]){
            $computerInfVal = $MSInfo32["Cs$propName"]
            $info32Val = $MSInfo32R.$propName
            Write-Host "[$propName]Value '$info32Val' differs from '$computerInfVal'"
        } else {
            Write-Host "same"
        }
    }