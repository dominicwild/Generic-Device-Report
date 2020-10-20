$folder = $env:PUBLIC
$fileName = "$env:COMPUTERNAME.xml"
$fileLocation = "$folder/$fileName"

# gpresult /x $fileLocation

[XML]$xml = (Get-Content $fileLocation)
$rsop = $xml.Rsop
$computerResults = $rsop.ComputerResults


Function ConvertTo-HashFromXML($node) {
    $children = $node.ChildNodes
    try {
        if ($children.Count -gt 0 -and -not ($children[0].GetType().Name -eq "XmlText")) {
            $parentHash = @{}
            foreach ($child in $children) {
                $result = ConvertTo-HashFromXML $child
                $childNode = $parentHash."$($result.Name)"
                if ($childNode) {
                    if($childNode.GetType().Name -eq "Object[]"){
                        $parentHash."$($result.Name)" += $result.Value
                    } else {
                        $list = @($childNode, $result.Value)
                        $parentHash."$($result.Name)" = $list
                    }
                } else {
                    $parentHash."$($result.Name)" = $result.Value
                }
            }
            return @{
                Name  = $node.LocalName; 
                Value = $parentHash; 
            }
        } else {
            return @{
                Name  = $node.LocalName;
                Value = $node.InnerText;
            }
        }
    } catch {
        Write-Host "Got"
    }
}

$a = ConvertTo-HashFromXML -Node $computerResults
