# Theta Resonance

**Résonance Theta · Méditation Vibratoire** — *Theta Resonance · Vibratory Meditation*

![iOS 26+](https://img.shields.io/badge/iOS-26%2B-6c5ce7) ![visionOS 26+](https://img.shields.io/badge/visionOS-26%2B-a78bfa) ![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-F05138) ![Xcode 16+](https://img.shields.io/badge/Xcode-16%2B-147EFB)

🇫🇷 **[Français](#français)** · 🇬🇧 **[English](#english)**

---

<a id="français"></a>
## 🇫🇷 Français

Expérience méditative immersive basée sur la théorie vibratoire de la conscience. L'app génère des signaux audio en temps réel (battements binauraux, vibration aorte, tons isochroniques, stimulation gamma 40 Hz) et les accompagne de plus de 50 visualisations animées.

### Architecture

| Composant | Technologie |
|---|---|
| Audio temps réel | `AVAudioEngine` — buffers PCM, continuité de phase, 4 modes |
| État réactif | `@Observable` (Swift 6 strict concurrency) |
| Visualisations | `Canvas` + `TimelineView(.animation)` |
| Immersif visionOS | `RealityKit` — tore procédural, `ParticleEmitterComponent` |
| Audio spatial | `SpatialAudioComponent` |
| Haptique | `CoreHaptics` |
| Localisation | Dictionnaire intégré FR/EN |

### Structure du projet

```
Theta Resonance/
├── ThetaResonanceApp.swift     → Point d'entrée, injection @Environment
├── ContentView.swift           → Interface principale
├── AudioManager.swift          → Moteur AVAudioEngine (binaural, AM, isochronique, gamma 40 Hz)
├── EnergyScreenSaverView.swift → 50+ modes visuels (Canvas)
├── ToreImmersiveView.swift     → Espace immersif visionOS (RealityKit 3D)
├── HapticManager.swift         → Retour haptique CoreHaptics
├── LanguageManager.swift       → Gestion FR/EN in-app
└── Assets.xcassets/            → Icône d'app, couleur d'accentuation
```

### Modes audio

- **Battements Binauraux** — porteuse 150 Hz gauche / 150 + Δf Hz droite. Nécessite un casque stéréo.
- **Vibration Aorte** — porteuse 55 Hz modulée en amplitude à la fréquence theta.
- **Tons Isochroniques** — porteuse 200 Hz pulsée à θ Hz. Fonctionne sans casque.
- **Stimulation Gamma 40 Hz** — porteuse 400 Hz pulsée à 40 Hz. Trois niveaux (Douce / Moyenne / Forte). Casque recommandé.

### Rampe Alpha → Θ

Descente progressive de 10 Hz (alpha) vers la fréquence theta cible sur 5, 10, 20 ou 30 minutes.

### Visualisations (50+ modes)

- **Classiques (20)** : Tore d'Énergie, Respiration Cosmique, Géométrie Sacrée, Champ Neural, Interférence d'Ondes, Vortex Spiral, Champ d'Étoiles, Onde Pendulaire, Aurore, Champ Quantique, Réseau Cristallin, Mandala Cosmique, Océan Profond, Hélice ADN, Lignes Magnétiques, Lissajous, Toile Cosmique, Encre Fluide, Tesseract, Rosetta Bloom
- **Stéréo 3D (11)** : Champ, Nébula, Tunnel, Orbes, Vagues, Spirale, Matrice, Réseau, Lucioles, Ondulations, Prisme
- **Pendulaires (11)** : Balancier, Double Pendule, Réseau d'ondes, Foucault, Ressort, Couplés, Conique, Horloge, Magnétique, Galaxie, Harmonique
- **Organiques (10)** : Marée Lunaire, Lotus Respirant, Arc Solaire, Ondulation Horizon, Trace Infini, Méduse Cosmique, Résonance de Cordes, Spirale Dorée, Dérive Nébuleuse, Pulsation Cardiaque

### Sécurité

- **Photo-épilepsie** : toutes les oscillations visuelles < 0,1 Hz (seuil de risque : 3 Hz)
- **Audition** : volume plafonné à 0,85 (−3 dBFS)
- **Vie privée** : aucune donnée collectée, pas de réseau, pas de tracking

### visionOS — Espace Immersif

Tore cosmique 3D procédural avec effet stéréo cross-eye, animation pendulaire physique — `θ(t) = θmax·sin(2π·t/T)`, système de particules (étoiles + glow orbital), audio spatial (`SpatialAudioComponent`) et éclairage réactif (`PointLightComponent`).

### Prérequis

- Xcode 16+
- iOS 26+ / visionOS 26+
- Swift 5.9+

### Build

```bash
git clone <repo-url>
cd "Theta Resonance"
open "Theta Resonance.xcodeproj"
# Sélectionner le scheme "Theta Resonance" → Run (⌘R)
```

### Licence

© 2026 Valérie Otero. Tous droits réservés.

---

<a id="english"></a>
## 🇬🇧 English

Immersive meditative experience based on the vibratory theory of consciousness. The app generates real-time audio signals (binaural beats, aortic vibration, isochronic tones, gamma 40 Hz stimulation) accompanied by more than 50 animated visualizations.

### Architecture

| Component | Technology |
|---|---|
| Real-time audio | `AVAudioEngine` — PCM buffers, phase continuity, 4 modes |
| Reactive state | `@Observable` (Swift 6 strict concurrency) |
| Visualizations | `Canvas` + `TimelineView(.animation)` |
| visionOS immersive | `RealityKit` — procedural torus, `ParticleEmitterComponent` |
| Spatial audio | `SpatialAudioComponent` |
| Haptics | `CoreHaptics` |
| Localization | Built-in FR/EN dictionary |

### Project structure

```
Theta Resonance/
├── ThetaResonanceApp.swift     → Entry point, @Environment injection
├── ContentView.swift           → Main interface
├── AudioManager.swift          → AVAudioEngine core (binaural, AM, isochronic, gamma 40 Hz)
├── EnergyScreenSaverView.swift → 50+ visual modes (Canvas)
├── ToreImmersiveView.swift     → visionOS immersive space (RealityKit 3D)
├── HapticManager.swift         → CoreHaptics feedback
├── LanguageManager.swift       → In-app FR/EN handling
└── Assets.xcassets/            → App icon, accent color
```

### Audio modes

- **Binaural Beats** — 150 Hz carrier left / 150 + Δf Hz right. Requires stereo headphones.
- **Aorta Vibration** — 55 Hz carrier amplitude-modulated at theta frequency.
- **Isochronic Tones** — 200 Hz carrier pulsed at θ Hz. Works without headphones.
- **Gamma 40 Hz Stimulation** — 400 Hz carrier pulsed at 40 Hz. Three levels (Low / Medium / High). Headphones recommended.

### Alpha → Θ Ramp

Gradual descent from 10 Hz (alpha) to the target theta frequency over 5, 10, 20 or 30 minutes.

### Visualizations (50+ modes)

- **Classic (20)**: Torus Energy, Cosmic Breath, Sacred Geometry, Neural Field, Wave Interference, Spiral Vortex, Starfield, Pendulum Wave, Aurora, Quantum Field, Crystal Lattice, Cosmic Mandala, Deep Ocean, DNA Helix, Magnetic Lines, Lissajous, Cosmic Web, Fluid Ink, Tesseract, Rosetta Bloom
- **Stereo 3D (11)**: Field, Nebula, Tunnel, Orbs, Waves, Spiral, Matrix, Lattice, Fireflies, Ripples, Prism
- **Pendulum (11)**: Swing, Double Pendulum, Wave Array, Foucault, Spring, Coupled, Conical, Clock, Magnetic, Galaxy, Harmonic
- **Organic (10)**: Moon Tide, Breathing Lotus, Solar Arch, Horizon Ripple, Infinity Trace, Cosmic Jellyfish, String Resonance, Golden Unfurl, Nebula Drift, Heart Pulse

### Safety

- **Photosensitive epilepsy**: all visual oscillations < 0.1 Hz (risk threshold: 3 Hz)
- **Hearing**: volume capped at 0.85 (−3 dBFS)
- **Privacy**: no data collected, no network, no tracking

### visionOS — Immersive Space

Procedural 3D cosmic torus with cross-eye stereo effect, physical pendulum animation — `θ(t) = θmax·sin(2π·t/T)`, particle system (stars + orbital glow), spatial audio (`SpatialAudioComponent`) and reactive lighting (`PointLightComponent`).

### Requirements

- Xcode 16+
- iOS 26+ / visionOS 26+
- Swift 5.9+

### Build

```bash
git clone <repo-url>
cd "Theta Resonance"
open "Theta Resonance.xcodeproj"
# Select the "Theta Resonance" scheme → Run (⌘R)
```

### License

© 2026 Valérie Otero. All rights reserved.
