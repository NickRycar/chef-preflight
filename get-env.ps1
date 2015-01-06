$outputfile = results.txt
Get-Childitem env: | out-file $outputfile -a
Get-Host | out-file $outputfile -a