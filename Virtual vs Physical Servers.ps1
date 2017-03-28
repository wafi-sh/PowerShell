$Servers = get-adcomputer -filter {operatingsystem -like "*windows*server*"} -Properties Name,OperatingSystem,IPv4Address | sort name #| select-object name | export-csv .\scripts\3\computers.txt -notypeinformation -encoding UTF8
# ) -and (name -like "Durham-ob*")


Foreach($Server in $Servers)
{
 $server.Name+"---------> "+ $Server.dnshostname

    if(Test-Connection $server.dnshostName -count 1 -Quiet)
    {
    "--->UP"
    "--->Getting System Info..."
      $HT.Manufacturer = "Unknown!";
      $HT = gwmi -ComputerName $Server.dnshostName win32_computersystem;
      $HT.manufacturer;
      $Server | Add-Member -type NoteProperty -Name HardwareType -Value $HT.manufacturer -Force  
    }
    Else
    {
        $Server | Add-Member -type NoteProperty -Name HardwareType -Value "Server is Down!!!" -Force
        "Down"
    }
"-----------------------------------"

}  <# #>

# $DownServers | out-file -FilePath .\scripts\3\DownServers.txt -append
$Servers | select Name,HardwareType,OperatingSystem,IPv4Address | Export-Csv -Path '.\scripts\3\Servers.csv' -Encoding ascii -NoTypeInformation   

