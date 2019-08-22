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
        [string[]]
        $IPAddress
    )
    foreach ($thing in $IPAddress) {
        $Status = [ordered]@{
            IPAddress = $thing
        }
        if (Test-Connection $thing -Count 1 -ErrorAction SilentlyContinue -Quiet) {
            $status.Add('Results', 'Online')
        }
        else {
            $status.Add('Results', 'Offline')
        }
        [pscustomobject]$status
    }
}