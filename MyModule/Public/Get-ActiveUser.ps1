function Get-ActiveUser {
    <#
    .SYNOPSIS
    Checks if user account is enabled in AD
    
    .DESCRIPTION
    Checks if user account is enabled in AD and returns status and email address

    .PARAMETER user
    User or list of users to check against AD

    .EXAMPLE
    Get-ActiveUser -User 'brett.miller'
    
    .EXAMPLE
    Get-ActiveUser -User 'brett.miller', 'jeff.jefferson'
    #>
    param (
        [Parameter(Mandatory)]
        [string[]]
        $User
    )

    #Loop through the users in the list and look them up in AD. Output successful in try or failed lookups in catch.
    foreach ($subUser in $user) {
        try {
            Get-ADUser $subUser -Properties emailaddress -ErrorAction Stop |
            Select-Object -Property @(
                'samaccountname'
                'enabled'
                @{name = 'Status'; expression = { 'Found in AD' } }
                'emailaddress'
            )
        }
        catch {
            [pscustomobject]@{
                samaccountname = $subUser.username
                Enabled        = $null
                Status         = 'Not Found in AD'
                emailaddress   = $null
            }
        }
    }
}