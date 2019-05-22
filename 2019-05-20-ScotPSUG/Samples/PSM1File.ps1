# Borrowed from https://github.com/RamblingCookieMonster/PSStackExchange/blob/db1277453374cb16684b35cf93a8f5c97288c41f/PSStackExchange/PSStackExchange.psm1
# Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the files
Foreach($import in @($Public + $Private)){
    Try{
        . $import.fullname
    }
    Catch{
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Here we might...
    # Read in or create an initial config file and variables
    # Set variables visible to the module and its functions only
    # Export public functions...
Export-ModuleMember -Function $Public.Basename


