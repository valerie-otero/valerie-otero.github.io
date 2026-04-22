# Theta Resonance

**Résonance Theta · Méditation Vibratoire**

![iOS 26+](https://img.shields.io/badge/iOS-26%2B-6c5ce7) ![visionOS 26+](https://img.shields.io/badge/visionOS-26%2B-a78bfa) ![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-F05138) ![Xcode 16+](https://img.shields.io/badge/Xcode-16%2B-147EFB)

Expérience méditative immersive basée sur la théorie vibratoire de la conscience. L'app génère des signaux audio en temps réel (battements binauraux, vibration aorte, tons isochroniques, stimulation gamma 40 Hz) et les accompagne de plus de 50 visualisations animées.

---

## Architecture

| Composant | Technologie |
|---|---|
| Audio temps réel | `AVAudioEngine` — buffers PCM, continuité de phase, 4 modes |
| État réactif | `@Observable` (Swift 6 strict concurrency) |
| Visualisations | `Canvas` + `TimelineView(.animation)` |
| Immersif visionOS | `RealityKit` — tore procédural, `ParticleEmitterComponent` |
| Audio spatial | `SpatialAudioComponent` |
| Haptique | `CoreHaptics` |
| Localisation | Dictionnaire intégré FR/EN |

## Structure du projet

```
Theta Resonance/
├── ThetaResonanceApp.swift       → Point d'entrée, injection @Environment
├── ContentView.swift           → Interface principale
├── AudioManager.swift          → Moteur AVAudioEngine (binaural, AM, isochronique, gamma 40 Hz)
├── EnergyScreenSaverView.swift → 50+ modes visuels (Canvas)
├── ToreImmersiveView.swift     → Espace immersif visionOS (RealityKit 3D)
├── HapticManager.swift         → Retour haptique CoreHaptics
├── LanguageManager.swift       → Gestion FR/EN in-app
└── Assets.xcassets/            → Icône d'app, couleur d'accentuation
```

## Modes audio

### Battements Binauraux
Porteuse à 150 Hz oreille gauche, 150 + Δf Hz oreille droite. Le cerveau perçoit un battement à Δf = fréquence theta. Nécessite un casque stéréo.

### Vibration Aorte
Porteuse à 55 Hz (sous-basse) modulée en amplitude à la fréquence theta. Reproduit la micro-vibration aortique décrite dans la théorie vibratoire de la conscience.

### Tons Isochroniques
Porteuse à 200 Hz pulsée à θ Hz avec enveloppe lissée. Fonctionne sans casque.

### Stimulation Gamma 40 Hz
Porteuse à 400 Hz pulsée à 40 Hz avec enveloppe lissée. Associée à la concentration, la clarté mentale et la mémoire de travail. Trois niveaux d'intensité (Douce / Moyenne / Forte). Mode 100 % audio — casque recommandé.

## Rampe Alpha → Θ

Descente progressive de la fréquence alpha (10 Hz) vers la fréquence theta cible sur 5, 10, 20 ou 30 minutes. Guide naturellement les ondes cérébrales vers l'état méditatif profond.

## Visualisations (50+ modes)

- **Classiques (20)** : Tore d'Énergie, Respiration Cosmique, Géométrie Sacrée, Champ Neural, Interférence d'Ondes, Vortex Spiral, Champ d'Étoiles, Onde Pendulaire, Aurore, Champ Quantique, Réseau Cristallin, Mandala Cosmique, Océan Profond, Hélice ADN, Lignes Magnétiques, Lissajous, Toile Cosmique, Encre Fluide, Tesseract, Rosetta Bloom
- **Stéréo 3D (11)** : Champ, Nébula, Tunnel, Orbes, Vagues, Spirale, Matrice, Réseau, Lucioles, Ondulations, Prisme
- **Pendulaires (11)** : Balancier, Double Pendule, Réseau d'ondes, Foucault, Ressort, Couplés, Conique, Horloge, Magnétique, Galaxie, Harmonique
- **Organiques (10)** : Marée Lunaire, Lotus Respirant, Arc Solaire, Ondulation Horizon, Trace Infini, Méduse Cosmique, Résonance de Cordes, Spirale Dorée, Dérive Nébuleuse, Pulsation Cardiaque

## Sécurité

- **Photo-épilepsie** : toutes les oscillations visuelles < 0,1 Hz (seuil de risque : 3 Hz)
- **Audition** : volume plafonné à 0,85 (−3 dBFS)
- **Vie privée** : aucune donnée collectée, pas de réseau, pas de tracking

## visionOS — Espace Immersif

Tore cosmique 3D procédural avec :
- Effet stéréo cross-eye (deux groupes d'entités avec décalage de phase)
- Animation pendulaire physique — `θ(t) = θmax·sin(2π·t/T)`
- Système de particules (étoiles scintillantes + glow orbital)
- Audio spatial attaché au tore (`SpatialAudioComponent`)
- Éclairage réactif via `PointLightComponent`

## Prérequis

- Xcode 16+
- iOS 26+ / visionOS 26+
- Swift 5.9+

## Build

```bash
git clone <repo-url>
cd "Theta Resonance"
open "Theta Resonance.xcodeproj"
# Sélectionner le scheme "Theta Resonance" → Run (⌘R)
```

## Licence

© 2026 Valérie Otero. Tous droits réservés.
