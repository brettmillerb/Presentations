function Test-ServerOnline {
    <#
    .SYNOPSIS
    Short description
    
    .DESCRIPTION
    Long description
    
    .PARAMETER file
    Parameter description
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>
    param (
        [string]
        $file
    )
    $machines = Import-Csv -Path $file
    
    foreach ($thing in $machines) {
        $Status = [pscustomobject]@{
            Servername = $thing.server
        }
        if (Test-Connection $thing.server -Count 1 -ErrorAction SilentlyContinue -Quiet) {
            $status | Add-Member -MemberType NoteProperty -Name "Results" -Value Online
        }
        else {
            $status | Add-Member -MemberType NoteProperty -Name "Results" -Value Offline
        }
        $status
    }
}