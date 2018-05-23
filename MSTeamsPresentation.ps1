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

#region Variations of blue...because why not
"This is a message"         | New-TeamsMessage -WebhookURI $webhook -Color skyblue
"This is another message"   | New-TeamsMessage -WebhookURI $webhook -Color slateblue
"This is a third message"   | New-TeamsMessage -WebhookURI $webhook -Color teal
"This is a fourth message"  | New-TeamsMessage -WebhookURI $webhook -Color royalblue
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
    WebhookURI  = $OTWebhook
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
    Image -TargetURI 'http://millerb.co.uk/wp-content/uploads/2017/02/wordpress-logo-square.png' -Title 'Alttext'
    Image -TargetURI 'http://millerb.co.uk/wp-content/uploads/2018/04/flow-push.png' -Title 'Alttext'
}
#endregion

#region Adding a button to view OVF results
New-TeamsMessage @params -Button {
    Button -ButtonType OpenURI -ButtonName 'Click Me' -TargetURI 'https://millerb.co.uk' 
    Button -ButtonType OpenURI -ButtonName 'Pester Results' -TargetURI 'http://millerb.co.uk/wp-content/uploads/2018/05/PresentationResults.html' 
}
#endregion