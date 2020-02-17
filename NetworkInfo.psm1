Function Get-NetworkInfo{
Param(

    [string]$computername
)

$computersystem = Get-CimInstance -ComputerName $computername -ClassName Win32_ComputerSystem | select *
$networkinfo = Get-CimInstance -ComputerName $computername -ClassName Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq $true} | select *

$output =  Foreach ($network in $networkinfo) {

                 [PSCustomObject]@{
                    
                    Name        =    $computersystem.Name
                    IPAddress   =    $network.IPAddress[0]
                    Model       =    $computersystem.Model
                    MACAddress  =    $network.MACAddress
             }
    }

$output | ft -GroupBy Ipaddress
}

