
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
write-host $StartTime
$vanhadepartment = read-host "Minkä departmentin käyttäjiä etsitään?: "
$totalusers = 0

# Käyttäjien haku:
$users = Get-ADUser -filter {(department -eq $vanhadepartment -and emailaddress -like "*@*" -and enabled -eq $true)} -properties * | select name, samaccountname, emailaddress, department

# Hieno progressbar
For($i = 1; $i -le $users.count; $i++)
    {
    $SecondsElapsed = ((Get-Date) - $StartTime).TotalSeconds
    $secondsRemaining = ($SecondsElapsed.TotalSeconds / $i) * ($users.Count - $i)
    $SecondsElapsed = "{0:N0}" -f $SecondsElapsed
    ++$totalusers
    Write-Progress -Activity "Etsitään käyttäjiä..." -status "Löydetty $totalusers käyttäjää. Aikaa mennyt: $SecondsElapsed" -percentComplete ($i / $users.count*100) -SecondsRemaining $SecondsRemaining
    }

# Käyttäjät on käsitelty, joten seuraavaksi hienon progressbarin piilotus
write-progress -Activity "Etsitään käyttäjiä..." -status "Valmis. Löydettiin $i käyttäjää." -Completed

# Infotaan käyttäjää hyvästä työstä
write-host "Löydettiin yhteensä $totalusers käyttäjää."

# Käyttäjien tallennus tiedostoon:

# Ensin haetaan unix timestamp jotta tiedoston nimestä tulee uniikki
$unixtimestamp = ([DateTimeOffset](Get-Date)).ToUnixTimeSeconds()

write-host "Nimetään tiedosto: users-$unixtimestamp.csv"
$users | export-csv -path "users-$unixtimestamp.csv" -Encoding UTF8 -Append -NoTypeInformation -NoClobber

# Odotetaan mikäli tiedostosta tulee iso ja tietokone käy hitaalla
write-host "Odotellaan 5 sekuntia.."
start-sleep -s 5

# Joskus tulee duplikaatteja, siivotaan ne pois
write-host "Siivotaan tiedostosta duplikaatit.."
Import-Csv "users-$unixtimestamp.csv" | sort name –Unique | Export-Csv "users-$unixtimestamp-siivottu.csv" -Encoding UTF8 -Append -NoTypeInformation -NoClobber

# Lopuksi odotellaan napin painamista koska miksi ei
write-host "Paina nappulaa lopettaaksesi"
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")