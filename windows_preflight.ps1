#Powershell pre-flight Check

#Parameters
$current_time = Get-Date -format u
$current_time = $current_time.split(" ")[0]
$outputfile = "$env:username" +"_" + "$current_time" + "_results.csv"
$results = @()

$sites = @(
	'google.com',
	'aws.amazon.com',
	'cloud.google.com',
	'rackspace.com',
	'azure.microsoft.com',
 	'manage.chef.io',
	'use.cloudshare.com',
	'supermarket.chef.io',
	'api.chef.io',
	'rubygems.org',
	'portquiz.net'
)

$urls = @(
	'https://downloads.chef.io/chef-dk/',
	'https://www.virtualbox.org/wiki/Downloads',
	'https://www.vagrantup.com/downloads.html'
)

$ports = @(
	@{endpoint = 'portquiz.net'; protocol = 'HTTP'; port = 80},
	@{endpoint = 'portquiz.net'; protocol = 'HTTPS'; port = 443},
	@{endpoint = 'portquiz.net'; protocol = 'SSH'; port = 22},
	@{endpoint = 'portquiz.net'; protocol = 'RDP'; port = 3389},
	@{endpoint = 'portquiz.net'; protocol = 'WinRM'; port = 5985}
) 

function Format-Color ([hashtable] $Colors = @{}, [switch] $SimpleMatch) {
	$lines = ($input | Out-String) -replace "`r", "" -split "`n"
	foreach($line in $lines) {
		$color = ''
		foreach($pattern in $Colors.Keys){
			if(!$SimpleMatch -and $line -match $pattern) { $color = $Colors[$pattern] }
			elseif ($SimpleMatch -and $line -like $pattern) { $color = $Colors[$pattern] }
		}
		if($line.length -gt 0) {
			if($color) {
				Write-Host -ForegroundColor $color $line 
			} else {
				Write-Host $line
			}
		}
	}
}

function Add-TestResult ($TestName, $Result) {
	$NewEntry = New-Object -TypeName PSObject -Property @{TestName=$TestName; Result=$Result}
	$script:results += $NewEntry
	"{0,-50} {1,-20}" -f $TestName, $Result  | Format-Color @{'FAIL' = 'Red'}
}


#Test-Admin
#Was the script run as an Administrator?
Function Test-Admin {
	Write-Host
	Write-Host "###############################################################################"
	Write-Host "Validating Local Admin Privileges."
	Write-Host

	if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
		$result = "[OK]"
	}
    else {
		$result = "[FAIL]"
    }

	Add-TestResult -TestName "ADMIN: Local Admin" -result $result
}

Function Test-DNS ($sites) {
	Write-Host
	Write-Host "###############################################################################"
	Write-Host "Testing DNS resolvers..."
	Write-Host
	Write-Host "Checking DNS for:"	
	Foreach ($site in $sites) {
		$result = (Get-DnsEntry $site)
		Add-TestResult -TestName "DNS: $site" -result $result
	}
}

Function Test-Websites ($sites) {
	Write-Host
	Write-Host "###############################################################################"
	Write-Host "Checking connectivity to Internet sites..."
	Write-Host
    
	Foreach($site in $Sites) {
	    try {
		   $web = New-Object Net.WebClient
		   $content = $web.DownloadString($site)
		   $result = '[OK]'
		}
		catch {
			$result = '[FAIL]'
		}
		Add-TestResult -TestName "WEB: $site" -result $result
	}
}

Function Get-DnsEntry ($IpHost) {
	$addresses = @()
	
	if($IpHost -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$") {
    	[System.Net.Dns]::GetHostEntry($iphost).HostName
  	}
 	elseif( $IpHost -match "^.*\.\.*") {
    	try {
			$addresses += [System.Net.Dns]::GetHostEntry($iphost).AddressList | Where-Object {$_.AddressFamily -eq 'InterNetwork'}
			$addresses[0].IPAddressToString
    	} 
		catch {
	   		"[FAIL]"
		}
	} 
}


function Test-Port ($Ports) {

	Write-Host
	Write-Host "###############################################################################"
	Write-Host "Checking outbound ports..."
	Write-Host

	foreach ($port in $Ports) {
		$ip = Get-DnsEntry -IpHost $port['endpoint']
		$t = New-Object Net.Sockets.TcpClient

		# We use Try\Catch to remove exception info from console if we can't connect
	    try {
	        $t.Connect($ip,$port['port'])
	    } catch {}

	    if($t.Connected) {
	        $t.Close()
			$result = "[OK]"
	    }
	    else {
			$result = "[FAIL]"
	    }
	    $msg = "PORT: {0,-6} {1,-10}" -f $port['port'], $port['protocol']
		Add-TestResult -TestName $msg -result $result
	}
}

function Get-Proxy {

	Write-Host
	Write-Host "###############################################################################"
	Write-Host "Checking proxy configuration..."
	Write-Host
	
	$IESettings = get-itemproperty -path "hkcu:Software\Microsoft\Windows\CurrentVersion\Internet Settings"
	
	if ($IESettings.ProxyEnable) {
		Add-TestResult -TestName "PROXY: Enabled" -result '[TRUE]'
		Add-TestResult -TestName "PROXY: Server" -result $IESettings.ProxyServer
		Add-TestResult -TestName "PROXY: Override" -result $IESettings.ProxyOverride
	}
	else {
		Add-TestResult -TestName "PROXY: Enabled" -result '[FALSE]'
	}
}

#Get-Environment
Function Get-Environment {
	# Useful Environment variables
	$envvars = @(
		'COMPUTERNAME',
		'PROCESSOR_ARCHITECTURE'
		'HOME',
		'HOMEDRIVE',
		'HOMEPATH',
		'HTTP_PROXY',
		'HTTPS_PROXY',
		'NO_PROXY',
		'PATH',
		'USERPROFILE',
		'VAGRANT_HOME',
		'EDITOR'
	)

	Write-Host
	Write-Host "###############################################################################"
	Write-Host "Getting useful environment variables..."
	Write-Host
	
	foreach ($envvar in $envvars) {
#		Add-TestResult -TestName 'ENV: $envvar' -Result $env:($envvar)
		Add-TestResult -TestName "ENV: $envvar" -Result $([environment]::GetEnvironmentVariable($envvar))
	}

	Write-Host
	Write-Host "###############################################################################"
	Write-Host "Getting Powershell Version..."
	Write-Host

	$h = Get-Host
	Add-TestResult -TestName 'PSVER: Version' -Result $h.Version
}

#Test Suite
Clear-Host

#Verify if user has admin credentials
Test-Admin

#Verify DNS resolvers
Test-DNS $Sites
Test-Websites $Urls

#Test outbound ports
Test-Port -Ports $ports

#Look for Proxy
Get-Proxy

#Grab useful environment details
Get-Environment

#Create output file/clean it out if it already exists.
$results | Export-Csv $outputfile -NoTypeInformation

#$results | select TestName,Result