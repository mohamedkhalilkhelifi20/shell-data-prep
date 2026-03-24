# DataPrep - Outil de Préparation et Gestion des Données

## Objectif

Développer un outil CLI interactif en **script shell** permettant de :

- Gérer des fichiers CSV
- Nettoyer des données simples
- Supprimer les lignes invalides
- Diviser un dataset en Train/Test
- Organiser les dossiers pour l'apprentissage
- Générer un rapport statistique

---

## Fonctionnalités

| Option | Description |
|--------|-------------|
| **1** | Charger un dataset CSV |
| **2** | Afficher les statistiques du dataset |
| **3** | Supprimer les lignes vides |
| **4** | Supprimer les lignes non annotées (contenant "NULL") |
| **5** | Supprimer les doublons simples |
| **6** | Diviser le dataset en Train/Test |
| **7** | Organiser les dossiers train/test |
| **8** | Générer un rapport statistique |
| **9** | Quitter |

---

## Exécution du projet

### 1. Prérequis
- Système Linux / macOS / WSL
- Bash (interpréteur shell)

### 2. Rendre le script exécutable
```bash
chmod +x script.sh
```

### 3. Lancer le script
```bash
./script.sh
```

### 4. Utilisation
Le menu principal s'affiche automatiquement :
=========================================
======== MENU PRINCIPAL ==========
=========================================
1. Charger un dataset
2. Afficher statistiques du dataset
3. Supprimer lignes vides
4. Supprimer lignes non annotées
5. Supprimer doublons simples
6. Diviser en Train/Test
7. Organiser dossiers train/test
8. Générer un rapport statistique
9. Quitter
=========================================
Votre choix : _




---

Ce README est concis, couvre toutes les étapes et explique clairement comment exécuter votre script. Vous pouvez le personnaliser avec votre nom si nécessaire.