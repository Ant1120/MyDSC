Param(
    [Parameter(Mandatory=$false)][string]$NodeName,
    [Parameter(Mandatory=$false)][string]$Role
)


#$node = New-Object object
#$node | Add-Member -type noteproperty -name NodeName -value $NodeName
#$node | Add-Member -type noteproperty -name Role - value $Role


$MyData = 
@{
    AllNodes =
    @(
        @{
            NodeName    = 'FS005'
            Role = 'FS'
        }

        @{
            NodeName    = 'FS002'
            Role = 'FS'
        }

        @{
            NodeName    = 'FS003'
            Role = 'FS'
        }

        @{
            NodeName    = 'FS004'
            Role = 'FS'
        }

        @{
            NodeName    = 'localhost'
            Role = 'HV'
        }
    )
}


Configuration FS
{


    # One can evaluate expressions to get the node list
    # E.g: $AllNodes.Where("Role -eq Web").NodeName
    node $AllNodes.Where{$_.Role -eq "FS"}.NodeName 
    {
        # Call Resource Provider
        # E.g: WindowsFeature, File
        WindowsFeature FileServer
        {
           Ensure = "Present"
           Name = "FileAndStorage-Services"
           LogPath = "C:\Logs\DSC.log"
        }

    }
}


Configuration HV{
    
    Node $AllNodes.Where{$_.Role -eq "HV"}.NodeName 
    {
        WindowsFeature HyperV {
            name = "Hyper-V"
            Ensure = "Present"
            LogPath = "C:\Logs\DSC.log"
        }
        WindowsFeature DNS {
            name = "DNS"
            Ensure = "Present"
            LogPath = "C:\Logs\DSC.log"
        }
        WindowsFeature ADDS {
            Name = "AD-DOmain-Services"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]DNS"
            LogPath = "C:\Logs\DSC.log"
        }
    }
}

HV -ConfigurationData $MyData
FS -ConfigurationData $MyData