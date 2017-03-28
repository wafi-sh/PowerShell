
$WhatIfPreference = $false
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
