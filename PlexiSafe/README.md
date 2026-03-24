# PlexiSafe

**Calcul de fissure sur plexiglas — iOS (Swift / SwiftUI)**

PlexiSafe est une application iOS de calcul de mécanique de la rupture linéaire élastique (MFLE) appliquée aux plaques de plexiglas. Elle permet de déterminer si une fissure existante est sûre ou critique en calculant le facteur d'intensité des contraintes K_I et en le comparant à la ténacité K_IC du matériau.

---

## Fonctionnalités

| Fonctionnalité | Détail |
|---|---|
| Mode Débutant | 5 entrées géométriques → verdict simplifié |
| Mode Expert | Accès complet à K_I, σ, Y, d_min, K_IC |
| Préréglages matériaux | PMMA standard · PMMA HR · Polycarbonate |
| Systèmes d'unités | mm/MPa/MPa√m · m/MPa/MPa√m · m/kPa/MPa√mm |
| Historique | Archivage illimité nommé et annoté |
| Export | Rapport texte partageable via UIActivityViewController |
| Localisation | FR · EN · ES · PT · ZH-Hans |
| Tip Jar | 5 niveaux de contribution (IAP via StoreKit 2) |

---

## Formule principale

```
K_I = Y · σ · √(π · a)
```

- `K_I` — facteur d'intensité des contraintes (MPa√m)
- `Y` — facteur géométrique (sans dimension, calculé selon EN 1337 ou ASTM)
- `σ` — contrainte appliquée (MPa), déduite des dimensions en mode Débutant
- `a` — demi-longueur de fissure (m)

**Critère de rupture :** `K_I ≥ K_IC`

**Taille minimale de fissure sûre :**

```
d_min = (1/π) · (K_IC / (Y · σ))²
```

---

## Architecture

```
PlexiSafe/
├── Engine/
│   └── FractureCalculator.swift      # Calculs MFLE, validation, Y-factors
├── Models/
│   ├── Diagnostic.swift              # Enum verdict (safe / warning / critical)
│   ├── HistoryStore.swift            # Persistance @AppStorage JSON
│   ├── InputData.swift               # Struct paramètres d'entrée
│   ├── MaterialPreset.swift          # Préréglages + preset personnalisé
│   ├── Results.swift                 # Struct résultats de calcul
│   └── SavedCalculation.swift        # Struct historique sérialisable
├── ViewModels/
│   └── CalculatorViewModel.swift     # @Observable, logique métier, export
└── Views/
    ├── History/
    │   ├── HistoryView.swift
    │   ├── HistoryDetailView.swift
    │   └── SaveCalculationSheet.swift
    ├── InputView/
    │   ├── BeginnerInputView.swift
    │   ├── ExpertInputView.swift
    │   └── MaterialPresetPicker.swift
    ├── Preferences/
    │   ├── PreferencesView.swift
    │   ├── UnitsSettingsView.swift    # AppSettings + conversion helpers
    │   ├── TipJarView.swift           # StoreKit 2 IAP
    │   ├── SafetyDisclaimerView.swift
    │   ├── PrivacyPolicyView.swift
    │   ├── FAQView.swift
    │   ├── TutorialsView.swift
    │   ├── LanguageSettingsView.swift
    │   └── ContactView.swift
    ├── ResultsView/
    │   ├── UnifiedResultsView.swift   # Résultats convertis en unités choisies
    │   ├── BeginnerResultsView.swift
    │   ├── ExpertResultsView.swift
    │   └── VerdictCard.swift
    └── Shared/
        ├── SliderFieldRow.swift       # Slider + champ numérique combiné
        ├── DiagnosticBadge.swift
        └── ReportView.swift
```

---

## Système d'unités

Les calculs internes s'effectuent toujours en **mm / MPa / MPa√m**. La conversion vers les unités d'affichage est appliquée au moment du rendu (proxy `Binding` dans les vues), jamais sur les données stockées.

| Paramètre | Interne | Facteur si m | Facteur si kPa |
|---|---|---|---|
| Longueurs (W, e, L, x, δ, d_min) | mm | × 0.001 | — |
| Contraintes (σ, σ_adm) | MPa | — | × 1000 |
| Ténacité (K_IC, K_I) | MPa√m | — | × √1000 ≈ 31.62 |

`AppSettings.shared` (singleton `@Observable`) expose les helpers de conversion : `lengthToDisplay`, `stressToDisplay`, `toughnessToDisplay` et les symboles correspondants.

---

## Prérequis & build

- **Xcode** 16+
- **iOS** 17+, iPhone et iPad
- **Swift** 5.10+, SwiftUI

```bash
# Build sur simulateur iPad mini A17 Pro
xcodebuild \
  -project PlexiSafe.xcodeproj \
  -scheme PlexiSafe \
  -destination 'platform=iOS Simulator,id=EFC8774A-9C87-4408-89CD-1651FD05B6EE' \
  build
```

---

## Fichiers DOCS

| Fichier | Description |
|---|---|
| `PlexiSafe_v1.html` | Démo interactive HTML de l'interface calculateur |
| `PlexiSafe_marketing.html` | Page marketing avec présentation de l'app |
| `README.md` | Ce fichier — documentation technique |
| `PlexiSafe-iOS-Swift-Prompt.md` | Prompt de développement initial |
| `plexisafe-calculator.skill` | Skill Alexa associée |
| `AppIcon.png` | Icône de l'application |

---

## Avertissement

PlexiSafe est un outil d'aide au calcul basé sur la mécanique de la rupture linéaire élastique (MFLE / LEFM). Les résultats fournis sont indicatifs et ne constituent pas un avis d'ingénierie certifié. Toute décision structurelle ou de sécurité doit être validée par un ingénieur qualifié. L'auteur décline toute responsabilité pour tout dommage résultant d'une utilisation inappropriée.

---

© 2024–2025 PlexiSafe. Tous droits réservés.
