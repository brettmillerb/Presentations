#Import all users from .csv file - may have to amend location
$users = Import-Csv C:\Scripts\Imports\users.csv -Header username, emailaddress

#Declare Function
Import-Module MyAwesomeModule

$output = Get-ActiveUser -User $users
#Export the contents of the lookups to .csv file - May have to amend location
$output | Export-Csv C:\Scripts\Exports\users-export.csv -NoTypeInformation