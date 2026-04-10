<#
.SYNOPSIS
    Maintenance de base d'un poste utilisateur.
.DESCRIPTION
    Vide les répertoires temporaires, la corbeille, et vérifie l'uptime de la machine.
#>

[CmdletBinding()]
param()

Write-Host "Démarrage de la maintenance..." -ForegroundColor Cyan

# 1. Vérification de l'Uptime (Temps depuis le dernier redémarrage)
$OS = Get-CimInstance Win32_OperatingSystem
$LastBoot = $OS.LastBootUpTime
$Uptime = (Get-Date) - $LastBoot

Write-Host "Le PC est allumé depuis $($Uptime.Days) jours et $($Uptime.Hours) heures."
if ($Uptime.Days -ge 14) {
    Write-Host "[ATTENTION] Le PC n'a pas été redémarré depuis plus de 14 jours. Pensez à redémarrer !" -ForegroundColor Yellow
} else {
    Write-Host "[OK] Cycle de redémarrage sain." -ForegroundColor Green
}

# 2. Vidage de la corbeille (sans demander confirmation)
try {
    Clear-RecycleBin -Force -ErrorAction Stop
    Write-Host "[OK] Corbeille vidée." -ForegroundColor Green
} catch {
    Write-Host "[INFO] La corbeille est déjà vide ou inaccessible." -ForegroundColor Gray
}

# 3. Nettoyage des fichiers temporaires (Dossier Temp Windows et Temp Utilisateur)
$TempFolders = @("$env:TEMP\*", "C:\Windows\Temp\*")
$FreedSpace = 0

foreach ($Folder in $TempFolders) {
    try {
        Remove-Item -Path $Folder -Recurse -Force -ErrorAction SilentlyContinue
    } catch {
        # Ignore les fichiers en cours d'utilisation
    }
}
Write-Host "[OK] Fichiers temporaires obsolètes supprimés." -ForegroundColor Green

Write-Host "Maintenance terminée !" -ForegroundColor Cyan
