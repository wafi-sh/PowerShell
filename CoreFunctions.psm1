<#
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
}


<#
.Synopsis
   Get when is a VM created and who created it.
.EXAMPLE
   Get-VMCreationDetails 'Vserver1'
   Get the creation detials for Vserver1
.EXAMPLE
   Get-VMCreationDetails 'Vserver1','Vserver2'
   Get the creation detials for Vserver1 and Vserver2
.EXAMPLE
   $vm = get-vm 'Vserver1'
   Get-VMCreationDetails $vm
   Get the creation detials for Vserver1
#>
function Get-VMCreationDetails
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Virtual Machines names
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$True,
                   Position=0)]
        [Alias('VirtualMachine','VM','Name')]
        [String[]]$VMnames
    )
    Begin
    {
    }
    Process
    {
        if(Check-Module 'vmware.vimautomation.core')
        {
            if(Check-VIServerConnection 'durham-vci')
                {
                    # Prepare $VMs array to add virtual machines to it
                   $VMs = @()
                    # Fetch all VM and store them in $VMs array
                   foreach($VMName in $VMNames)
                   {
                        $VM = get-vm $VMName -EA SilentlyContinue
                        if($vm -eq $null)
                        {Write-Warning "Could not find a virtual machine named: $VMName"}
                        else
                        {$VMs += $vm}
                   } #foreach
                   if($vms.Length -gt 0)
                   {
                    # Get vCenter Events for virtual machines in $VMs and filter on create, deploy, register, or clone event
                      Get-VIEvent -Entity $VMs -MaxSamples ([int]::MaxValue)|
                      Where-Object {$_.gettype().name -in 'VmCreatedEvent','VmBeingDeployedEvent','VmRegisteredEvent','VmClonedEvent','VmDiscoveredEvent'}  |
                      Select-Object @{n='VM';E={$_.Vm.name}},@{n='Action';E={$_.gettype().name}},CreatedTime,UserName | 
                      Sort-Object CreatedTime 
                   } #if $VMs.Length
                   else
                   {
                    Write-Warning "No VMs to get details of!"
                   } #else $VMs.Length
                } #if Check-VIServerConnection
                else
                {
                    "No connection to vCenter Server"
                } #else Check-VIServerConnection
        } #if check-module
        else
        {
            "VMware.VIMautomation.core module is not available!"
        } #else check-module
    } #Process
    End
    {
    }
}


<#

#>
Function Check-VIServerConnection
{
    [CmdletBinding()]
    Param
    (
        # vCenter Server name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Server
    )

    if($global:DefaultVIServers.Count -gt 0)
    {
        #"Connected to $global:DefaultVIServers"
        $TRUE
    }
    else
    {
        if(Connect-VIServer -server $Server) {$TRUE} else {$FALSE}    
    }
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





