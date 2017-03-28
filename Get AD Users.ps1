$path =""
$Users=""

ForEach ($Path in $(Get-ChildItem 'H:\Scripts\Get AD Users\Computers lists'))
{
    $Users = ForEach ($User in $(Get-Content $Path.FullName)) 
    {
  #  $user
        try
        {
            Get-AdUser $user -Properties * | select samaccountname,GivenName,surname,Department,Office,telephoneNumber
        }
        catch
        {
            Get-AdUser $user -Properties * -Server 'ossi.durham.local' | select samaccountname,GivenName,surname,Department,Office,telephoneNumber 
        }
    }
    #$Users
    
    "_______________________________________________________________________________"
    $Path.Name.Substring(0,$Path.Name.Length-4)
   
    $Users  | Export-Csv ('H:\Scripts\Get AD Users\Active users on old print servers\' + $Path.Name.Substring(0,$Path.Name.Length-4) +'.cvs') -Encoding ascii -NoTypeInformation
 
    "_______________________________________________________________________________"
    $Users = ''
}

#| Format-Table samaccountname,GivenName,surname,Department,Office,telephoneNumber -wrap -auto #





#$domains = "durham.local","ossi.durham.local"

#$Path = 'H:\Scripts\Get AD Users\Computers lists\durham-vprtc.txt'







# | ft SamAccountName,GivenName,surname,Department,Office,StreetAddress,telephoneNumber,CanonicalName -wrap -AutoSize

   # $AllUsers | ft GivenName,surname,Department,Office,StreetAddress,telephoneNumber -Wrap -AutoSize | Out-File 'H:\Scripts\Get AD Users\AllUsers1.test'

#Get-ADUser -Filter {name -Like '*wafi*'} -Properties * | Get-Member
#Get-ADUser -Filter $Filter -Properties GivenName,surname,Department,Office,StreetAddress,telephoneNumber | Format-Table GivenName,surname,Department,Office,StreetAddress,telephoneNumber -Wrap -AutoSize
#Get-ADUser -Filter {name -Like '*wafi*'} -Properties *

#{SamAccountName -Like "BarbaraBu" -or SamAccountName -Like "BoDo"}

#if (dsquery user -samid $user){"Found user"}

#else {"Did not find user"}