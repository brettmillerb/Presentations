param (
    [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
    [System.IO.FileInfo]
    $File
)

#Import all users from .csv file - may have to amend location
$users = Import-Csv $File -Header username, emailaddress

#Create empty arrayList to later add user details to
$outputarray = [System.Collections.ArrayList]::new()

#Loop through the users in the list and look them up in AD. Output successful in try or failed lookups in catch.
foreach ($user in $users) {
    try {
        $person = Get-ADUser $user.username -Properties emailaddress |
            Select-Object samaccountname, enabled, emailaddress -ErrorAction stop
        
            $properties = [pscustomobject]@{
                samaccountname = $person.samaccountname
                Enabled        = $person.enabled
                Status         = 'Found in AD'
                emailaddress   = $person.emailaddress
        }
    }
    catch {
        $properties = [pscustomobject]@{
            samaccountname = $user.username
            Enabled        = $null
            Status         = 'Not Found in AD'
            emailaddress   = $null
        }
    }
    
    #Add value of properties to the empty array for each user in data.
    $outputarray.Add($properties) | Out-Null
}

#Export the contents of the lookups to .csv file - May have to amend location
$outputarray | Export-Csv C:\Scripts\Exports\users-export.csv -NoTypeInformation