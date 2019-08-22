Import-module ActiveDirectory
$machines = Import-Csv C:\Scripts\Imports\POCServers.csv

$Outputarr = @()
foreach ($thing in $machines) {
    $Status = [pscustomobject]@{
        "Servern" = $thing.server
        #"Enabled" = $thing.enabled
    }
        if (Test-Connection $thing.server -Count 1 -ErrorAction SilentlyContinue -Quiet) {
            $status | Add-Member -MemberType NoteProperty -Name "Results" -Value Online
        }
        else {
            $status | Add-Member -MemberType NoteProperty -Name "Results" -Value Offline
        }
        
        $Outputarr += $Status
}

$Outputarr