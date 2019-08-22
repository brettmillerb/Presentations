$users = import-csv "C:\users\brett\Documents\temp.csv"

foreach ( $user in $users) {

    Write-Host $user.SamAccountName

    #Adds users/Groups
    Add-ADGroupMember -Identity "AzureADConnectSyncUsers" -Members $user.samaccountname

    #Remove users/Groups
    #remove-ADGroupMember -Identity "AzureADConnectSyncUsers" -Members $user.SamAccountName -Confirm:$false

} 
