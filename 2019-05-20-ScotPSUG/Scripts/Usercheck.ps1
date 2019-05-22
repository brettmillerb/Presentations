#Import all users from .csv file - may have to amend location
$duffy = Import-Csv C:\Scripts\Imports\users.csv -Header RParty,username,emailaddress

#Create empty array to later add user details to
$outputarray = @()

#Loop through the users in the list and look them up in AD. Output successful in try or failed lookups in catch.
foreach ($user in $duffy){
    try {
        $person = Get-ADUser $user.username -Properties emailaddress | select samaccountname,enabled,emailaddress -ErrorAction stop
        $properties = [pscustomobject]@{samaccountname = $person.samaccountname
                                       Enabled = $person.enabled
                                       Status = 'Found in AD'
                                       emailaddress = $person.emailaddress
                                    }
    }
    catch {
        $properties = [pscustomobject]@{samaccountname = $user.username
                                        Enabled = $null
                                        Status = 'Not Found in AD'
                                        emailaddress = $null
                                    }
    }
    
    #Add value of properties to the empty array for each user in data.
    $outputarray += $properties
}

#Export the contents of the lookups to .csv file - May have to amend location
$outputarray | Export-Csv C:\Scripts\Exports\userexport3.csv -NoTypeInformation