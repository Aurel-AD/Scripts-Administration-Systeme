# 🧑‍💻 New-ADUserBatch

## 📝 Description
Ce script automatise la création d'utilisateurs dans l'Active Directory à partir d'un fichier CSV. Il permet de standardiser l'onboarding (arrivée de nouveaux collaborateurs) en évitant les erreurs manuelles et en gagnant un temps précieux.

## ⚙️ Prérequis
- Module PowerShell `ActiveDirectory` (RSAT) installé.
- Droits d'administration sur le domaine cible (Compte Admin de Domaine ou délégation sur l'OU).
- Un fichier source `users.csv` structuré (Prénom, Nom, Département, Titre).

## 🚀 Utilisation
```powershell
.\New-ADUserBatch.ps1 -CsvPath "C:\Temp\NouveauxArrivants.csv"
