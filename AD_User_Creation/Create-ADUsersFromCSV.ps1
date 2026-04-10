<#
.SYNOPSIS
    Création d'utilisateurs Active Directory en masse à partir d'un fichier CSV.
.DESCRIPTION
    Ce script lit un fichier CSV contenant Prénom, Nom, Service. 
    Il génère le SamAccountName, crée l'utilisateur dans la bonne OU et génère un mot de passe par défaut.
.EXAMPLE
    .\Create-ADUsersFromCSV.ps1 -CsvPath "C:\Temp\Nouveaux_Users.csv"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$CsvPath,
    [string]$DomainName = "mondomaine.local"
)

Import-Module ActiveDirectory

# Vérification de l'existence du fichier
if (-not (Test-Path $CsvPath)) {
    Write-Warning "Le fichier CSV est introuvable à l'emplacement : $CsvPath"
    return
}

$Users = Import-Csv -Path $CsvPath -Delimiter ";"

foreach ($User in $Users) {
    try {
        # Génération du SamAccountName (Exemple: a.pont)
        $FirstLetter = $User.Prenom.Substring(0,1).ToLower()
        $LastName = $User.Nom.ToLower().Replace(" ","")
        $SamAccountName = "$FirstLetter.$LastName"
        
        $UserPrincipalName = "$SamAccountName@$DomainName"

        # Mot de passe par défaut sécurisé
        $SecurePassword = ConvertTo-SecureString "Bienvenue2025!" -AsPlainText -Force

        # Définition de l'OU cible selon le service (à adapter selon ton infra)
        $TargetOU = "OU=$($User.Service),OU=Utilisateurs,DC=mondomaine,DC=local"

        # Création de l'utilisateur
        New-ADUser -Name "$($User.Prenom) $($User.Nom)" `
                   -GivenName $User.Prenom `
                   -Surname $User.Nom `
                   -SamAccountName $SamAccountName `
                   -UserPrincipalName $UserPrincipalName `
                   -Path $TargetOU `
                   -AccountPassword $SecurePassword `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true `
                   -Title $User.Titre

        Write-Host "[SUCCÈS] Utilisateur $SamAccountName créé avec succès." -ForegroundColor Green
    }
    catch {
        Write-Host "[ERREUR] Impossible de créer $($User.Prenom) $($User.Nom) : $_" -ForegroundColor Red
    }
}
