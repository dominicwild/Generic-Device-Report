$Outlook = New-Object -ComObject Outlook.Application

$Mail = $Outlook.CreateItem(0)

# https://docs.microsoft.com/en-gb/office/vba/outlook/how-to/items-folders-and-stores/attach-a-file-to-a-mail-item
$attachments = $Mail.Attachments
$attachments.Add("C:\Users\dwild8\Documents\VsCode\Generic Device Report\src\scripts\GB-5CG002691G.zip")

$Mail.Recipients.Add("dwild8@dxc.com")
$Mail.Subject = "Test"
$Mail.Body = "testing"


$Mail.Send()


$Outlook.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Outlook) | Out-Null

Function New-Zip {
    $compress = @{
        Path        = "C:\Users\dwild8\Documents\VsCode\Generic Device Report\src\scripts\GB-5CG002691G";
        Destination = "C:\Users\dwild8\Documents\VsCode\Generic Device Report\src\scripts\GB-5CG002691G.zip";
    }

    Compress-Archive @compress -Force
}

