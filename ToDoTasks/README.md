# ToDoTasks

**ToDoTasks** est une application de gestion de tâches simple, élégante et efficace pour macOS. Conçue pour vous aider à organiser votre quotidien, elle permet de gérer plusieurs listes de tâches (Travail, Personnel, Courses, etc.) dans une interface claire et intuitive.

![App Icon](../TodoList/Assets.xcassets/AppIcon.appiconset/Icon-1024.png)

## Fonctionnalités Principales

*   **Gestion Multi-Listes** : Créez autant de listes que nécessaire (ex: "Travail", "Maison", "Projets") via la barre latérale.
*   **Interface Intuitive** : Cochez vos tâches pour les marquer comme terminées.
*   **Mode Sombre & Clair** : Basculez facilement entre le thème clair et sombre selon vos préférences.
*   **Horloge Intégrée** : Gardez un œil sur l'heure avec une horloge analogique élégante intégrée à l'interface.
*   **Import / Export** :
    *   Importez vos tâches depuis des fichiers `.txt` ou `.csv`.
    *   Exportez vos listes en `.txt`, `.csv` ou `.md` (Markdown).
*   **Localisation** : Disponible entièrement en Français et en Anglais.
*   **Tip Jar** : Soutenez le développement de l'application via des achats intégrés (In-App Purchase).

## Prérequis Système

*   **macOS** : Version 14.6 ou ultérieure.
*   **Architecture** : Compatible Apple Silicon (M1/M2/M3) et Intel.

## Installation

1.  Téléchargez la dernière version de l'application.
2.  Glissez `ToDoTasks.app` dans votre dossier `Applications`.
3.  Lancez l'application depuis le Launchpad ou Spotlight.

## Utilisation

### Gestion des Listes
*   **Créer une liste** : Cliquez sur le bouton `+` dans la barre d'outils ou utilisez le menu contextuel.
*   **Renommer/Supprimer** : Faites un clic droit sur une liste dans la barre latérale.

### Gestion des Tâches
*   **Ajouter** : Utilisez le bouton `+` ou le raccourci clavier. Vous pouvez ajouter plusieurs tâches d'un coup en les séparant par un point-virgule `;`.
*   **Nettoyer** : Le bouton `∆` supprime toutes les tâches cochées de la liste active.
*   **Tout effacer** : Le bouton `Ø` vide entièrement la liste active.

## Développement

Ce projet est développé en **Swift** avec **SwiftUI**.

*   **Architecture** : MVVM (Model-View-ViewModel).
*   **Persistance** : Système de fichiers local (JSON/TXT) pour une portabilité maximale.
*   **StoreKit 2** : Intégration native pour les dons (Tip Jar).

## Auteur

Développé avec ❤️ par **Valérie Otero**.
*   **Email** : valerie.otero@free.fr
*   **Confidentialité** : [Politique de Confidentialité](https://valerie-otero.github.io/ToDoTasks/PrivacyPolicy.html)

---
*Copyright © 2025 Valérie Otero. Tous droits réservés.*
