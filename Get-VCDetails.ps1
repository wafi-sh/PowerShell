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
function Get-VCDetails
{
<#
The fucntion will:
1: Check connectivity to VC
2: Get general info about the VC datacenters, hosts and VMs
#>
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # vCenter Server
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$True,
                   Position=0)]
        [Alias('Server','VC','vCenter')]
        [String]$VC
    )
    Begin    {    }
    Process
    {
        check-module ("VMware.VimAutomation.Core")
        if(Check-VIServerConnection($VC)) 
        {
            $vms = Get-VM
            $hosts = Get-VMHost
            $dc = Get-Datacenter
            $ConnectedHosts = $hosts | ? connectionstate -EQ "Connected" 
            $PoweredOnHosts =  $hosts | ? powerstate -EQ "PoweredOn"
            $totalVMs = ($vms |measure | select count).count
            $PoweredOnVMs = $vms | ? powerstate -EQ "PoweredOn"
            $PoweredOffVMs = $vms | ? powerstate -EQ "PoweredOff"

            $UnknownVMs = $totalVMs - ($PoweredOnVMs.Count + $PoweredOffVMs.Count)
            "`r`nTotal Datacenters: "+ ($dc |measure | select count).count
            "Total Hosts: "+ ($Hosts |measure | select count).count + " (Connected: "+$ConnectedHosts.Count+", Powered On: "+$PoweredOnHosts.Count+")"
            "Total VMs: "+ $totalVMs +" (Powered On: "+$PoweredOnVMs.Count+", Powered Off: "+$PoweredOffVMs.count+", Unknown: " + $UnknownVMs +")"
        } #if Check-VIServerConnection
        else
        {
            "No Connection to vCenter Server!"
        } # else Check-VIServerConnection
    }#Process
}#Function