$isup = $false
$starttime = Get-Date
Write-Host $starttime,"Program start."
while($true){
    sleep 1
    $thetime = Get-Date
    
    if(test-connection 8.8.8.8 -count 1 -quiet) {
        if(-Not $isup) {
            Write-Host $thetime,"Connected" -foreground "DarkGreen"
            $isup = $true
        }
        else {
            Write-Host $thetime,"OK." -foreground "Green"
            
        }
    }
     
    else {
        if($isup) {
            Write-Host $thetime,"Connection problem or packet loss" -foreground "DarkRed"
            $isup = $false
        }
        else {
            Write-Host $thetime,"No connection." -foreground "Red"
        }
    }
}
