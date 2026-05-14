# CapRoute

**Préparation de navigation VFR — iPhone & iPad**

CapRoute est une application iOS native (SwiftUI / SwiftData / iCloud) destinée aux pilotes privés. Elle calcule, pour chaque branche d'une navigation VFR, la chaîne complète **Rv → Rm → Cv → Cm → Cc**, la dérive subie, la correction de cap, la vitesse sol (GS) et le temps de vol — à partir du vent, de la TAS, de la déclinaison magnétique et de la déviation compas.

> ⚠️ CapRoute est une aide à la préparation. Elle ne remplace pas un log de navigation papier, un EFB officiel ni un briefing météo. La responsabilité finale incombe au commandant de bord.

---

## Fonctionnalités

- **Multi-branches** : chaque tronçon a son cap, sa distance, son temps. Totaux automatiques.
- **Calcul vent complet** : composante traversière → WCA, composante face/arrière → GS.
- **Matrice Route/Cap × Vrai/Mag/Comp** lisible en un coup d'œil.
- **Rose des Nords pédagogique** : Rv, Rm, Cv, Cc, vent, dérive — visualisés simultanément.
- **Export PDF A4** prêt à glisser dans un kneeboard, généré localement.
- **Inversion 1-tap** pour la nav retour.
- **iCloud (CloudKit)** : navs synchronisées entre vos appareils. Suppression locale ou globale au choix.
- **FR / EN** : interface entièrement localisée.

## Pile technique

| Couche | Technologie |
|---|---|
| UI | SwiftUI |
| Persistance | SwiftData + CloudKit |
| Concurrence | Swift 6 (strict) |
| Cible minimale | iOS 17.0 |
| Rendu PDF | `UIGraphicsPDFRenderer` + `ImageRenderer` |
| Tests | XCTest (`NavigationScenarioTests`) |

## Confidentialité

CapRoute **ne collecte aucune donnée personnelle**. Toutes vos navigations restent sur vos appareils et, si vous l'activez, dans votre propre conteneur iCloud privé. Aucun tracker, aucune analytics, aucun compte tiers.

→ Voir [`privacy.html`](privacy.html)

## Liens

- Page produit : [`index.html`](index.html)
- Politique de confidentialité : [`privacy.html`](privacy.html)
- Icônes App Store : dossier [`AppIcon/`](AppIcon/)

## Auteur

Valérie Otero — 2026
