#Powershell pre-flight Check
#This module contains the various functions necessary for pre-flight checks on Windows workstations

#Parameters
$current_time = Get-Date -format u
$current_time = $current_time.split(" ")[0]
$outputfile = "$env:username" +"_" + "$current_time" + "_results.csv"
$output = @()
$Providers = @{
    Azure = 'ado-web.cloudapp.net';
    Rackspace = 'galenemery.com';
    Amazon = '54.187.33.204'
}
#Test-Admin
#Was the script run as an Administrator?
Function Test-Admin {
    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
        {
        Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        $output += New-Object -TypeName PSObject -Property @{Test="Admin Access";Result=$false}
        }
    else {
        Write-Output "You ran this as an Administrator"
        $output += New-Object -TypeName PSObject -Property @{Test="Admin Access";Result=$true}
    }
    $output | Select Test,Result | Export-Csv $outputfile -NoTypeInformation -append
}

#Test-SSH
function Test-Port {
    param(
        [string]$endpoint,
        [int]$port,
        [string]$provider = "$endpoint"
        )

    # This works no matter in which form we get $host - hostname or ip address
    try {
        $ip = [System.Net.Dns]::GetHostAddresses($endpoint) | 
            select-object IPAddressToString -expandproperty  IPAddressToString
        if($ip.GetType().Name -eq "Object[]")
        {
            #If we have several ip's for that address, let's take first one
            $ip = $ip[0]
        }
    } catch {
        Write-Error "$endpoint is not resolvable"
        return
    }
    $t = New-Object Net.Sockets.TcpClient
    # We use Try\Catch to remove exception info from console if we can't connect
    try
    {
        $t.Connect($ip,$port)
    } catch {}

    if($t.Connected)
    {
        $t.Close()
        $msg = "Port $port on $provider is operational"
        $output += New-Object -TypeName PSObject -Property @{Test="$provider Port:$port Access";Result=$true}
    }
    else
    {
        $msg = "Port $port on $provider is closed, "
        $msg += "You may need to contact your IT team to open access to $provider on port $port"
        $output += New-Object -TypeName PSObject -Property @{Test="$provider Port:$port Access";Result=$false}                                 
    }
    Write-Host $msg
    $output | Select Test,Result | Export-Csv $outputfile -NoTypeInformation -append
}

#Get-Environment
Function Get-Environment {
    $environment_output = $Env:username + "_environment.csv"
    Get-Childitem env: | Select Name,Value | export-csv $environment_output -NoTypeInformation
    Write-Output "Environment info saved to $environment_output"
    $h = Get-Host
    $psversion = $h.Version
    $output += New-Object -TypeName PSObject -Property @{Test="Powershell Version";Result=$psversion}
    $output | Select Test,Result | Export-Csv $outputfile -NoTypeInformation -append
    Write-Output "Running Powershell Version $psversion"
}

#Test Suite

#Create output file/clean it out if it already exists.
$output | Export-Csv $outputfile -NoTypeInformation

#Verify if user has admin credentials
Test-Admin

#Grab all of the environment details
Get-Environment

#Test each port on each provider
ForEach($item in $Providers.GetEnumerator() ) {
    $endpoint = $item.Value
    $provider = $item.Name
    Test-Port $endpoint 22 $provider
    Test-Port $endpoint 80 $provider
    Test-Port $endpoint 443 $provider
    Test-Port $endpoint 3389 $provider
    Test-Port $endpoint 5985 $provider
}