# 📊 Dashboard Commercial avec R Shiny

Un tableau de bord interactif, réactif et prêt à l'emploi développé en **R** avec **Shiny** et **shinydashboard**. Ce projet permet de visualiser et d'analyser facilement des données commerciales telles que les ventes, les profits, les régions et les catégories de produits.

## ✨ Fonctionnalités

- **Générateur de données intégré** : Le script inclut la génération de données commerciales fictives pour tester l'application instantanément.
- **Filtres interactifs** : Filtrage dynamique par période (dates), par région et par catégorie.
- **Indicateurs clés (KPIs)** : Affichage du Chiffre d'Affaires total, de la Marge Générée et du Nombre de commandes.
- **Visualisations graphiques (ggplot2)** :
  - Courbe de tendance mensuelle des ventes.
  - Diagramme à barres horizontales des ventes par catégorie.
  - Diagramme à barres de la répartition des ventes par région.
- **Tableau de bord de données brutes (DT)** : Un onglet dédié affichant les transactions sous forme de tableau interactif (tri, recherche, pagination).

## 🛠️ Prérequis

Assurez-vous d'avoir installé **R** et **RStudio**.
Avant d'exécuter l'application, vous devez installer les packages nécessaires. Exécutez la commande suivante dans votre console R :

```R
install.packages(c("shiny", "shinydashboard", "ggplot2", "dplyr", "DT", "lubridate"))
```

## 🚀 Installation et Utilisation

1. Clonez ce dépôt sur votre machine locale ou téléchargez le fichier `app.R`.
2. Ouvrez le fichier `app.R` dans RStudio.
3. Cliquez sur le bouton **"Run App"** en haut à droite de l'éditeur de code dans RStudio, ou exécutez la commande suivante dans la console :

```R
shiny::runApp("chemin/vers/le/dossier/du/projet")
```

## 📁 Utiliser vos propres données

Par défaut, l'application utilise un jeu de données fictif généré aléatoirement (`set.seed(123)`). Pour utiliser vos propres données commerciales, modifiez la **PARTIE 1** du fichier `app.R`.

Remplacez le bloc de génération de données par l'importation de votre propre fichier CSV :

```R
# Exemple d'importation d'un fichier CSV
data_ventes <- read.csv("chemin/vers/votre/fichier/ventes.csv", sep=";")

# Assurez-vous que la colonne Date est bien formatée
data_ventes$Date <- as.Date(data_ventes$Date, format="%Y-%m-%d")

# Optionnel : Créer la colonne 'Mois' requise par le graphique de tendance
data_ventes$Mois <- floor_date(data_ventes$Date, "month")
```

**Format attendu pour le fichier de données :**
Le DataFrame `data_ventes` doit contenir au minimum les colonnes suivantes :
- `Date` (Format Date)
- `Categorie` (Texte)
- `Region` (Texte)
- `Ventes` (Numérique)
- `Profit` (Numérique)

## 🏗️ Structure de l'application (app.R)

Le code est divisé en 4 sections principales :
1. **Génération / Importation des données** : Préparation du jeu de données initial.
2. **Interface Utilisateur (UI)** : Définition de l'agencement visuel avec `dashboardPage` (En-tête, Barre latérale avec filtres, Corps avec onglets et graphiques).
3. **Logique Serveur (Server)** : Fonctions de filtrage réactif (`reactive`) et rendu des composants (`renderValueBox`, `renderPlot`, `renderDT`).
4. **Lancement de l'application** : Appel de la fonction `shinyApp()`.

