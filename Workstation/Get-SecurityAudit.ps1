<#
.SYNOPSIS
    Audit rapide de la sécurité d'un poste de travail Windows.
.DESCRIPTION
    Vérifie BitLocker, le Pare-feu, Windows Defender et le groupe Administrateurs locaux.
    Génère un rapport HTML.
#>

[CmdletBinding()]
param ()

Write-Host "Démarrage de l'audit de sécurité..." -ForegroundColor Cyan

# Initialisation des résultats
$ComputerName = $env:COMPUTERNAME
$Date = Get-Date -Format "dd/MM/yyyy HH:mm"

# 1. Vérification BitLocker (Lecteur C:)
try {
    $BitLocker = Get-BitLockerVolume -MountPoint "C:" -ErrorAction Stop
    $BLStatus = $BitLocker.VolumeStatus
} catch {
    $BLStatus = "Non vérifiable (Nécessite droits Admin)"
}

# 2. Vérification du Pare-Feu
$Firewall = Get-NetFirewallProfile -Name Domain, Private, Public | Select-Object Name, Enabled
$FWStatus = if ($Firewall.Enabled -contains $false) { "Désactivé sur certains profils !" } else { "Actif" }

# 3. Vérification Antivirus (Defender)
try {
    $Defender = Get-MpComputerStatus
    $AVStatus = if ($Defender.AMServiceEnabled) { "Actif et en cours d'exécution" } else { "Désactivé" }
} catch {
    $AVStatus = "Service non détecté"
}

# 4. Membres du groupe Administrateurs locaux
$LocalAdmins = (Get-LocalGroupMember -Group "Administrateurs").Name -join ", "

# --- Création du rapport HTML ---
$ReportPath = "$env:USERPROFILE\Desktop\Audit_Securite_$ComputerName.html"

$HTML = @"
<!DOCTYPE html>
<html>
<head>
<title>Audit Sécurité - $ComputerName</title>
<style>
    body { font-family: Arial; background-color: #f4f4f9; color: #333; }
    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #34d399; color: white; }
    h2 { color: #0b1120; }
</style>
</head>
<body>
    <h2>Rapport d'audit - $ComputerName</h2>
    <p><strong>Date :</strong> $Date</p>
    <table>
        <tr><th>Élément contrôlé</th><th>Statut</th></tr>
        <tr><td>BitLocker (C:)</td><td>$BLStatus</td></tr>
        <tr><td>Pare-feu Windows</td><td>$FWStatus</td></tr>
        <tr><td>Antivirus (Defender)</td><td>$AVStatus</td></tr>
        <tr><td>Admins Locaux</td><td>$LocalAdmins</td></tr>
    </table>
</body>
</html>
"@

$HTML | Out-File -FilePath $ReportPath -Encoding UTF8
Write-Host "[SUCCÈS] Rapport généré sur le bureau : $ReportPath" -ForegroundColor Green
