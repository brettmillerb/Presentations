## MicrosoftTeams Administration module

#region Find, Import & Connect...
    # Find and install the module on the PSGallery
    Find-Module -Name MicrosoftTeams | Install-Module -Scope CurrentUser

    # Import the module
    Import-Module MicrosoftTeams

    # Take a look at the commands
    Get-Command -Module MicrosoftTeams

    # Connect - Prompted for MFA (most of the time)
    Connect-MicrosoftTeams
#endregion Find, Import & Connect

#region Show command usage and some caveats/issues...
    # Get all teams in a tenant
    Get-Team

    # Get members of a team
    Get-TeamUser -GroupId (Get-Team | Where-Object displayname -like 'ANZ*').GroupId

    # Get channels in a team
    Get-TeamChannel -GroupId (Get-Team | Where-Object displayname -like 'ANZ*').GroupId
#endregion show command usage

#region Wrapper functions to find groups and channels using strings instead of GUIDs
    function New-MsTeamsChannel {
        [cmdletbinding(DefaultParameterSetName = 'Input')]
        param (
            [Parameter(Mandatory,
                Position = 0,
                ValueFromPipeline,
                ValueFromPipelineByPropertyName,
                ParameterSetName = 'Input')]
            [string[]]
            $DisplayName, 

            [Parameter(Mandatory)]
            [string]
            $TeamName
        )

        begin {
            $teamGroupId = Get-Team | Where-Object displayname -like "*$TeamName*" | Select -ExpandProperty GroupId
        }
        
        process {
            if ($PSCmdlet.ParameterSetName -eq 'Input') {
                foreach ($item in $DisplayName) {
                    [PSCustomObject]@{
                        DisplayName = $item
                        GroupId     = $teamGroupId
                    }
                }
            }
            else {
                [PSCustomObject]@{
                    Displayname = $_.DisplayName
                    GroupId     = $_.TeamName
                }
            }
        }
    }

    function Get-MsTeamsGroupId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $TeamName
    )

    process {
        Get-Team | Where-Object displayname -like "*$TeamName*"
    }
}
#endregion Wrapper functions

#region show wrapper function usage for usability...
    'Test Channel 1', 'Test Channel 2', 'Test Channel 3' | New-MSTeamsChannel -TeamName 'ANZPS' | New-TeamChannel

    # Get team fun settings showing wrapper function use
    Get-TeamFunSettings -GroupId (Get-Team | Where-Object displayname -like 'ANZPS*').groupid
    Get-MsTeamsGroupId -TeamName 'scot' | Get-TeamFunSettings
    'scot' | Get-MsTeamsGroupId | Get-TeamFunSettings

    <# 
        Set-TeamFunSettings is the worst for usability
        Three string parameters which should be switches
        One string parameter which should be an enum or set - only accepts 'strict' or 'moderate'
    #>

    # Doesn't work because the Set needs the GroupID which Get-TeamFunSettings doesn't output
    Get-TeamFunSettings -GroupId (Get-Team | Where-Object displayname -like 'scot*').groupid | Set-TeamFunSettings

    # Instead you have to use the succinct command below
    Set-TeamFunSettings -GroupId (Get-Team | Where-Object displayname -like 'demo*') -GiphyContentRating strict -AllowCustomMemes false
    Get-Team | ? displayname -like 'demo*' | Set-TeamFunSettings -AllowGiphy true -GiphyContentRating moderate -AllowCustomMemes true

    # Or using the wrapper functions
    Get-MsTeamsGroupId 'scot' | Set-TeamFunSettings -AllowGiphy true -GiphyContentRating strict -AllowCustomMemes false
#endregion

#region MSTeams Webhooks
    #region Add Webhook
    $webhook = 'https://outlook.office.com/webhook/24599b6e-adc3-44ea-b6c1-b6f8906413cc@10a6d4fc-3a63-42d9-8a1e-744f8d79928d/IncomingWebhook/af5868787c9441dcafdb4291486524ed/3840f450-6881-442c-8f9e-232ad6c29783'
    #endregion

    #region Send a simple message to a channel
    "This is a message"         | New-TeamsMessage -WebhookURI $webhook
    #endregion

    #region Send some simple messages as a notification to Teams
    "This is a message"         | New-TeamsMessage -WebhookURI $webhook
    "This is another message"   | New-TeamsMessage -WebhookURI $webhook
    "This is a third message"   | New-TeamsMessage -WebhookURI $webhook
    "This is a fourth message"  | New-TeamsMessage -WebhookURI $webhook
    #endregion

    #region Send some simple messages with colour ooooh!
    "Yaayyyyyy GOOD message"    | New-TeamsMessage -WebhookURI $webhook -Color green
    "Ooohhhhhh Warning message" | New-TeamsMessage -WebhookURI $webhook -Color orange
    "Aaahhhhhh ERROR message"   | New-TeamsMessage -WebhookURI $webhook -Color red
    #endregion

    #region Splatting the parameters...easier to build dynamically
    $hash = @{
        Enabled      = $true
        emailaddress = 'brett@millerb.co.uk'
        givenname    = 'Brett'
        surname      = 'Miller'
    }

    $params = @{
        Title       = 'Some Helpful Title'
        Text        = 'Some bumph to give an idea of what stuff is'
        Facts       = $hash
        WebhookURI  = $Webhook
        Colour      = 'Purple'
    }

    New-TeamsMessage @params
    #endregion

    #region Splatting the parameters...easier to build dynamically
    $params = @{
        Title               = 'Some Helpful Title'
        activityTitle       = 'An Activity Title...because why not'
        activitySubtitle    = 'Because you can never have enough titles'
        Text                = 'Some bumph to give an idea of what stuff is'
        Facts               = $hash
        WebhookURI          = $webhook
        Colour              = 'Purple'
    }

    New-TeamsMessage @params
    #endregion

    #region Adding an OpenURI Button
    New-TeamsMessage @params -Button {
        Button -ButtonType OpenURI -ButtonName 'Click Me' -TargetURI 'https://millerb.co.uk' 
    }
    #endregion

    #region Adding an OpenURI Button useful link
    New-TeamsMessage @params -Button {
        Button -ButtonType TextInput -ButtonName 'Leave a Comment' -TargetURI 'https://millerb.co.uk'
        Button -ButtonType DateInput -ButtonName 'Choose a Date' -TargetURI 'https://millerb.co.uk'
    }
    #endregion

    #region Adding an OpenURI Button useful link
    New-TeamsMessage @params -Button {
        Button -ButtonType TextInput -ButtonName 'Leave a Comment' -TargetURI 'https://millerb.co.uk'
        Button -ButtonType DateInput -ButtonName 'Choose a Date' -TargetURI 'https://millerb.co.uk'
        Button -ButtonType HttpPost -ButtonName 'POST Stuff' -TargetURI 'https://millerb.co.uk'
        Button -ButtonType OpenURI -ButtonName 'Open Me :)' -TargetURI 'https://millerb.co.uk'
    }
    #endregion

    #region Adding Embedded Images
    $params = @{
        Title               = 'Some Helpful Title'
        activityTitle       = 'An Activity Title...because why not'
        activitySubtitle    = 'Because you can never have enough titles'
        Text                = 'Some bumph to give an idea of what stuff is'
        Facts               = $hash
        WebhookURI          = $webhook
        Colour              = 'Purple'
        Image               = @('https://raw.githubusercontent.com/brettmillerb/brettmillerb.github.io/master/assets/img/flow-push.png',
                                'https://raw.githubusercontent.com/brettmillerb/brettmillerb.github.io/master/images/avatar.jpg')
    }
    
    New-TeamsMessage @params
    #endregion
#endregion

## END