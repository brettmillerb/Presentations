break
#region Profile(s)
    # $env:OneDrive\Documents\PowerShell\profile.ps1
    psedit $profile.CurrentUserAllHosts

    # Windows PowerShell in a different place
    psedit $env:OneDrive\Documents\WindowsPowerShell\profile.ps1

    Get-Command -Module Toolbox

    New-Multipass -Path C:\support -FileName testing -Name test1, test2, test3

    $pass = Get-MultiPass -Path C:\support\testing.xml

    $pass | Format-List

    syntax Get-ChildItem
#endregion Profile

#region snippets
@"
    {
        "CalculatedProperty": {
            "prefix": "Calculated-Property",
            "body": [
                "@{name='${1:PropertyName}';expression={${2:\\$_.PropertyValue}}}$0"
            ],
            "description": "Creates a PSCustomObject"
        }
    }
"@

psedit 'C:\Users\brett.miller\AppData\Roaming\Code - Insiders\User\snippets\powershell.json'
psedit 'C:\Users\brett.miller\AppData\Roaming\Code - Insiders\User\snippets\markdown.json'

'Demo use of snippets'

#endregion snippets

#region Keyboad Shortcuts
    'Demo keyboard shortcuts'
#endregion Keyboard Shortcuts

#region VSCode Extensions
'BracketPairColourizer'
'IndentRainbow'
[array]$variable = @{
    key = @(
        @{
            OtherKey = @(
                'value1'
                 'value2'
            )
        }
    )
}
$variable

'Previewers - Markdown, CSV, HTML'
psedit .\2019-03-27-ScotPSUG\test.csv
psedit .\2019-03-27-ScotPSUG\test.md

'Lorem Ipsum Generator'
'Available in the command palette'

'Settings Sync'
'TabOut'
'vscode-icons'
'gitlens'

'PowerShell Preview - The good one
Now with PSReadLine support'
#endregion VSCode Extensions

#region Essential Modules
    'EditorServicesCommandSuite'
    Get-ChildItem -Path .\ -Filter *.ps1 -Recurse -File -Force $true

    'Function Extraction'
    foreach ($storageAcc in $storageaccounts) {
        [PSCustomObject]@{
            Name = $storageAcc.name
            Name2 = $storageAcc.property2
            Name3 = $storageAcc.property3
        }
    }

    'Indented.Net.IP'
    Import-Module -Name Indented.Net.IP

    Get-Command -Module Indented.Net.IP

    Get-NetworkSummary -IPAddress 10.0.0.1 -SubnetMask 255.255.254.0
#endregion Essential Modules

#region Keyboard Quick Actions
    ls -Path .\ -Filter *.ps1

    dir -Path .\ -Filter *.ps1
#endregion Keyboard Quick Actions

#region Git and Git Integration
    psedit $home\.gitconfig
    psedit $home\.gitconfig-personal

    git log #difficult to read quickly
    git logline
#endregion

#region Firefox
    'module discovery and quick searching'
#endregion

#region debugging
    'want me to cover debugging?'
#endregion debugging