#Do you have http connectivity to:
$outputfile = "results.txt"
$request = [System.Net.WebRequest]::Create('http://api.chef.io')

$response = $request.GetResponse()

if ($response.StatusCode -eq "OK")     {
        Write-Output "Site returned 200"
        $output = "Web Access = TRUE"
        $output | out-file $outputfile -a
    }
else {
        Write-Warning "Site returned something other than 200"
        $output = "Web Access = FALSE"
        $output | out-file $outputfile -a
}

$response.Close()