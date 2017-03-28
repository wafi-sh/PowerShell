
$WhatIfPreference = $false

#$IPs = Get-Content -Path 'H:\Scripts\7\IPs.txt'
#$servers = Get-Content -Path 'H:\Scripts\7\servers.txt'

$Servers = Get-ADComputer -Filter {OperatingSystem -like "*2003*"} -Properties *

$UpServers = @()
$DownServers = @()

foreach ($server in $servers)
{

 $server.Name+"---------> "+ $Server.dnshostname

    if(Test-Connection $server.dnshostName -count 1 -Quiet)
    {
        $UpServers += $Server
    }
    else
    {
        $DownServers += $Server
    }
}


<# Array

$x = @()

foreach ($server in $servers)
{
    $server = $server -replace '\s',''
    $x += Get-ADComputer -Filter {DNShostname -like $server} -Properties Name, OperatingSystem
}

$x

#>



<#
$x = Get-ADUser -Filter {name -like "*"} -Properties name,surname,givenname,samaccountname,department,enabled | where -Property enabled -eq $true

#>


<#

#Set Search
cls
$search = New-Object DirectoryServices.DirectorySearcher([ADSI]“”)
$search.filter = “(servicePrincipalName=*)”
$results = $search.Findall()

 

#list results
foreach($result in $results)
{
       $userEntry = $result.GetDirectoryEntry()
       Write-host "Object Name = " $userEntry.name -backgroundcolor "yellow" -foregroundcolor "black"
       Write-host "DN      =      "  $userEntry.distinguishedName
       Write-host "Object Cat. = "  $userEntry.objectCategory
       Write-host "servicePrincipalNames"
       $i=1
       foreach($SPN in $userEntry.servicePrincipalName)
       {
           Write-host "SPN(" $i ")   =      " $SPN       
           $i+=1
       }
       Write-host ""

} 

#>




<#
Write-Host "Enter Password: "
$pass = read-host -assecurestring 
$username = "Adminwafi"
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $pass 

$FilterList = "localsystem", "NT AUTHORITY\LocalService", "NT AUTHORITY\NetworkService", "NT AUTHORITY\SYSTEM", $null, "NT Service\SQLSERVERAGENT" ,"NT Service\MsDtsServer110", "NT Service\MSSQLFDLauncher", "NT Service\MSSQLSERVER", "NT Service\MSSQLServerOLAPService", "NT Service\ReportServer", "NT Service\SQL Server Distributed Replay Client", ".\administrator", "NT Service\SQL Server Distributed Replay Controller"
$Return = @()

#$servers = "sccm", "durham-phydc", "durham-BLS", "McAfee"

$servers = Get-ADComputer -Filter {OperatingSystem -like "*server*"} -Properties * | where {$_.enabled -eq "True" -and $_.IPv4address -ne $null}

Foreach ($server in $servers)
{
    $result = @()
    $result = gwmi win32_service -computername $server.Name -Credential $cred | where {$_.startname -notin $FilterList}| select SystemName,Name, StartName, State
    "----------$server.name-----------"
    $result
    $Return += $result
}

#$Return

<#

#>
#>




# $vms = get-vm | ? {(Get-Annotation -Entity $_.Name -CustomAttribute 'CreatedBy').Value -in 'Unknown','',$null}



<#
$vms = get-vm 

$events = Get-VMCreationDetails $vms

$events.Count

foreach($event in $events)
{
    $pos = $event.UserName.IndexOf('\')
    
    $user = $event.UserName.Substring($pos+1)
    $date = $event.CreatedTime
    $vm = get-vm -Name $event.VM -EA SilentlyContinue
    if($vm)
    {
      #  Get-Annotation -Entity $vm -CustomAttribute 'createdby'

        If ($vm.CustomFields["CreatedBy"] -eq $null -or $vm.CustomFields["CreatedBy"] -eq "" -or $vm.CustomFields["CreatedBy"] -eq "Unknown")
        {
            set-Annotation -Entity $vm -CustomAttribute 'CreatedBy' -Value $user 
        }
        else
        {
            
        }

        If ($vm.CustomFields["CreatedOn"] -eq $null -or $vm.CustomFields["CreatedOn"] -eq "" -or $vm.CustomFields["CreatedOn"] -eq "Unknown")
        {
            set-Annotation -Entity $vm -CustomAttribute 'CreatedOn' -Value (get-date $event.CreatedTime -Format MM/dd/yyyy) 
        }
        else
        {
            $currentData = Get-Annotation -Entity $vm -CustomAttribute 'createdOn'
            $currentdate = $currentData.Value
            $evm = $event.vm
           "Date Already Exist: -----> $evm -------------> CreatedOn: $date --- Currentdate[ $currentdate ]"

        }

    }# if $vm
    else
    {
        $evm = $event.vm
        "Error: -----> $evm -------------> New-user: $user ------------> New-Date: $date" 
    }
   # Get-ADUser $user -Properties * | select givenname, SurName
   
}

#>

<#

$WhatIfPreference = $true

 
#$VMs = Get-VM | Sort Name

Foreach ($VM in $VMs){
   If ($vm.CustomFields["CreatedBy"] -eq $null -or $vm.CustomFields["CreatedBy"] -eq "")
   {
      Write-Host "Finding creator for $vm"
      $Event = $VM | Get-VIEvent -Types Info | Where { $_.Gettype().Name -eq "VmBeingDeployedEvent" -or $_.Gettype().Name -eq "VmCreatedEvent" -or $_.Gettype().Name -eq "VmRegisteredEvent" -or $_.Gettype().Name -eq "VmClonedEvent"}
      If (($Event | Measure-Object).Count -eq 0){
         $User = "Unknown"
         $Created = "Unknown"
      } Else {
         If ($Event.Username -eq "" -or $Event.Username -eq $null) {
            $User = "Unknown"
         } Else {
            $User = (Get-QADUser -Identity $Event.Username).DisplayName
            if ($User -eq $null -or $User -eq ""){
               $User = $Event.Username
            }
            $Created = $Event.CreatedTime
         }
      }
      Write "Adding info to $($VM.Name)"
      Write-Host -ForegroundColor Yellow "CreatedBy $User"
      $VM | Set-CustomField -Name "CreatedBy" -Value $User | Out-Null
      Write-Host -ForegroundColor Yellow "CreatedOn $Created"
      $VM | Set-CustomField -Name "CreatedOn" -Value $Created | Out-Null
   }
}




$vms =  'test-wafi'
#get-vm | where folder -Like "Development" 

foreach ($vm in $vms)
{
    
    #$newNotes = "11/8/2016 Wafi AlShareef: `r`n" + $vm.Notes
    #Set-VM -VM $vm -Notes $newNotes -Confirm:$false
    
}






#>


<#


#Get-VIServer durham-vci
#Remove-Variable vms
$vms = @()
$VMNames = 'test-wafi'

 foreach($VMName in $VMNames)
            {
                $VM = get-vm $VMName -EA SilentlyContinue
                if($vm -eq $null)
                {Write-Warning "Could not find a virtual machine named: $VMName"}
                else
                {$vms += $vm}
            } #foreach

Get-VIEvent -Entity $VMs -MaxSamples ([int]::MaxValue)|
    where {$_.gettype().name -in 'VmCreatedEvent','VmBeingDeployedEvent','VmRegisteredEvent','VmClonedEvent'} |
    select @{n='VM';E={$_.Vm.name}},@{n='Action';E={$_.gettype().name}},CreatedTime,UserName | 
    sort CreatedTime | 
    ft -auto -Wrap


#>

<#


$vms = get-vm | where folder -Like "GIS Systems" 

foreach ($vm in $vms)
{
    $newNotes = "11/8/2016 Wafi AlShareef: `r`n" + $vm.Notes
    Set-VM -VM $vm -Notes $newNotes -Confirm:$false
}


#>


 <#
 
 
 $vm = Read-Host -Prompt "What is the VM name?"

foreach($DSID in (Get-VM $vm | select DatastoreIdList).datastoreidlist)
{
    Get-Datastore -id $DSID
}
 
 
 
 
 #>