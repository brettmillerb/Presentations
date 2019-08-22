# Some basic design practices for PowerShell

#region Don't use aliases in scripts - EVER!!!

    # Da hell does that mean 😕
    gps | ? name -like p*w* | % na*

    #Instead
    Get-Process |
        Where-Object name -like p*w* |
            Foreach-Object -MemberName Name
#endregion

#region Death to Backticks
    # This is a really long line
    Send-MailMessage -To 'brett@millerb.co.uk' -From 'info@millerb.co.uk' -Subject 'My Super Important Message' -SmtpServer 'mymailserver@millerb.co.uk' -Body 'Hi there'
    
    # So you might be inclined to do
    Send-MailMessage `
    -To 'brett@millerb.co.uk' `
    -From 'info@millerb.co.uk' `
    -Subject 'My Super Important Message' `
    -SmtpServer 'mymailserver@millerb.co.uk' `
    -Body 'Hi there'
    
    # Don't.....I'll send ninjas to kill you in your sleep
    
    # Instead use Splatting
    $sendMailMessageSplat = @{
        To         = 'brett@millerb.co.uk'
        From       = 'info@millerb.co.uk'
        Subject    = 'My Super Important Message'
        SmtpServer = 'mymailserver@millerb.co.uk'
        Body       = 'Hi there'
    }

    Send-MailMessage @sendMailMessageSplat

#endregion Death to Backticks

#region Array Construction
    # Don't do this, it's slow and rebuilds the array in memory every time it adds something
    $array = @()
    $array += 'Adding stuff to the array'
    $array += 'Adding more stuff to the array'
    $array += [pscustomobject]@{someKey = 'SomeValue'}
    $array

    # Option 1 Use Array List
    # Good if you have mixed types
    $arrayList = [System.Collections.ArrayList]::new()
    $arrayList.Add('Adding stuff to the arrayList') | Out-Null
    $arrayList.Add('Adding more stuff to the array') | Out-Null
    $arrayList.Add([pscustomobject]@{someKey = 'SomeValue'}) | Out-Null
    $arrayList

    # Better to constrain what you're adding
    $genericList = [System.Collections.Generic.List[string]]::new()
    $genericList.Add('Adding stuff to the genericList')
    $genericList.Add('Adding more stuff to the genericList')
    $genericList.Add([pscustomobject]@{someKey = 'SomeValue'}) | Out-Null
    $genericList
#endregion Array Construction

## Building functions
#region poorly implemented parameters
function Get-Something {
    param (
        $User,
        $Age,
        $EmailAddress
    )
    [PSCustomObject]@{
        UserName = $User
        Age = $Age
        EmailAddress = $EmailAddress
    }
}
#endregion poorly implemented parameters

#region Type Constraint your Parameters
function Get-Something {
    param (
        [Parmeter(Mandatory)]
        [string]
        $User,

        [Parameter(Mandatory)]
        [int]
        $Age,

        [Parameter(Mandatory)]
        [mailaddress]
        $EmailAddress
    )
}
#endregion Type Constraint your Parameters

#region Add ShouldProcess support to State Changing Functions

<# When evaluating the ShouldProcess() method, a prompt will be generated
only if the current command's ConfirmImpact is equal to or higher
than the current $ConfirmPreference setting.

$ConfirmImpact is set to High by default #>

function Set-SomethingDestructive {
    [CmdletBinding(SupportsShouldProcess,
        DefaultParameterSetName = 'Parameter Set 1',
        ConfirmImpact = 'High')]
    Param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $Param1,

        [Parameter(ParameterSetName = 'Another Parameter Set')]
        [String]
        $Param2
    )

    process {
        if ($pscmdlet.ShouldProcess("Target", "Operation")) {
            
        }
    }
}


#endregion
