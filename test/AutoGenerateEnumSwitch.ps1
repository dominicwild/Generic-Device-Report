Function Get-EnumSwitchTemplate
{
    [CmdletBinding()]
    [OutputType([String])]
    Param(
      [Parameter(Mandatory=$False)]
      [Object]$Object=$Null,
      [Parameter(Mandatory=$False)]
      [String]$EnumName="",
      [Parameter(Mandatory=$False)]
      [Object]$EnumObject=$Null,
      [Parameter(Mandatory=$False)]
      [System.Type]$EnumType=$Null)
    Try
    {
        If ($EnumType -NE $Null)
        {
            Write-Verbose "EnumType is $EnumType"
            $Names = [System.Enum]::GetNames($EnumType)
            $Output = "Switch("+"$"+"EnumObject){`n"
            ForEach($Name in $Names)
            {
                $Output += " ""$Name"" {`n"
                $Output += "             # Code for $Name`n" 
                $Output += "             Continue`n" 
                $Output += "             }`n" 
            }
            $Output += "}`n" 
            $Output 
        }
        ElseIf ($EnumObject -NE $Null)
        {
            Write-Verbose "EnumObject is $($EnumObject.GetType())"
            Get-EnumSwitchTemplate $EnumObject
        }
        ElseIf ($EnumName -NE "")
        {
            Write-Verbose "EnumName is $EnumName"
            Get-EnumSwitchTemplate $EnumName
        }
        ElseIf ($Object -Is [System.String])
        {
            Write-Verbose "Object is a string=$Object"
            Get-EnumSwitchTemplate (New-Object -TypeName $Object)
        }
        ElseIf ($Object -Is [System.Enum])
        {
            Write-Verbose "Object is an enum=$($Object.GetType())"
            Get-EnumSwitchTemplate -EnumType (($Object.GetType()) -As [System.Type])
        }
        ElseIf ($Object -Is [System.Type])
        {
            Write-Verbose "Object is a type=$Object"
            Get-EnumSwitchTemplate (New-Object -TypeName $Object)
        }
        ElseIf ($Object -NE $Null)
        {
            Write-Verbose "Object is not an enum"
        }
        Else
        {
            Write-Verbose "Object is Null"
        }
    }
    Catch [System.Exception]
    {
        Write-Host $_.Exception.Message
    }
}