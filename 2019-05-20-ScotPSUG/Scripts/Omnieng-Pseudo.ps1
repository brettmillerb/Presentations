$GPO = Get-GPO -All -Domain omnieng.co.uk -Server vmtrw0001.omnieng.co.uk

foreach ($Policy in $GPO){

        $GPOID = $Policy.Id
        $GPODom = $Policy.DomainName
        $GPODisp = $Policy.DisplayName

            if (Test-Path "\\$($GPODom)\SYSVOL\$($GPODom)\Policies\{$($GPOID)}\User\Preferences\Drives\Drives.xml")
            {
                [xml]$DriveXML = Get-Content "\\$($GPODom)\SYSVOL\$($GPODom)\Policies\{$($GPOID)}\User\Preferences\Drives\Drives.xml"

                    foreach ( $drivemap in $DriveXML.Drives.Drive ) {
                            $properties = @{
                            GPOName = $GPODisp
                            DriveLetter = $drivemap.Properties.Letter + ":"
                            DrivePath = $drivemap.Properties.Path
                            DriveAction = $drivemap.Properties.action.Replace("U","Update").Replace("C","Create").Replace("D","Delete").Replace("R","Replace")
                            DriveLabel = $drivemap.Properties.label
                            DrivePersistent = $drivemap.Properties.persistent.Replace("0","False").Replace("1","True")
                            DriveFilterGroup = $drivemap.Filters.FilterGroup.Name
                            }
                            
                            $GPPObject = New-Object -TypeName psobject -Property $properties
                            #Write-Output $GPPObject
                            $GPPObject | Export-Csv C:\Scripts\Exports\OmniGPP.csv -Append -NoTypeInformation
                    }
        }
}

$GPO = Get-GPO -All
 
        foreach ($Policy in $GPO){
 
                $GPOID = $Policy.Id
                $GPODom = $Policy.DomainName
                $GPODisp = $Policy.DisplayName
 
                 if (Test-Path "\\$($GPODom)\SYSVOL\$($GPODom)\Policies\{$($GPOID)}\User\Preferences\Drives\Drives.xml")
                 {
                     [xml]$DriveXML = Get-Content "\\$($GPODom)\SYSVOL\$($GPODom)\Policies\{$($GPOID)}\User\Preferences\Drives\Drives.xml"
 
                            foreach ( $drivemap in $DriveXML.Drives.Drive )
 
                                {New-Object PSObject -Property @{
                                    GPOName = $GPODisp
                                    DriveLetter = $drivemap.Properties.Letter + ":"
                                    DrivePath = $drivemap.Properties.Path
                                    DriveAction = $drivemap.Properties.action.Replace("U","Update").Replace("C","Create").Replace("D","Delete").Replace("R","Replace")
                                    DriveLabel = $drivemap.Properties.label
                                    DrivePersistent = $drivemap.Properties.persistent.Replace("0","False").Replace("1","True")
                                    DriveFilterGroup = $drivemap.Filters.FilterGroup.Name
                                }
                            }
                }
        }

# New AD Group Creation for Omnieng
$OmniPrinters = get-printer -ComputerName printserver | select name, computername,drivername,portname

foreach ($printer in $OmniPrinters) {
    $printserver = $printer.computername
    $printername = $printer.name
    $ADGroup = "prn..GBSHESFCOMPW001..SheffieldSafeCom"

    $params = @{
        Name = $ADGroup
        SamAccountName = $ADGroup
        GroupCategory = 'Security'
        GroupScope = 'Global'
        path = 'ou=Logon Script,ou=Groups,ou=BBU,dc=bbds,dc=balfourbeatty,dc=com'}

    New-ADGroup @params -Credential $creds
    
}

$params = @{
        Name = $item
        SamAccountName = $item
        GroupCategory = 'Security'
        GroupScope = 'Global'
        path = 'ou=Logon Script,ou=Groups,ou=OEL,dc=bbds,dc=balfourbeatty,dc=com'}