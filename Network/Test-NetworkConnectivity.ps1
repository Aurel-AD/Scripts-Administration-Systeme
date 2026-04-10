<#
.SYNOPSIS
    Script de diagnostic réseau niveau 1 pour l'assistance utilisateur.
.DESCRIPTION
    Ping la passerelle par défaut, le serveur DNS, internet (Google) et le serveur VPN interne.
    Possibilité de vider le cache DNS.
#>

[CmdletBinding()]
param (
    [switch]$FlushDNS
)

Write-Host "--- DIAGNOSTIC RÉSEAU ---" -ForegroundColor Cyan

# Fonction pour tester un ping et afficher le résultat en couleur
function Test-Ping {
    param([string]$Target, [string]$Name)
    if (Test-Connection -ComputerName $Target -Count 2 -Quiet) {
        Write-Host "[OK] $Name ($Target) est joignable." -ForegroundColor Green
    } else {
        Write-Host "[ERREUR] $Name ($Target) est INJOIGNABLE." -ForegroundColor Red
    }
}

# Trouver la passerelle par défaut
$Gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Sort-Object RouteMetric | Select-Object -First 1).NextHop

Test-Ping -Target $Gateway -Name "Passerelle par défaut"
Test-Ping -Target "8.8.8.8" -Name "Internet (DNS Google)"
Test-Ping -Target "10.0.0.5" -Name "Serveur Fichiers Interne (VPN)" # Modifie cette IP par une vraie IP de test LAN

if ($FlushDNS) {
    Write-Host "Vidage du cache DNS en cours..." -ForegroundColor Yellow
    Clear-DnsClientCache
    Write-Host "[OK] Cache DNS vidé." -ForegroundColor Green
}

Write-Host "--- FIN DU DIAGNOSTIC ---" -ForegroundColor Cyan
