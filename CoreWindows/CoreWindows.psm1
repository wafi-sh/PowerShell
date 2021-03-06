﻿<#
.Synopsis
   Get general information about the current domain.
.DESCRIPTION
    Get list of domain controllers on the current domain along with the FSMO roles for each one.
#>
function Get-DomainInfo
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (

    )

    Begin
    {
    }
    Process
    {
        Import-Module ActiveDirectory

        $schema = Get-ADObject -SearchBase ((Get-ADRootDSE).schemaNamingContext) `
            -SearchScope OneLevel -Filter * -Property objectClass, name, whenChanged,`
            whenCreated, attributeID | Select-Object objectClass, attributeID, name,`
            whenCreated, whenChanged, `
            @{name="event";expression={($_.whenCreated).Date.ToString("yyyy-MM-dd")}} |
            Sort-Object event, objectClass, name
<#
        "`nDetails of schema objects created by date:"
        $schema | Format-Table objectClass, attributeID, name, whenCreated, whenChanged `
            -GroupBy event -AutoSize
#>
        "`nCount of schema objects created by date:"
        $schema | Group-Object event | Format-Table Count, Name, Group -AutoSize

        $schema | Export-CSV .\schema.csv -NoTypeInformation
        "`nSchema CSV output here: .\schema.csv"

        #------------------------------------------------------------------------------

        "`nForest domain creation dates:"
        Get-ADObject -SearchBase (Get-ADForest).PartitionsContainer `
            -LDAPFilter "(&(objectClass=crossRef)(systemFlags=3))" `
            -Property dnsRoot, nETBIOSName, whenCreated |
          Sort-Object whenCreated |
          Format-Table dnsRoot, nETBIOSName, whenCreated -AutoSize

        #------------------------------------------------------------------------------

        $SchemaVersions = @()

        $SchemaHashAD = @{
            13="Windows 2000 Server";
            30="Windows Server 2003 RTM";
            31="Windows Server 2003 R2";
            44="Windows Server 2008 RTM";
            47="Windows Server 2008 R2";
            56="Windows Server 2012 RTM";
            69="Windows Server 2012 R2"
            }

        $SchemaPartition = (Get-ADRootDSE).NamingContexts | Where-Object {$_ -like "*Schema*"}
        $SchemaVersionAD = (Get-ADObject $SchemaPartition -Property objectVersion).objectVersion
        $SchemaVersions += 1 | Select-Object `
            @{name="Product";expression={"AD"}}, `
            @{name="Schema";expression={$SchemaVersionAD}}, `
            @{name="Version";expression={$SchemaHashAD.Item($SchemaVersionAD)}}

        #------------------------------------------------------------------------------

        $SchemaHashExchange = @{
            4397="Exchange Server 2000 RTM";
            4406="Exchange Server 2000 SP3";
            6870="Exchange Server 2003 RTM";
            6936="Exchange Server 2003 SP3";
            10628="Exchange Server 2007 RTM";
            10637="Exchange Server 2007 RTM";
            11116="Exchange 2007 SP1";
            14622="Exchange 2007 SP2 or Exchange 2010 RTM";
            14625="Exchange 2007 SP3";
            14726="Exchange 2010 SP1";
            14732="Exchange 2010 SP2";
            14734="Exchange 2010 SP3";
            15137="Exchange 2013 RTM";
            15254="Exchange 2013 CU1";
            15281="Exchange 2013 CU2";
            15283="Exchange 2013 CU3";
            15292="Exchange 2013 SP1";
            15300="Exchange 2013 CU5";
            15303="Exchange 2013 CU6"
            }

        $SchemaPathExchange = "CN=ms-Exch-Schema-Version-Pt,$SchemaPartition"
        If (Test-Path "AD:$SchemaPathExchange") {
            $SchemaVersionExchange = (Get-ADObject $SchemaPathExchange -Property rangeUpper).rangeUpper
        } Else {
            $SchemaVersionExchange = 0
        }

        $SchemaVersions += 1 | Select-Object `
            @{name="Product";expression={"Exchange"}}, `
            @{name="Schema";expression={$SchemaVersionExchange}}, `
            @{name="Version";expression={$SchemaHashExchange.Item($SchemaVersionExchange)}}

        #------------------------------------------------------------------------------

        $SchemaHashLync = @{
            1006="LCS 2005";
            1007="OCS 2007 R1";
            1008="OCS 2007 R2";
            1100="Lync Server 2010";
            1150="Lync Server 2013"
            }

        $SchemaPathLync = "CN=ms-RTC-SIP-SchemaVersion,$SchemaPartition"
        If (Test-Path "AD:$SchemaPathLync") {
            $SchemaVersionLync = (Get-ADObject $SchemaPathLync -Property rangeUpper).rangeUpper
        } Else {
            $SchemaVersionLync = 0
        }

        $SchemaVersions += 1 | Select-Object `
            @{name="Product";expression={"Lync"}}, `
            @{name="Schema";expression={$SchemaVersionLync}}, `
            @{name="Version";expression={$SchemaHashLync.Item($SchemaVersionLync)}}

        #------------------------------------------------------------------------------

        "`nKnown current schema version of products:"
        $SchemaVersions | Format-Table * -AutoSize

        "`nForest functional level:"
        (Get-ADForest).forestmode

        "`nDomain functional level:"
        (Get-ADdomain).domainmode

        Get-ADDomainController -Filter * | Sort-Object site | Format-Table Domain,Name,site,OperationMasterRoles, OperatingSystem, OperatingSystemServicePack -AutoSize -wrap
    }
    End
    {
    }
} # End Function Get-DomainInfo

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Check-Module
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String[]]$ModulesNames
    )
    $return = $FALSE
    Foreach ($ModuleName in $ModulesNames)
    {
        if((Get-Module -Name $ModuleName | Measure-Object).Count -ge 1)
        {
            "$ModuleName is already loaded"
            $Return = $TRUE
        }
        else
        {
            if((Get-Module -Name $ModuleName -ListAvailable | Measure-Object).Count -ge 1)
            {
                Get-Module -Name $ModuleName -ListAvailable | Import-Module
                $return = $TRUE
            }
            else
            {
                #  "Couldn't find $ModuleName, Check if the correct Cmdlet is available"
                   $return = $FALSE
            }
        }
    }#foreach
Return $return
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-DNSName
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String[]]$IPs
    )
    $x = New-Object -TypeName System.Net.IPHostEntry
    Foreach ($IP in $IPs)
    {
        Try
        {
            $x = [System.Net.Dns]::GetHostbyAddress("$IP")
        }
        catch
        {
            $x.AddressList = $IP
            $x.Aliases = {}
            $x.HostName = " - - No Data Found! - - "
        }
      $x
    }#foreach
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-PCInfo
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String[]]$IPs
    )
    $info = @{}
    Foreach ($IP in $IPs)
    {
        $info += Get-WmiObject -Class Win32_operatingsystem | Select-Object csname, Caption, Version, BuildNumber, OSArchitecture, TotalVisibleMemorySize, Description, Organization, SerialNumber
        #$info.OS =
    }

}

# SIG # Begin signature block
# MIIFhQYJKoZIhvcNAQcCoIIFdjCCBXICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkBR6Dz9Z72QVxI3eSc6BQ91Q
# VYqgggMYMIIDFDCCAfygAwIBAgIQWIeL12tDz5hAx8dzrGl52DANBgkqhkiG9w0B
# AQUFADAiMSAwHgYDVQQDDBdQb3dlclNoZWxsIENvZGUgU2lnbmluZzAeFw0xODAz
# MDEwNzUwMTBaFw0yODAzMDIwNzUwMTBaMCIxIDAeBgNVBAMMF1Bvd2VyU2hlbGwg
# Q29kZSBTaWduaW5nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy4VJ
# 5QANvadIT/+pEiy2kVXj7d3sRK4GonHZ0xEf8pFviT9R2QTNanAV9be2AAUCPgTl
# eXyVqPO9ZjqDcA666maPY3mfwTxZEZfnmHPZs701FZpLuzpkZIyPkmWHuFoAe0kA
# /mirUBI518Qhqsnj/z30Mp36GtPq7AYg1zCiNLiiTWodZd+xj05flwkhiXwIgFiN
# OXsWuf9MXfLr1BmynphyMuU5tSxkppGf48nvU0nQeHv/6PLFC1Wo22eEfZ84K14Y
# dbOPI15aVgG/vFnc/nUrElmFZlhkuFAFAQIzX19xPzUXvZg/6pf6J2n6EhcTk3eP
# 4xwCfqTK76lBo2im8wIDAQABo0YwRDATBgNVHSUEDDAKBggrBgEFBQcDAzAOBgNV
# HQ8BAf8EBAMCB4AwHQYDVR0OBBYEFL/+Ccu+wkq7G9pPWnmtPxfHAfU+MA0GCSqG
# SIb3DQEBBQUAA4IBAQDFCyRFa/1/7clOs+xNVSGhjMVedHEFxacsXw8Sw81q9SWF
# PmRi2C0WW9mEfBWlx47B5aZ/jG/gF4F8UKQWImyltPI74MFgF+5tlxB8TWP7wBdZ
# P0x984WoMgEzr3SNzeMRsnpmu7uWu1dtQU0Dbc3XPC01gC+//XHfe3CeaS0LsvP+
# 5JZZ8KcBqrAwdwH1xsWC1oQzo2g3qH6X0Phu4zlzdbEAcO4spyvtxX321juWcAZC
# 3WxfEbea8PdTscOYnR+L0m0+qpoNpXgj0D18XkNCZHC6bvTDdABpZI771wfjRYX4
# mGGJxP2wHCdJy13e5+B7FWK8fUBtxJTdwiQ5ONI0MYIB1zCCAdMCAQEwNjAiMSAw
# HgYDVQQDDBdQb3dlclNoZWxsIENvZGUgU2lnbmluZwIQWIeL12tDz5hAx8dzrGl5
# 2DAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTAjBgkqhkiG9w0BCQQxFgQUXfHgCLIgVqH+Prjs34IfuCe6TFwwDQYJKoZIhvcN
# AQEBBQAEggEAlcy/qJmptIO/i09vryXW/s9hKIgO3I3ifPScD2MY02Ao+F/44G3O
# yqGqEjFqmuR4E6HDmkSY0z7OEQRDtBrEjfxRYkNrQ1DZuwu8FNLzVKUzZtl8V9v9
# gC5SFjJ4ClfERgYCjUanhHzQmxu6jO1zi7MgNq0AFmk1iA/8Vb1/GqUGVZUGJOzU
# VvVlVdLVxqGAko0TMPPYI+RnJ/A6SaHT3Sj30NK9ZabaG/kP91sG1jaqKnOUV4Fs
# WAiKtBPlIs+JXE0dqFs8enUF5TJ7sOfNYhIKMydoyKMJhNHyurV6Jz8A8R+mYooE
# ANNWTizKw6SN4QMHp9g8ZCu5fCCfFlCgew==
# SIG # End signature block
