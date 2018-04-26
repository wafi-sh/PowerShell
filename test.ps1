<#

$CDP = "165.237.227.60"; $NCE = "165.237.226.60"; $LAB = "10.64.132.60"; $NCW = "24.28.197.60"
$cred = Get-Credential
Get-Module -ListAvailable *vm* | Import-Module
Connect-VIServer $ncw -Credential $cred



# $x.runninginstance | select @{N="Name";E={($_.tag | ? key -Like "Name").value}}, instanceID, Platform, @{N="Power Status";E={$_.state.name}} | sort "power status" -Descending
$z = @("i-0b69c63bad778ae8f","i-0c302e26dd1a99891")

$z | Start-EC2Instance
#>



<#
### Search VM By IP4 Address
$ip = "127.0.0.2"
$vms = Get-VM

$result = foreach ($vm in $vms)
{
    $IPs = $vm.Guest.IPAddress
    if ($ips -match $ip) {$vm} 
}
#>



<#
foreach ($switch in $switchs0)
{
 New-VirtualPortGroup -Name "X-Stage-CM-Dup" -VLanId "2002" -VirtualSwitch $switch
}
#>

<#

foreach ($switch in $switchs)
{
    $portGroups = Get-VirtualPortGroup -VirtualSwitch $switch
    foreach ($portgroup in $portGroups)
    {
        $policy = $portgroup | Get-NicTeamingPolicy
        #$switch.VMHost.Name + " :: " + $switch.Name +" :: "+ $portgroup.name +" --> "+$policy.NetworkFailoverDetectionPolicy +" - "+$policy.LoadBalancingPolicy + " - "+ $policy.NotifySwitches +" - "+ $policy.FailbackEnabled
        $policy | Set-NicTeamingPolicy -LoadBalancingPolicy LoadBalanceSrcId -NetworkFailoverDetectionPolicy LinkStatus -NotifySwitches $true -FailbackEnabled $true -InheritFailoverOrder $false
    }
    #$policy = $switch | Get-NicTeamingPolicy
    #$switch.VMHost.Name + " :: " + $switch.Name +" :: "+ $portgroup.name +" --> "+$policy.NetworkFailoverDetectionPolicy +" - "+$policy.LoadBalancingPolicy + " - "+ $policy.NotifySwitches +" - "+ $policy.FailbackEnabled
    #$policy | Set-NicTeamingPolicy -LoadBalancingPolicy LoadBalanceSrcId -NetworkFailoverDetectionPolicy LinkStatus -NotifySwitches $true -FailbackEnabled $true
}

#>



# X-Stage-CM-Dup --> vlan 2002

<#
### Create portgroup for each host and set policies for it.

foreach ($h in $hosts)
{
    $switch = Get-VirtualSwitch -VMHost $h -Name "*0"
    $portgroup = New-VirtualPortGroup -Name "TPZ" -VirtualSwitch $switch -VLanId "60" 
   # $policy = $portgroup | Get-NicTeamingPolicy
    #$policy | Set-NicTeamingPolicy -LoadBalancingPolicy LoadBalanceSrcId -NetworkFailoverDetectionPolicy LinkStatus -NotifySwitches $true -FailbackEnabled $true
  #  $h.name + " --> " + $switch.Name
    $switch = ""
    $portgroup = ""
}

#>


<#
$switchs = Get-VirtualSwitch
#$portgroups = Get-VirtualPortGroup
$result = @{}
#$result["Switch"] = @{}
$i = 0
$result = foreach ($switch in $switchs)
{
     $switch | Get-VirtualPortGroup | select @{N="Host"; E={@($switch.VMHost)}}, @{N="Switch"; E={@($switch)}}, @{N="PortGroup"; E={@($_.name)}}, VlanID
}
#>


<#

### import CSV into variable 
### prepare the static OVA configuration (same config for all VMs)
### get the targeted datastore and the targeted cluster, I coudn't import ova without specifing specific host, so I choos host for each OVA randomly


$path = 'C:\Users\V797172\Desktop\AES Build Info.csv'
$file = Import-Csv -Path $path

$ovaconfig = Get-OvfConfiguration -Ovf 'C:\Users\V797172\Desktop\AES-7.1.2.0.0.3.20171110-e55-00.ova'
$ovaconfig.DeploymentOption.Value = "aesFootprint-profile3"
$ovaconfig.NetworkMapping.Public.Value = "X-Stage-Net"
$ovaconfig.NetworkMapping.Private.Value = "X-Stage-Net"
$ovaconfig.NetworkMapping.Out_of_Band_Management.Value = "X-Stage-Net"
$ovaconfig.Common.EASG_enable.Value = 2
$ovaconfig.Common.ntpservers.Value = "165.237.86.17"
$ovaconfig.Common.vamitimezone.Value = "Etc/UTC"
$ovaconfig.Common.srchdomains.Value = "twcable.com"
$ovaconfig.vami.Application_Enablement_Services.DNS.Value = "165.237.86.86,165.237.54.54"
$ovaconfig.IpAssignment.IpProtocol.Value="IPv4"

$ds = Get-Datastore "Application1"
$c = Get-Cluster

foreach ($item in $file)
{
    $ovaconfig.Common.vami.hostname.Value = $item.Hostname
    $ovaconfig.vami.Application_Enablement_Services.gateway.Value = $item.'Default Gateway'
    $ovaconfig.vami.Application_Enablement_Services.ip0.Value= $item.'Public IP Address'
    $ovaconfig.vami.Application_Enablement_Services.netmask0.Value= $item.'Public Netmask'
    $vmhost = Get-VMHost | Get-Random
    $vmhost.Name
    #$item.'VM Name'
   
    Import-VApp -Source .\AES-7.1.2.0.0.3.20171110-e55-00.ova -OvfConfiguration $ovaconfig -Name $item.'VM Name' -Datastore $ds -DiskStorageFormat Thick -VMHost $vmhost -Location $c -RunAsync
}

#>



<#

### enable vCPUHotAdd 
### then run it again for memoryHotAdd

$vms = Get-Folder "scriptdeployed" | Get-VM | Get-View

$vmConfig = new-object VMware.Vim.VirtualMachineConfigSpec
$extra = new-object VMware.Vim.OptionValue
$extra.key = "vcpu.hotadd"

#$extra.key = "mem.hotadd"

$extra.Value = "True"

$vmconfig.ExtraConfig += $extra

foreach ($vmview in $vms)
{
    $vmview.ReconfigVM($vmconfig)
    
}//foreach

#>

<#
### remove all reservation on vCPU and Memory

$vms = Get-Folder "scriptdeployed" | Get-VM

foreach ($vm in $vms)
{
    $vm | Get-VMResourceConfiguration | Set-VMResourceConfiguration -MemReservationMB 0 -CpuReservationMhz 0
    
}



#>











# $vms = Get-VM
 #$vms | select name, vmhost, @{N="IP Address";E={@($_.guest.IPAddress -join "`r`n")}} | Export-Csv -NoTypeInformation CPod-NCE-Lab-IPAddress.csv
 <#
 #>
 #$vc = Connect-VIServer -Server 165.237.227.60 -Credential $myaccount

<# $list = $vms | select name, PowerState,@{N="VMTools";E={$_.ExtensionData.Guest.ToolsStatus}}, @{N="DNS Name";E={$_.ExtensionData.guest.hostname}}, @{N="OS";E={$_.guest.OSFullName}}, @{N="IPs";E={$_.guest.IPAddress}} 
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


#>

<#
$machines = "agntpapp02cdp","cdpbciqapp01", "cdpbciqdb01", "agntpapp03cdp", "essadmcorpreg", "cmadmpacreg"

foreach ($machine in $machines)
{
    $Computer ="";
    $Computer = Get-ADComputer -Filter {name -like $machine} -Properties *
    if ($Computer)
    {
       try 
       { 
            $ErrorActionPreference = "Stop";
            $details = gwmi -ComputerName $computer.DNSHostName win32_computersystem
            if($?){$manufacturer = $details.manufacturer}
            else{throw $error[0].exception}
       }
       catch
       {
            $manufacturer = "RPC is not accessable due to: none-Windows OS, firewall, permission, or RPC is not running"
       }
       $machine + " --> " + $manufacturer
    }
    else 
    {
        $machine + " Dosn't exist!"
    }

}
#>

<#

$vlans = @("165.237.160.0/24", "165.237.34.0/24", "165.237.161.0/24", "165.237.35.0/25", "165.237.152.0/24", "165.237.163.128/25", "165.237.103.128/25", "165.237.163.0/26", "165.237.103.0/26", "165.237.27.128/25", "165.237.227.0/24")
foreach ($vlan in $vlans)
{
    $SubnetID, $MaskBits = $vlan.split("/")
    $i= [int]$SubnetID.Substring($SubnetID.LastIndexOf('.')+1)+1
    switch ($MaskBits)
    {
        24 {$end = [int]254}
        25 {$end = [int]126}
        26 {$end = [int]62}
    }
    $part1 = $SubnetID.Substring(0,$SubnetID.LastIndexOf('.')+1)
    
}


$vlan10ip = "165.237.160."
$i=1
$ip=""

while($i -le $i+$end)
    {
        $ip = $vlan10ip + $i
        $vlan10 += $ip
        $i++
    }
#>

<#
$vmswip = @()
$vmswoip = @()
foreach ($vm in $vms)
{
    $ips = $vm.Guest.IPAddress
    if($ips.count -gt 0)
    {
        $vmswip += $vm
    }
    else
    {
        $vmswoip +=$vm
    }
    #$vm.Name + " --> " + $vm.Guest.IPAddress
}
#>