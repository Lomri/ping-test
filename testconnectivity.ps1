# Simple Powershell script to monitor Internet availability
# Pings a certain IP every second

# ip to test connectivity to
$TestIP = "8.8.8.8"
# sleep time in seconds
$Sleep_time = 1
# we use this
$isup = $false

Write-Host (Get-Date),"Program start."

while($true)
{
    sleep $Sleep_time
    $thetime = Get-Date
    
    if(test-connection $testIP -count 1 -quiet)
    {
        # Connection OK
        if(-Not $isup)
        {
            # We connected for the first time or we reconnected after a disconnect
            Write-Host $thetime,"Connected" -foreground "DarkGreen"
            $isup = $true
        }
        else 
        {
            # Everything is fine and we are still connected
            Write-Host $thetime,"OK." -foreground "Green"
        }
    }
    
    else 
    {
        # Connection not ok
        if($isup) 
        {
            # Our $isup is set to true which means we were connected in earlier check
            Write-Host $thetime,"Connection problem or packet loss" -foreground "DarkRed"
            $isup = $false
        }
        else 
        {
            Write-Host $thetime,"No connection." -foreground "Red"
        }
    }
}
