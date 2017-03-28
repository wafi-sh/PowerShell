Write-Host "Enter Password: "
$pass = read-host -assecurestring 
$username = "Adminwafi"
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $pass 


$IPs = Get-Content -Path 'C:\Users\wafial\Desktop\CoD\Work Files\COD\Scripts\8\PHPips.txt'
#$ips = 'durham-vgisapps'
$goodIPs = @()
$badIPs = @()
Foreach ($ip in $ips)
{
    $ip
    if(Test-Connection $ip -Count 1 -Quiet)
    {
        gwmi win32_service -ComputerName $ip -Credential $cred  | ? name -like *apach* |select Name, Startmode, State, @{n='Server'; e={$ip}} | sort name
        $goodIPs += $ip
    }
    else
    {
        "$ip ---- Not Accessable"
        $badIPs += $ip
    }
 
}