function Add-ADSyncUsers {
    <#
    .SYNOPSIS
    Add users to the Active Directory Group for AzureADConnect

    .DESCRIPTION
    Add users to the Active Directory Group for AzureADConnect

    .PARAMETER Users
    List of users to be added to the AzureADConnect group

    .PARAMETER InputObject
    PSObject for pipeline support

    .EXAMPLE
    Add-ADSyncUsers -Users 'brett.miller','jeff goldblum'

    .EXAMPLE
    $csv = Import-CSV -Path C:\temp\users.csv
    $csv | Add-ADSyncUsers
    #>

    [CmdletBinding(SupportsShouldProcess,
        DefaultParameterSetname = 'Default',
        ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory,
            ParameterSetName = 'Default')]
        [string[]]$Users,

        [Parameter(Mandatory,
            ParameterSetName = 'Pipeline',
            ValueFromPipeline)]
        [psobject]$InputObject
    )
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Default') {
            foreach ($user in $users) {

                Write-Verbose $user

                #Adds users/Groups
                if ($PSCmdlet.ShouldProcess("AzureADConnectSyncUsers", "Adding $user to Group")) {
                    Add-ADGroupMember -Identity "AzureADConnectSyncUsers" -Members $user
                }
            }
        }
        else {
            Write-Verbose $_.SamAccountName

            if ($PSCmdlet.ShouldProcess("AzureADConnectSyncUsers", "Adding $($_.samaccountname) to Group")) {
                Add-ADGroupMember -Identity "AzureADConnectSyncUsers" -Members $_.samaccountname
            }
        }
    }
}
function Remove-ADSyncUsers {
    <#
    .SYNOPSIS
    Remove users from the Active Directory Group for AzureADConnect

    .DESCRIPTION
    Remove users from the Active Directory Group for AzureADConnect

    .PARAMETER Users
    List of users to be removed from the AzureADConnect group

    .PARAMETER InputObject
    PSObject for pipeline support
    
    .EXAMPLE
    Remove-ADSyncUsers -Users 'brett.miller','jeff goldblum'

    .EXAMPLE
    $csv = Import-CSV -Path C:\temp\users.csv
    $csv | Remove-ADSyncUsers
    
    .NOTES
    General notes
    #>
    
    [CmdletBinding(SupportsShouldProcess,
        DefaultParameterSetname = 'Default',
        ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory,
            ParameterSetName = 'Default')]
        [string[]]$Users,

        [Parameter(Mandatory,
            ParameterSetName = 'Pipeline',
            ValueFromPipeline)]
        [psobject]$InputObject
    )
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Default') {
            foreach ($user in $users) {

                Write-Verbose $user.SamAccountName

                #Adds users/Groups
                if ($PSCmdlet.ShouldProcess("AzureADConnectSyncUsers", "Removing $user from Group")) {
                    Remove-ADGroupMember -Identity "AzureADConnectSyncUsers" -Members $user.samaccountname
                }
            }
        }
        else {
            Write-Verbose $_.SamAccountName

            if ($PSCmdlet.ShouldProcess("AzureADConnectSyncUsers", "Removing $($_.samaccountname) from Group")) {
                Remove-ADGroupMember -Identity "AzureADConnectSyncUsers" -Members $_.samaccountname
            }
        }
    }
}