cls
$x = "wafi"
Get-ADComputer -Filter { description -Like '*$x*'} -Properties name #| Format-Table Name,OperatingSystem, -Wrap -Autosize
#-or Name -Like 'durham-phydc' -or Name -Like 'dcnps2' -or Name -Like 'vdndc'
#Get-ADDomainController  | Format-Table Name,OperatingSystem -Wrap -AutoSize
#Get-ADForest
# Get-ADGroupMember 'Domain Controllers' 
#$x =Get-ADComputer -Filter { Name -Like 'vex*'} 
#$x | Get-Member

# Get-ADComputer -Filter { Name -Like 'durham-vprtx'} -Properties * | Get-Member