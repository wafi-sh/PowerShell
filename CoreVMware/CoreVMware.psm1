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
    Begin    {    }
    Process
    {
        if(Check-Module 'vmware.vimautomation.core')
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
               
        } #if check-module
        else
        {
            "VMware.VIMautomation.core module is not available!"
        } #else check-module
    } #Process
    End    {    }
} # End Function Get-VMCreationDetails

<#
.Synopsis
   Get VM Folder Path.
.EXAMPLE
  Get-VMPath -VMnames "vm1, vm2"
  Get the folder path for vm1 and vm2
.EXAMPLE
   Get-VMPath $vms
   Get the folder path for any vm in $vms
#>
function Get-VMPath
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
    Begin    {    }
    Process
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
         foreach ($vm in $VMs)
         {
           $currentFolder = $vm.Folder
           $path = ""
           while ($currentFolder.Name -ne "vm")
           {
               $parentFolder = Get-Folder $currentFolder | select folder
               $Path=$CurrentFolder.name + "\" + $Path
               $currentFolder = $currentFolder.Parent
               if ($CurrentFolder.count -gt 0 )  {$currentFolder= $CurrentFolder[0]}
           }
           $Path
         }
       } #if $VMs.Length
       else
       {
        Write-Warning "No VMs to get details of!"
       } #else $VMs.Length
    } #Process
    End    {    }
} # End Function Get-VMPath

<#
.Synopsis
   Get VM by IP Address.
.EXAMPLE
  Get-VMByIP -IP "10.64.133.82"
#>
function Get-VMByIP
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # IP Address
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$True,
                   Position=0)]
        [String[]]$IP
    )
    Begin    {    }
    Process
    {
      $vms = Get-VM
      foreach ($vm in $vms)
      {
          $IPs = $vm.Guest.IPAddress
          if ($ips -match $ip) {$vm}
      }
    } #Process
    End    {    }
} # End Function Get-VMByIP

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
        $Server,
        [Parameter(Mandatory=$FALSE)]
        [Alias('Credential')]
        $cred
    )
    check-module ("VMware.VimAutomation.Core")
    if($global:DefaultVIServers.Count -gt 0)
    {
        "Already connected to: " + $global:DefaultVIServer
        #$TRUE
    }
    else
    {
      if(!$cred){ $cred = get-Credential}
      if(Connect-VIServer -server $Server -Credential $credk)
      {
        "Connected successfully to: "+ $global:DefaultVIServer
      }
      else
      {
        "Connection failed! not able to connect to: " + $Server; $FALSE
      }
    }
} # End Function Check-VIServerConnction

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
2: Get general info about the VC Datacenter, hosts and VMs
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
        [Alias('Server')]
        [String]$vCenter

    )
    Begin    {    }
    Process
    {
        import-module -Name "VMware.VimAutomation.Core"
        if(Check-VIServerConnection($vCenter))
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
}# End Function Get-VCDetails
