<#
.SYNOPSIS
    Alerte d'expiration des mots de passe AD.
.DESCRIPTION
    Cherche les comptes expirant dans les 7 prochains jours et envoie une notification par e-mail.
    Script conçu pour être lancé par une tâche planifiée sur le serveur.
#>

[CmdletBinding()]
param (
    [int]$DaysBeforeExpiration = 7,
    [string]$SMTPServer = "smtp.entreprise.local",
    [string]$FromEmail = "it-support@entreprise.com"
)

Import-Module ActiveDirectory

Write-Host "Recherche des mots de passe expirant dans $DaysBeforeExpiration jours..." -ForegroundColor Cyan

# Trouve les comptes avec un mdp qui expire (exclut les comptes désactivés)
$ExpiringUsers = Search-ADAccount -PasswordExpiring -TimeSpan "$DaysBeforeExpiration.00:00:00" | 
                 Where-Object { $_.Enabled -eq $true }

if (-not $ExpiringUsers) {
    Write-Host "[OK] Aucun mot de passe n'expire prochainement." -ForegroundColor Green
    return
}

foreach ($User in $ExpiringUsers) {
    # On récupère l'email de l'utilisateur
    $ADUser = Get-ADUser -Identity $User.SamAccountName -Properties EmailAddress, msDS-UserPasswordExpiryTimeComputed
    
    if ($ADUser.EmailAddress) {
        
        $Subject = "⚠️ Votre mot de passe Windows expire bientôt !"
        $Body = @"
Bonjour $($ADUser.GivenName),<br><br>
Ceci est un message automatique du support informatique.<br>
Votre mot de passe Windows va expirer dans moins de $DaysBeforeExpiration jours.<br><br>
Merci d'appuyer sur <b>CTRL + ALT + SUPPR</b> puis "Modifier le mot de passe" avant l'expiration pour éviter le blocage de votre compte.<br><br>
Cordialement,<br>
L'équipe Support IT.
"@

        try {
            Send-MailMessage -From $FromEmail -To $ADUser.EmailAddress -Subject $Subject -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -Encoding UTF8
            Write-Host "[SUCCÈS] Email envoyé à $($ADUser.EmailAddress)" -ForegroundColor Green
        }
        catch {
            Write-Host "[ERREUR] Impossible d'envoyer l'email à $($ADUser.EmailAddress) : $_" -ForegroundColor Red
        }
    }
}
