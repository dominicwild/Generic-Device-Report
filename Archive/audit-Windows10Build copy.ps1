<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER XMLOnly
    BOOLEAN Used when you already have the XSL Transform and CSS Files created
    OPTIONAL Defaults to create support files

.PARAMETER FolderPath
    STRING Specifies the Folder that the output is created in
    OPTIONAL Defaults to the folder where the script is executed from

.PARAMETER NoGUI
    BOOLEAN Used to prevent the output displaying on the console
    OPTIONAL Default is to open output in Internet Explorer Window

.EXAMPLE
audit-Windows10Build.ps1

.EXAMPLE
audit-Windows10Build.ps1 -XMLONLY -FolderPath \\server\share\folder

#>
[CmdletBinding()]
Param(
    [switch]$XMLOnly = $false,
    [ValidateScript({if (Test-Path $_ -PathType 'Container'){$true}else{throw "Invalid Path Specified"}})]
        [string]$FolderPath,
    [switch]$NoGUI
)


###########################################################################################
## Revisions
###########################################################################################
## v2.1.4a - Initial Version
## v2.1.5a - 1) Modified to update versions of apps and build
## v2.1.5a - 2) Removed Globalsign Certificate Check as not present at build time
## v2.1.5b - Added TPM Manufacturer tests
## v2.1.5c - 1) Added Certificate Private Key Check
## v2.1.5c - 2) Removed Baltimore Certificate Check as not present at build time
## v2.1.5c - 3) Removed Certificate Count Check
## v2.1.5c - 4) Removed applications that are published to all users and not part of build
## v2.1.5c - 5) Added checks for calulator, photos and camera
## v2.1.5d - 1) Added more cellular information
## v2.1.5e - 1) Modifed to create subfolder based on builddate for output
## v2.1.5e - 2) Fixed Power settings to refect correct expectations

###########################################################################################

$ScriptVersion = "2.1.5e"



Function Audit-PowerSettings() {

    $Test = $xml.CreateElement("Test")
    $Test.SetAttribute("Family",$($MyInvocation.MyCommand -Replace "Audit-")) 

## v2.1.5e - 2) - Start of Change
    $ExpectedValues = @()
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="STANDBYIDLE";PowerState="AC";ExpectedValue=0;TestName="AC Sleep after (minutes)";Models="20JJS0HD00"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="STANDBYIDLE";PowerState="DC";ExpectedValue=6;TestName="DC Sleep after (minutes)";Models="20JJS0HD00"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="HIBERNATEIDLE";PowerState="AC";ExpectedValue=0;TestName="AC Hibernate after (minutes)";Models="20JJS0HD00"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="HIBERNATEIDLE";PowerState="DC";ExpectedValue=120;TestName="DC Hibernate after (minutes)";Models="20JJS0HD00"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_VIDEO";Setting="VIDEOIDLE";PowerState="AC";ExpectedValue=6;TestName="AC Turn Display Off after (minutes)";Models="20JJS0HD00"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_VIDEO";Setting="VIDEOIDLE";PowerState="DC";ExpectedValue=6;TestName="DC Turn Display Off after (minutes)";Models="20JJS0HD00"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="STANDBYIDLE";PowerState="AC";ExpectedValue=0;TestName="AC Sleep after (minutes)";Models="Venue 8 Pro 5855"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="STANDBYIDLE";PowerState="DC";ExpectedValue=15;TestName="DC Sleep after (minutes)";Models="Venue 8 Pro 5855"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="HIBERNATEIDLE";PowerState="AC";ExpectedValue=0;TestName="AC Hibernate after (minutes)";Models="Venue 8 Pro 5855"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_SLEEP";Setting="HIBERNATEIDLE";PowerState="DC";ExpectedValue=120;TestName="DC Hibernate after (minutes)";Models="Venue 8 Pro 5855"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_VIDEO";Setting="VIDEOIDLE";PowerState="AC";ExpectedValue=15;TestName="AC Turn Display Off after (minutes)";Models="Venue 8 Pro 5855"}
    $ExpectedValues+=@{Scheme="SCHEME_BALANCED";SubGroup="SUB_VIDEO";Setting="VIDEOIDLE";PowerState="DC";ExpectedValue=15;TestName="DC Turn Display Off after (minutes)";Models="Venue 8 Pro 5855"}
## v2.1.5e - 2) - End of Change

	foreach ($ExpectedValue in $ExpectedValues){
        if (($ExpectedValue.Models -eq "ALL") -or ($ExpectedValue.Models -match $Global:ComputerModel)) {
            $Reason = (powercfg /Q $ExpectedValue.Scheme $ExpectedValue.SubGroup $ExpectedValue.Setting | ?{$_ -match "Current $($ExpectedValue.PowerState) Power Setting Index"}).split(":")[1]/60
            if ($Reason -match $ExpectedValue.ExpectedValue) {$Result="OK"} else {$Result="Error"}
	        $RunningTest=$xml.CreateElement("TestInstance")
	        $RunningTest.SetAttribute("TestResult",$Result)
            $RunningTest.SetAttribute("TestValue",$Reason)
	        $RunningTest.SetAttribute("TestExpectedValue",$ExpectedValue.ExpectedValue)
	        $RunningTest.SetAttribute("TestName",$ExpectedValue.TestName)
            $Test.AppendChild($RunningTest) | Out-Null
	    }
    }

    $xml.get_ChildNodes().Item($RootItemNumber).AppendChild($Test) | Out-Null

}


If (-not $FolderPath) {$FolderPath=split-path -parent $MyInvocation.MyCommand.Definition}
If (-not ($FolderPath.Substring($FolderPath.Length-1,1) -eq "\")) {$FolderPath+="\"}
$XSLTransformFile = "BuildAudit.xsl"
$CSSFile = "BuildAudit.css"


$xmlHeader=@()
$xmlHeader+='<?xml version="1.0" encoding="utf-16"?>'
$xmlHeader+='<?xml-stylesheet type="text/xsl" href="' + $XSLTransformFile +'"?>'
$xmlHeader+='<Tests></Tests>'
$xml = New-Object xml
$xml.LoadXml($xmlHeader)
$RootItemNumber=$xmlHeader.Count-1


Audit-HardwareInformation
if ($Global:ComputerMake -eq "LENOVO") {Audit-LenovoBIOSSettings}

Audit-SOETaskSequence
Audit-TPMSettings
Audit-PowerSettings
Audit-LanguageCapability
Audit-AntiVirusDefinitions
Audit-HardDiskSettings
Audit-FireWallRules
Audit-InstalledSoftware
Audit-InstalledHotfixes
Audit-RootCertificates
Audit-DirectAccessSettings
Audit-SierraWirelessSettings
Audit-NetworkConnections


$TotalTests=$($xml.Tests.Test.TestInstance | Measure-Object).Count
$TotalErrors=$($xml.Tests.Test.TestInstance | Where-Object {$_.TestResult -eq "Error"} | Measure-Object).Count
$TotalWarnings=$($xml.Tests.Test.TestInstance | Where-Object {$_.TestResult -eq "Warn"} | Measure-Object).Count
$Summary=$xml.Tests
$Summary.SetAttribute("ScriptVersion",$ScriptVersion)
$Summary.SetAttribute("RunBy",$env:USERDOMAIN+"\"+$env:USERNAME)
$Summary.SetAttribute("RunDate",$(Get-Date -Format "dd-MMM-yyyy HH:mm"))
$Summary.SetAttribute("System",$env:COMPUTERNAME)
$Summary.SetAttribute("TotalTests",$TotalTests)
$Summary.SetAttribute("TotalErrors",$TotalErrors)
$Summary.SetAttribute("TotalWarnings",$TotalWarnings)

$XMLFile = $Global:BuildDate + "-" + $env:COMPUTERNAME +  "-AuditReport.xml"

## v2.1.5e - 1) Start of Change
if (Test-Path ($FolderPath+$Global:BuildDate.Substring(0,8) + "\") -PathType 'Container') {
    $FolderPath+=$Global:BuildDate.Substring(0,8) + "\"
    if (-not $XMLONLY) {
        Create-StyleSheet
        Create-XSLTransform
    }
}
else {
    New-Item -Type Directory -Path ($FolderPath+$Global:BuildDate.Substring(0,8) + "\") | Out-Null
    $FolderPath+=$Global:BuildDate.Substring(0,8) + "\"
    Create-StyleSheet
    Create-XSLTransform
}
## v2.1.5e - 1) End of Change


$xml.Save($($FolderPath+$XMLFile)) 


Write-Host "Finished Auditing $env:COMPUTERNAME"
Write-Host "Ran $TotalTests tests, found $TotalErrors Errors and $TotalWarnings Warnings"
Write-Host "Check $FolderPath$XMLFile for details"
if (-not $NoGUI) { Start-Process "iexplore.exe" $($FolderPath + $XMLFile)}