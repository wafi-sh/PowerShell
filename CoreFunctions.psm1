
<#
.Synopsis
   Get general information about the current domain.
.DESCRIPTION
    Get list of domain controllers on the current domain along with the FSMO roles for each one.
#>
function Get-DomainInfo
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        
    )

    Begin
    {
    }
    Process
    {
        Get-ADDomainController -Filter * | sort site | ft Domain,Name,site,OperationMasterRoles -AutoSize
    }
    End
    {
    }
}


<#
.Synopsis
   Get when is a VM created.
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet

#>
function Get-VMCreationTime
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Virtual Machine Name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $VM
    )

    Begin
    {
    }
    Process
    {
        Get-VIEvent -Entity $VM |
            where {$_.gettype().name -like '*created*'} |
            select {$_.gettype().name},CreatedTime,UserName | 
            sort CreatedTime | 
            ft -auto
    }
    End
    {
    }
}

#Get-ADUser -Filter 'Name -like "*Wafi*"' -SearchBase "ou=DURHAM CITY GOV,dc=durham,dc=local"  -Properties *




<#










#>