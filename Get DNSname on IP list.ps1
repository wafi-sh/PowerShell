$IPs = Get-Content -Path 'C:\Users\wafial\Desktop\CoD\Work Files\COD\Scripts\7\SQLips.txt'
Get-DNSName $IPs

<#
$Result = @{}

$i=0
foreach ($IP in $IPs)
{
$i++
$Result[$i] = @{}
$Result[$i]['IP'] = $IP
$Result[$i]['Name'] = "name $i"
#[System.Net.Dns]::GetHostbyAddress($IP)
}

#>