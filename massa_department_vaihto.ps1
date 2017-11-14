
#$Properties =
#@(
# 'DisplayName',
# 'SamAccountName',
# 'Enabled',
# 'Created',
# 'AccountExpirationDate',
# 'telephoneNumber',
# 'EmailAddress',
# 'mobile',
# 'title',
# 'manager',
# 'physicalDeliveryOfficeName',
# 'otherTelephone',
# 'extensionAttribute1', # requires exchange
# 'extensionAttribute7',
# 'extensionAttribute15'
#)

$StartTime = Get-Date
$vanhadepartment = read-host "Minkä departmentin käyttäjiä etsitään?: "
$totalusers = 0
$Logfile = "C:\Massa_dept_vaihto.log"

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
   # Then replace your Write-host calls with LogWrite
}

$users = Get-ADUser -filter {department -eq $vanhadepartment} -properties * | select name, samaccountname, department


For($i = 1; $i -le $users.count; $i++)
    {
    $SecondsElapsed = ((Get-Date) - $StartTime).TotalSeconds
    $SecondsRemaining = ($SecondsElapsed / ($i / $users.Count)) - $SecondsElapsed
    $totalusers++
    Write-Progress -Activity "Etsitään käyttäjiä..." -status "Löydetty $totalusers käyttäjää" -percentComplete ($i / $users.count*100) -SecondsRemaining $SecondsRemaining
    }

write-progress -Activity "Etsitään käyttäjiä..." -status "Valmis. Löydettiin $i käyttäjää." -Completed
write-host "Löydettiin yhteensä $totalusers käyttäjää."
if($totalusers -gt 0){
write-warning "Tämä vaihtaa käyttäjien departmentteja!"

$valinta = read-host "Halutaanko vaihtaa department $totalusers käyttäjältä? (Y jatkaa): "
switch($valinta)
{
    Y { $uusidepartment = read-host "Anna uusi department: "
        write-host "-----------------------------"
        write-host "Vanha department: $vanhadepartment"
        write-host "Uusi department: $uusidepartment" -ForegroundColor Green
        write-host "-----------------------------"
        $valinta2 = read-host "Kirjoita VARMA mikäli haluat vaihtaa departmentit: "
        switch($valinta2)
        {
            VARMA {

                    foreach ($kayttaja in $users)
                    {
                        logwrite "$(Get-Date): $env:UserName : $kayttaja > -> $uusidepartment"
                        set-aduser -identity $kayttaja.samaccountname -department $uusidepartment                        
                        Write-Progress -Activity "Asetetaan uusi department" -status $kayttaja.name
                    }
                  
                  }
        }
      write-host "Asetettiin $totalusers käyttäjän departmentiksi: $uusidepartment"
      Write-Progress -Activity "Asetetaan uusi department" -Completed
    
      }
}
}
write-host "Paina nappulaa lopettaaksesi"
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")