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