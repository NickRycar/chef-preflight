#Powershell pre-flight check
#Was the script run as an administrator?
$outputfile = results.txt
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {
        Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        $output = "Admin Access = FALSE"
        $output | out-file $outputfile -a
    }

