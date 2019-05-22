function Get-O365Licenses {
<#
.SYNOPSIS
    Gets the current O365 license status
.DESCRIPTION
    Connects to O365 tenancy and gets the current license total, used and remaining counts and outputs to console.
.EXAMPLE
    Get-O365Licenses
.EXAMPLE
    Get-O365Licnses | Out-GridView
.OUTPUTS
    Name                         LicensesTotal LicensesUsed LicensesRemaining
    ----                         ------------- ------------ -----------------
    ENTERPRISEPREMIUM                       25            5                20
    POWERAPPS_INDIVIDUAL_USER            10000            2              9998
    YAMMER_ENTERPRISE_STANDALONE             1            0                 1
    ENTERPRISEPACK                          52           41                11
.NOTES
    Must be connected to AzureAD to run this script
    Use the Connect-AzureAD cmdlet to connect
#>
    [CmdletBinding()]
      
    Param (
    )
    
    process {
        $skus = Get-AzureADSubscribedSku

        foreach ($sku in $skus) {
            [PSCustomObject]@{
                Name = $sku.skupartnumber
                LicensesTotal = $sku.prepaidunits.enabled
                LicensesUsed = $sku.consumedunits
                LicensesRemaining = ($sku.prepaidunits.enabled) - ($sku.consumedunits)
            }
        }
            
    }
}

<#
.Synopsis
   Checks who owns the computer object in Active Directory
.DESCRIPTION
   Performs a lookup of the owner in the ACL of the computer object in Active Directory
.EXAMPLE
   Get-ADComputerOwner $Computers
.EXAMPLE
   Get-ADComputerOwner "Computer1", "Computer2"
#>
function Get-ADComputerOwner
{
    [CmdletBinding()]
    Param
    (
        #$computers - Single or array of computers to search
        [Parameter(Mandatory=$false,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$Computers
    )

    Begin {}
    Process{
        foreach ($computer in $computers){
            try {
                $comp = Get-ADComputer $computer -Properties Created -ErrorAction Stop
                $comppath = "AD:$($comp.DistinguishedName.ToString())"
                $owner = (Get-Acl -Path $comppath).Owner
                $properties = @{Computername = $comp.Name
                                Owner = $owner
                                Created = [datetime]$comp.Created
                                Enabled = $comp.enabled}
            } catch {
                $properties = @{Computername = $comp.Name
                                Owner = $null
                                Created = $null
                                Enabled = $null}
            } finally {
                $obj = New-Object -TypeName psobject -Property $properties
                Write-Output $obj
            } #End Finally
        } #End Foreach
    } #End Process
    End{}
} #End Function

<#
.Synopsis
   Checks if computer account exists for computer names provided
.DESCRIPTION
   Checks if computer account exists for computer names provided
.EXAMPLE
   Get-ADExistence $computers
.EXAMPLE
   Get-ADExistence "computer1","computer2"
#>
function Get-ADExistence
{
    [CmdletBinding()]
    Param
    (
        # single or array of machine names
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Enter one or multiple computer names")]
        [String[]]$Computers
     )
    Begin{}
    Process {
        foreach ($computer in $computers) {
            try {
                $comp = get-adcomputer $computer -ErrorAction stop
                $properties = @{computername = $computer
                                Enabled = $comp.enabled
                                InAD = 'Yes'}
            } 
            catch {
                $properties = @{computername = $computer
                                Enabled = 'Fat Chance'
                                InAD = 'No'}
            } 
            finally {
                $obj = New-Object -TypeName psobject -Property $properties
                Write-Output $obj
            }
        } #End foreach

    } #End Process
    End{}
} #End Function

function Get-ADLocalAdminGroup {
<#
.Synopsis
   Get AD Local Admin group for corresponding computer account
.DESCRIPTION
   Local Admin rights are granted via GPP using "OU ac-%computername%-LocalAdmin"
   AD accounts are created in Resource OU in AD and user added to those groups.
.EXAMPLE
   Get-ADLocalAdminGroup L9018210
   Get-ADLocalAdminGroup $machines
.EXAMPLE
   $machines | Get-LocalAdminGroup
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true)]
        [string[]]$Computername
    )

    Process {
        foreach ($computer in $computername) {
            $groupname = "OU ac-{0}-LocalAdmin" -f $computer
            try {
                $group = get-adgroup $groupname -Properties members
                [pscustomobject]@{
                    Computername = $computer
                    Groupname = $group.name
                    GroupExists = 'Yes'
                    Members = if (($group.members).count -lt 1) {
                                'No Members'
                              }
                              else {
                                (Get-ADGroupMember $groupname).samaccountname -join ","
                              }
                }
            }
            catch {
                [pscustomobject]@{
                    Computername = $computer
                    Groupname = $null
                    GroupExists = 'No'
                    Members = 'No Members'
                }
            }
        }
    }
}
function Get-ADUserAzure {
    <#
    .SYNOPSIS
    Gets the AzureAD account from the sAMAccountname of on-premises user
    
    .DESCRIPTION
    Looks up the on-premises sAMAccountname and queries AzureAD using the UPN from the on-premises account.
        
    .PARAMETER username
    sAMAccountname of on-premises user account
    
    .EXAMPLE
    Get-ADUserAzure brett.miller
    
    .NOTES
    Saves having to type out the full UPN of a user to look them up in AzureAD
    #>
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
                try {
                    (Get-aduser -identity $_ -ErrorAction Stop)
                    $true
                }
                catch {
                    throw "User does not exist"
                }
        })] 
        [string[]]$username
    )
    process {
        foreach ($user in $username) {
            get-azureaduser -objectid (get-aduser -Identity $user).userprincipalname
        }
    }
}

<#
.Synopsis
   Checks who owns the user object in Active Directory
.DESCRIPTION
   Performs a lookup of the owner in the ACL of the user object in Active Directory
.EXAMPLE
   Get-ADComputerOwner $Users
.EXAMPLE
   Get-ADComputerOwner "User1", "User2"
#>
function Get-ADUserOwner
{
    [CmdletBinding()]
    Param
    (
        #$Users - Single or array of computers to search
        [Parameter(Mandatory=$false,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$Users
    )

    Begin {}
    Process{
        foreach ($user in $users){
            try {
                $use = Get-ADUser $user -ErrorAction Stop
                $usepath = "AD:$($use.DistinguishedName.ToString())"
                $owner = (Get-Acl -Path $usepath).Owner
                $properties = @{Username = $user
                                Owner = $owner}
            } catch {
                $properties = @{Username = $user
                                Owner = $owner}
            } finally {
                $obj = New-Object -TypeName psobject -Property $properties
                Write-Output $obj
            } #End Finally
        } #End Foreach
    } #End Process
    End{}
} #End Function

function Get-AzureADUserLicenseSummary {
    <#
    .SYNOPSIS
    Gets a summary of users license allocation and enabled plans in readable format.

    .DESCRIPTION
    Enables you to quickly identify O365 license allocated to a user as well as the plans that are enabled as part of their license.

    .PARAMETER ObjectID
    Specifies the ID (as a UPN or ObjectId) of a user in Azure AD.

    .EXAMPLE
    Get-AzureADUserLicenseSummary brett.miller@domain.com

    .EXAMPLE
    $users = 'brett.miller@domain.com','joe.bloggs@domain.com'

    Get-AzureADUserLicenseSummary $users

    .NOTES
    Requires connection to AzureAD
    Use Connect-AzureAD to establish connection
    #>
    
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ObjectID
    )

    process {
        foreach ($user in $ObjectID) {
            try {
                $userobj = Get-AzureADUser -ObjectId $user -ErrorAction stop
                if ($userobj) {
                    $UserLicenses = Get-AzureADUserLicenseDetail -ObjectId $user -ErrorAction stop
                }
                
                [pscustomobject]@{
                    UserPrincipalName = $userobj.UserPrincipalName
                    usagelocation = $userobj.usagelocation
                    Licenses = ($UserLicenses.skupartnumber).replace('STANDARDPACK','ENTERPRISE E1').replace('ENTERPRISEPACK','ENTERPRISE E3').replace('ENTERPRISEPREMIUM','ENTERPRISE E5').replace('SHAREPOINTSTANDARD','SHAREPOINT ONLINE')
                    Plans = ($UserLicenses.serviceplans | Where-Object ProvisioningStatus -EQ Success).serviceplanname
                }
            }
            catch {
                [PSCustomObject]@{
                    UserPrincipalName = $user
                    usagelocation = $null
                    Licenses = $null
                    Plans = $null
                }
            }
        }
    }
}

function Get-CMUserPrimaryDevice {
<#
.SYNOPSIS
Gets a user's primary device from SCCM database

.DESCRIPTION
Connects to SCCM and obtains a users primary device from the SMS database

.PARAMETER identity
This requires sAMAccountName in order to successfully find the user in SMS database.

.EXAMPLE
Get-CMUserPrimaryDevice -Identity Brett.Miller

.EXAMPLE
'Brett.Miller' | Get-CMUserPrimaryDevice

.Example
Get-aduser brett.miller | select -ExpandProperty samaccountname | Get-CMUserPrimaryDevice
#>
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$identity

    )
    process {
        foreach ($person in $identity) {
            $userobj = Get-CMUserDeviceAffinity -UserName ("fqdn\{0}" -f $person)
            if ($userobj){
                [PSCustomObject]@{
                    sAMAccountName = ($userobj.uniqueusername | Select-Object -First 1).substring(5)
                    ComputerName = $userobj | Select-Object -ExpandProperty resourcename
                } 
            }
            else {
                [PSCustomObject]@{
                    sAMAccountName = $person
                    ComputerName = $null
                }
            }
        }
    }
}

function Get-FSMORoleLocation {
    $ADDomain = Get-ADDomain | Select-Object pdcemulator,ridmaster,infrastructuremaster
    $ADForest = Get-ADForest fqdn.domain.com | Select-Object domainnamingmaster,schemamaster

    [PSCustomObject]@{
        PDCEmulator = $ADDomain.pdcemulator
        RIDMaster = $ADDomain.ridmaster
        InfrastructureMaster = $ADDomain.infrastructuremaster
        DomainNamingMaster = $ADForest.domainnamingmaster
        SchemaMaster = $ADForest.schemamaster        
    }
}
<#
.Synopsis
   Get List of Ransomware filetypes from Public API
.DESCRIPTION
   Function to public API https://fsrm.experiant.ca/ to call data
   for use in FileSystem Resource Manager (FSRM) groups.
.EXAMPLE
   Get-FSRM (No Parementers required)
#>

function Get-FSRM
{
    Process {
        $webClient = New-Object System.Net.WebClient

        #Download JSON from API
        $jsonStr = $webClient.DownloadString("https://fsrm.experiant.ca/api/v1/combined")

        #Convert JSON to Custom Object
        $Raw = ConvertFrom-Json $jsonStr #Contains api

        #Add each file extension to an array for output
        $monitoredextensions = @(ConvertFrom-Json($jsonStr) | ForEach-Object { $_.filters })

        #Create custom object containing info from API
        $properties = @{DateExtracted = ((Get-Date).ToShortDateString())
                        GroupCount = $raw.api.file_group_count
                        LastUpdated = $raw.lastUpdated.date
                        Extensions = $monitoredextensions}

        $obj = New-Object -TypeName psobject -Property $properties
        Write-Output $obj
    }
}

function Get-O365Licenses {
<#
.SYNOPSIS
    Gets the current O365 license status
.DESCRIPTION
    Connects to O365 tenancy and gets the current license total, used and remaining counts and outputs to console.
.EXAMPLE
    Get-O365Licenses
.EXAMPLE
    Get-O365Licnses | Out-GridView
.OUTPUTS
    Name                         LicensesTotal LicensesUsed LicensesRemaining
    ----                         ------------- ------------ -----------------
    ENTERPRISEPREMIUM                       25            5                20
    POWERAPPS_INDIVIDUAL_USER            10000            2              9998
    YAMMER_ENTERPRISE_STANDALONE             1            0                 1
    ENTERPRISEPACK                          52           41                11
.NOTES
    Must be connected to AzureAD to run this script
    Use the Connect-AzureAD cmdlet to connect
#>
    [CmdletBinding()]
      
    Param (
    )
    
    process {
        $skus = Get-AzureADSubscribedSku

        foreach ($sku in $skus) {
            [PSCustomObject]@{
                Name = $sku.skupartnumber
                LicensesTotal = $sku.prepaidunits.enabled
                LicensesUsed = $sku.consumedunits
                LicensesRemaining = ($sku.prepaidunits.enabled) - ($sku.consumedunits)
            }
        }
            
    }
}
