markdown:
# 📧 Send-PasswordExpiryAlert

## 📝 Description
Un script de maintenance proactive qui interroge l'Active Directory pour identifier les utilisateurs dont le mot de passe va expirer dans les X prochains jours. Il envoie automatiquement un e-mail de rappel personnalisé à l'utilisateur concerné.

## ⚙️ Prérequis
- Module PowerShell `ActiveDirectory`.
- Accès à un serveur relais SMTP (ex: Exchange, Office 365, ou relais interne).

## 🚀 Utilisation
powershell:
.\Send-PasswordExpiryAlert.ps1 -DaysBeforeExpiry 14 -SmtpServer "smtp.mondomaine.com"
