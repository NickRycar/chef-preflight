#This Function sets the user's home drive and home path to the systemdrive and standard \users\username respectively.
#This is designed for Windows Vista+ systems that use "\Users" instead of "\Documents and Settings"

Function Set-Home {
    param(
        [string]$homedrive = "$env:systemdrive",
        [string]$username = "$env:username"
        )
    Write-Host "Setting Homedrive to $homedrive"
    $env:homedrive = $homedrive
    Write-Host "Setting Homepath to \Users\$username"
    $env:homepath = "\Users\" + $username
}

#Usage: If the $env:systemdrive or env:username are incorrect for your system, use the following example:
#Set-Home "Drivename" "User_folder"
#Set-Home "Q:" "My_Name"
Set-Home
