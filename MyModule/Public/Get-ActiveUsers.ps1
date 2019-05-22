function Get-ActiveUsers {
    <#
    .SYNOPSIS
    Short description
    
    .DESCRIPTION
    Long description
    
    .PARAMETER File
    Parameter description
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>
    param (
        [string]
        $File
    )

    #Import all users from .csv file - may have to amend location
    $duffy = Import-Csv -Path $file -Header RParty,username,emailaddress

    #Loop through the users in the list and look them up in AD. Output successful in try or failed lookups in catch.
    foreach ($user in $duffy){
        try {
            $person = Get-ADUser $user.username -Properties emailaddress |
                Select-Object samaccountname,enabled,emailaddress -ErrorAction stop

            [pscustomobject]@{
                samaccountname = $person.samaccountname
                Enabled = $person.enabled
                Status = 'Found in AD'
                emailaddress = $person.emailaddress
            }
        }
        catch {
            [pscustomobject]@{
                samaccountname = $user.username
                Enabled = $null
                Status = 'Not Found in AD'
                emailaddress = $null
            }
        }
    }
}