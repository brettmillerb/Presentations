#region Add Webhook
$webhook = 'https://outlook.office.com/webhook/ad52f8e5-1ed9-40c4-b1a0-0c5f6d62675e@10a6d4fc-3a63-42d9-8a1e-744f8d79928d/IncomingWebhook/125e9663c05740ec92d3cd267b2d05c7/3840f450-6881-442c-8f9e-232ad6c29783'
#endregion

#region Stop me running everything :)
break
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

#region Collate some script data that you would like to send to Teams
$hash = @{
    username    = 'brett.miller'
    givenname   = 'Brett'
    name        = 'Brett Miller'
    email       = 'brett@millerb.co.uk'
    surname     = 'Miller'
}

New-TeamsMessage -Text 'this is some text' -Facts $hash -WebhookURI $webhook
#endregion

#region Something more concise than just a table of information
New-TeamsMessage -Title 'Very Informative title' -Text 'Some other informative Subtext' -Facts $hash -WebhookURI $webhook
#endregion

#region Splatting the parameters...easier to build dynamically
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

#region Adding 4 OpenURI Buttons
New-TeamsMessage @params -Button {
    Button -ButtonType OpenURI -ButtonName 'Click Me' -TargetURI 'https://millerb.co.uk'
    Button -ButtonType OpenURI -ButtonName 'No...Click Me!' -TargetURI 'https://millerb.co.uk'
    Button -ButtonType OpenURI -ButtonName 'Me Three' -TargetURI 'https://millerb.co.uk'
    Button -ButtonType OpenURI -ButtonName 'Nobody ever clicks Me :(' -TargetURI 'https://millerb.co.uk'
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
New-TeamsMessage @params -Image {
    Image -TargetURI 'http://millerb.co.uk/wp-content/uploads/2018/05/me-small.png' -Title 'Alttext'
    Image -TargetURI 'http://millerb.co.uk/wp-content/uploads/2018/04/flow-push.png' -Title 'Alttext'
}
#endregion

#region Pester Test Sample
BeforeAll {
    $servers = Get-Content C:\Users\brettm\Github\Presentations\Servers.json | ConvertFrom-Json
}

Describe 'Testing My Server Deployment' {
    Context 'Check all servers deployed' {
        It 'Servers should match deployment spec' {
            (Get-Member -InputObject $servers -MemberType NoteProperty).count | Should -Be '4'
        }
    }
    Context 'Check Server Names' {
        Get-Member -InputObject $servers -MemberType NoteProperty | Select-Object Name | ForEach-Object {
            It ("{0} Should Adhere to Naming Policy" -f $_.name) {
                $_.Name | Should -Match '^\w{2}\w{3}(Win|LNX)\d{3}$'
            }
        }
    }
    Context 'Check Disk Sizes' {
        Get-Member -InputObject $servers -MemberType NoteProperty | Select-Object -ExpandProperty name | ForEach-Object {
            It "$_ should have 500GB System Drive" {
                $servers.$_.disksize | Should -Be '500'
            }
        }
    }
    Context 'Check Memory Allocation' {
        Get-Member -InputObject $servers -MemberType NoteProperty | Select-Object -ExpandProperty name | ForEach-Object {
            It "$_ should have 16GB Memory at least" {
                $servers.$_.disksize | Should -BeGreaterThan '15'
            }
        }
    }
    Context 'Check Server Environment' {
        Get-Member -InputObject $servers -MemberType NoteProperty | Select-Object -ExpandProperty name | ForEach-Object {
            It "$_ should be a Production environment" {
                $servers.$_.Environment | Should -Be 'Production'
            }
        }
    }
}
#endregion

#region Adding a button to view OVF results
New-TeamsMessage @params -Button {
    Button -ButtonType OpenURI -ButtonName 'Click Me' -TargetURI 'https://millerb.co.uk' 
    Button -ButtonType OpenURI -ButtonName 'Pester Results' -TargetURI 'http://millerb.co.uk/wp-content/uploads/2018/05/PresentationResults.html' 
}
#endregion