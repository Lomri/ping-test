# Käyttäjien propertyt:
#
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
$totalusers = 0
$Logfile = "C:\Users\$env:UserName\Desktop\Massa_title_vaihto.log"
$server = ""

Function LogWrite  # Helpottaa login tekemisessä
{﻿# Käyttäjien propertyt:
#
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
$totalusers = 0
$Logfile = "C:\Users\$env:UserName\Desktop\Massa_title_vaihto.log"
$server = ""

Function LogWrite  # Helpottaa login tekemisessä
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
   # Käytä "Write-host" sijaan "LogWrite"
}

Function Changetitle # Vaihtaa titlejä. Syötä 
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
   # Käytä "Write-host" sijaan "LogWrite"
}

Function Changetitle # Vaihtaa titlejä. Syötä ensin tunnus ja sitten uusi title
{
    logwrite "$(Get-Date): $env:UserName : $($args[2]) -> $($args_[1])"
    set-aduser -server $server -identity $args[0] -title $args[1]  # muuttaa titlen 
    write-host "Muutetaan: $($args[2]) - $($args[1])"

}

# Haetaan käyttäjät
$users = Get-ADUser -server $server -filter {title -eq *} -properties * | select name, samaccountname, title


For($i = 1; $i -le $users.count; $i++) # Näytetään hieno status palkki
    {
    $SecondsElapsed = ((Get-Date) - $StartTime).TotalSeconds
    $SecondsRemaining = ($SecondsElapsed / ($i / $users.Count)) - $SecondsElapsed
    $totalusers++
    Write-Progress -Activity "Etsitään käyttäjiä..." -status "Löydetty $totalusers käyttäjää" -percentComplete ($i / $users.count*100) -SecondsRemaining $SecondsRemaining
    }

write-progress -Activity "Etsitään käyttäjiä..." -status "Valmis. Löydettiin $i käyttäjää." -Completed # Piilottaa hienon status palkin
write-host "Löydettiin yhteensä $totalusers käyttäjää."
if($totalusers -gt 0){
write-warning "Tämä vaihtaa käyttäjien titlejä!"

$valinta = read-host "Halutaanko muuttaa titlen $totalusers käyttäjältä? (Y jatkaa): "
$vaihdot = 0

    switch($valinta)
    {
        Y { 
            $valinta2 = read-host "Kirjoita VARMA mikäli haluat vaihtaa titlet: "
            switch($valinta2)
            {
                VARMA {

                        foreach ($kayttaja in $users)
                        {
                            $vanhatitle  = $kayttaja.title
                            $uusititle = $vanhatitle.substring(0,1).toupper()+$vanhatitle.substring(1)  # muuntaa tekstiä niin, että ensimmäinen kirjain on isolla
                            # substring(0,1) ottaa ensimmäisen kirjaimen ja substring(1) kaikki ensimmäisen jälkeen tulevat

                            if($vaihdot -gt 5) # ollaan vaihdettu jo yli viiden käyttäjän title käyttäjän hyväksymänä joten kaiken pitäisi olla ok ja vaihdetaan loput automaatiolla
                                { 
                                    Changetitle $kayttaja.samaccountname $uusititle  
                                } 

                            else{ # ajetaan pari kertaa varmistuksen kanssa jotta voidaan keskeyttää tarvittaessa alkuunsa
                                $valinta3 = read-host "Löydettiin: $($kayttaja.name) - $($kayttaja.title) - Vaihdetaanko titleksi: $($uusititle) ? (Y/N) N lopettaa heti"
                                switch($valinta3)
                                {
                                    Y { 
                                        Changetitle $kayttaja.samaccoutname $uusititle $kayttaja.name
                                        ++$vaihdot
                                    }

                                    N { 
                                            write-host "Lopetetaan heti."
                                            break
                                    }
                                }
                            
                            }
                   
                                            
                        
                        
                        }
                  
                  }
            }
        }

        N { break }
    }
    
    write-host "Asetettiin $vaihdot käyttäjän tittelit."
    
}

write-host "Paina nappulaa lopettaaksesi"
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
