$a = quser

$a -match ">([a-Z]*)\s"
$matches

$a | Select-String -Pattern ">.*?\s" 




(((quser) -replace '^>', '') -replace '\s{2,}', ',').Trim() | ForEach-Object {
    if ($_.Split(',').Count -eq 5) {
        Write-Output ($_ -replace '(^[^,]+)', '$1,')
    } else {
        Write-Output $_
    }
} | ConvertFrom-Csv