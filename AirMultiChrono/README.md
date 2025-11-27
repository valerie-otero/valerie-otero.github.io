# AirMultiChrono

**Version 1.1**

Chronomètre multi-voies simple, puissant et fiable pour iPhone et iPad. Conçu pour les usages où plusieurs chronos indépendants et un cumulatif global sont utiles — notamment en aviation de loisir (gestion des réservoirs, branches de navigation, points d’origine/DCT, attentes), mais aussi pour le sport, la cuisine, les ateliers, ou toute activité nécessitant plusieurs temporisations parallèles.


## Points forts

- Jusqu’à 3 chronos principaux + 1 totalisateur global
- Dispositions adaptables: Triangle, Grille, ou Libre (drag & drop)
- Redimensionnement précis (pincement avec stabilisation, pas de 0,01/0,02)
- Alarmes visuelles et sonores par piste, avec répétition jusqu’à arrêt
- Choix de sons système intégrés avec pré-écoute (pas d’ID numériques visibles)
- Styles personnalisables (forme, bordure, échelle des chiffres, couleur, nom)
- Verrouillage de remise à zéro (sécurité anti-fausses manips)
- État persistant (positions, tailles, styles, alarmes, sons)
- iPhone et iPad, portrait/paysage, iOS 16+


## Cas d’usage en aviation de loisir (VFR)

Avertissement: AirMultiChrono est un outil d’assistance. Il ne remplace pas les procédures officielles, instruments certifiés, ou la vigilance du pilote. Vérifiez la réglementation en vigueur et gardez des marges.

- Gestion d’utilisation des réservoirs
  - Définissez un chrono par réservoir (L, R). Démarrez/Lancez la piste correspondante lors du basculement. Ajoutez une alarme répétée (ex. toutes 30 min) pour vous rappeler d’alterner.
  - Le totalisateur global suit le temps de vol cumulé/mission.
- Chronométrage d’une branche de navigation
  - Démarrez une piste “Branche N” au passage d’un point d’origine. Mettez une alarme à l’ETA planifiée pour déclencher un rappel (son+visuel) au point d’arrivée de branche.
- Point d’origine / DCT / TOT
  - Utilisez une piste dédiée pour le temps écoulé depuis un point de report ou un TOT (time over target). Réglage d’alarme absolue (ex. +7 min) ou en mode répété selon votre usage.
- Attente (holding)
  - Chrono par tour d’attente (1 min/1 minute 30, selon vent). Répétition d’alarme pour guider les virages et sorties en sécurité.
- Phases et check-lists
  - Petite alarme pour “mise en route → roulage”, “alignement → montée”, “palier → croisière”, “descente → intégration”. Les rappels sonores répétitifs vous évitent d’oublier.

Astuce: renvoyez les noms de pistes (ex. “L”, “R”, “BR1”, “DCT Ouest”) pour une lecture immédiate en cockpit.


## Autres usages

- Sport (intervalles, circuits, récupération)
- Cuisine (plusieurs cuissons simultanées + total global)
- Ateliers/formation (temps par groupe + macro)
- Laboratoire/expériences (étapes parallèles + alarme)


## Prise en main rapide

- Démarrer/Arrêter un chrono: touchez ON/OFF.
- Renommer: touchez le nom pour ouvrir la boîte de renommage.
- Disposition: via le menu, choisissez Triangle, Grille ou Libre.
- Mode Édition (Libre):
  - Déplacer un cadran: glisser-déposer.
  - Redimensionner un cadran: pincer; la taille est stabilisée (deadzone ~1,5%, lissage, pas 0,01). Relâchement = petit “snap” propre.
- Totalisateur global:
  - Pincer pour ajuster l’échelle (stabilisé, plage 0,5–3,0, pas 0,02).
  - Bouton “stylo” pour régler au pas fin si besoin.
- Styles (par piste): forme (rond/carré), bordure, échelle des chiffres, couleur, échelle du nom.
- Verrou “reset”: empêche la remise à zéro accidentelle.

Tout est enregistré automatiquement (positions, tailles, styles, alarmes, sons, échelle globale).


## Alarmes (par piste)

- Types: visuelle (flash) et sonore (sons système iOS)
- Pré-écoute: choisissez un son et testez-le immédiatement
- Répétition: le son se répète tant que l’alarme est “latchée” (jusqu’à OFF ou changement de chrono)
- Modes de déclenchement:
  - Absolu: alarme à t = valeur (ex. 00:07:00)
  - Répétée/offset: alarme qui se relance par intervalle
- Arrêt: OFF de la piste ou changement de chrono stoppe l’alarme et le son


## Gestes et précision (important)

- Pincement stabilisé: nous appliquons un delta progressif, une zone morte (~1,5%), une sensibilité adoucie et un lissage, plus un “snap” par pas (cadrans: 0,01; total: 0,02). Le but: des ajustements fluides, sans “sauts”.
- Plages:
  - Cadrans: 0,20 – 0,60 du côté court de l’écran (en mode Libre)
  - Totalisateur: 0,50 – 3,00


## Confidentialité et données

- Aucune collecte de données personnelles.
- Aucun suivi. Pas d’accès réseau requis pour fonctionner.
- Politique de confidentialité (FR/EN):
  - Web: <https://valerie-otero.github.io/AirMultiChrono/PrivacyPolicy.html> (la langue suit celle de l’app: ?lang=fr|en)
  - In-app: rubrique “Confidentialité”, avec lien direct et bouton “copier”.


## Compatibilité

- iOS 16 ou supérieur
- iPhone et iPad, portrait & paysage


## Conseils sécurité (aviation)

- Outil d’assistance non certifié: ne remplace ni l’horloge de bord, ni les instruments, ni les procédures de la checklist.
- Conservez des marges temps/carburant, vérifiez les temps critiques avec une source secondaire.
- Restez à l’écoute des fréquences et de la trajectoire; ne laissez pas un écran détourner l’attention.


## Dépannage rapide (FAQ)

- Je ne vois plus la bascule FR/EN de la politique dans l’app: l’app ouvre désormais la page Web dans la langue de l’OS, et affiche le lien (avec bouton copier).
- Les vibrations n’existent pas? Oui, le mode haptique a été retiré. Utilisez les sons système.
- Le son ne s’arrête pas: il se répète tant que l’alarme visuelle est active; passez OFF ou changez de chrono.
- Le pincement “saute”: le lissage est actif; relâchez pour un snap propre au pas fin. Dites-nous si vous voulez une sensibilité différente.


## Développement (pour contributeurs)

- Ouvrir `AirMultiChrono.xcodeproj` dans Xcode (iOS 16+ SDK)
- Cible: iPhone/iPad (SwiftUI)
- Son: AudioServices (sons système) + lecture .caf embarqué en secours
- Structure principale:
  - `AirMultiChrono/ChronoView.swift` (UI, gestes, mises en page, totalisateur)
  - `AirMultiChrono/ChronoModel.swift` (état, persistance, alarmes)
  - `AirMultiChrono/PrivacyPolicyView.swift` (lien Web + copie)
  - `docs/PrivacyPolicy.html` (police FR/EN publique)
- Captures: dossier `Screenshots/` (génération via `scripts/`)


## Licence et contact

- Voir la politique de confidentialité ci-dessus.
- Support: ouvrez une “Issue” GitHub pour bugs/suggestions.

Bon vol — et bonne maîtrise du temps !

---

# AirMultiChrono (English)

Simple, powerful, and reliable multi-track stopwatch for iPhone and iPad. Designed for uses where multiple independent timers and a global cumulative timer are useful — particularly in recreational aviation (fuel tank management, navigation legs, origin points/DCT, holding patterns), but also for sports, cooking, workshops, or any activity requiring multiple parallel timings.


## Highlights

- Up to 3 main timers + 1 global totalizer
- Adaptable layouts: Triangle, Grid, or Free (drag & drop)
- Precise resizing (pinch with stabilization, no 0.01/0.02 jitter)
- Visual and sound alarms per track, repeating until stopped
- Choice of built-in system sounds with preview (no visible numeric IDs)
- Customizable styles (shape, border, digit scale, color, name)
- Reset lock (protection against accidental resets)
- Persistent state (positions, sizes, styles, alarms, sounds)
- iPhone and iPad, portrait/landscape, iOS 16+


## Use Cases in Recreational Aviation (VFR)

Warning: AirMultiChrono is an assistance tool. It does not replace official procedures, certified instruments, or pilot vigilance. Check applicable regulations and keep margins.

- Fuel Tank Management
  - Define one timer per tank (L, R). Start/Launch the corresponding track when switching. Add a repeating alarm (e.g., every 30 min) to remind you to switch.
  - The global totalizer tracks cumulative flight/mission time.
- Navigation Leg Timing
  - Start a "Leg N" track when passing an origin point. Set an alarm at the planned ETA to trigger a reminder (sound+visual) at the leg arrival point.
- Origin Point / DCT / TOT
  - Use a dedicated track for elapsed time since a reporting point or TOT (time over target). Absolute alarm setting (e.g., +7 min) or repeating mode depending on your usage.
- Holding
  - Timer per holding turn (1 min/1 minute 30, depending on wind). Alarm repetition to guide turns and exits safely.
- Phases and Checklists
  - Short alarm for "startup → taxi", "alignment → climb", "level → cruise", "descent → integration". Repetitive sound reminders prevent forgetting.

Tip: Rename track names (e.g., "L", "R", "BR1", "DCT West") for immediate reading in the cockpit.


## Other Uses

- Sports (intervals, circuits, recovery)
- Cooking (multiple simultaneous cooking times + global total)
- Workshops/Training (time per group + macro)
- Laboratory/Experiments (parallel steps + alarm)


## Quick Start

- Start/Stop a timer: tap ON/OFF.
- Rename: tap the name to open the rename box.
- Layout: via the menu, choose Triangle, Grid, or Free.
- Edit Mode (Free):
  - Move a dial: drag and drop.
  - Resize a dial: pinch; size is stabilized (deadzone ~1.5%, smoothing, no 0.01). Release = clean small "snap".
- Global Totalizer:
  - Pinch to adjust scale (stabilized, range 0.5–3.0, step 0.02).
  - "Pencil" button to adjust with fine steps if needed.
- Styles (per track): shape (round/square), border, digit scale, color, name scale.
- "Reset" Lock: prevents accidental reset.

Everything is saved automatically (positions, sizes, styles, alarms, sounds, global scale).


## Alarms (per track)

- Types: visual (flash) and sound (iOS system sounds)
- Preview: choose a sound and test it immediately
- Repetition: sound repeats as long as the alarm is "latched" (until OFF or timer change)
- Trigger Modes:
  - Absolute: alarm at t = value (e.g., 00:07:00)
  - Repeated/Offset: alarm that restarts by interval
- Stop: OFF on the track or changing timer stops the alarm and sound


## Gestures and Precision (Important)

- Stabilized Pinch: we apply a progressive delta, a deadzone (~1.5%), smoothed sensitivity, and smoothing, plus a "snap" per step (dials: 0.01; total: 0.02). The goal: fluid adjustments without "jumps".
- Ranges:
  - Dials: 0.20 – 0.60 of the screen's short side (in Free mode)
  - Totalizer: 0.50 – 3.00


## Privacy and Data

- No personal data collection.
- No tracking. No network access required to function.
- Privacy Policy (FR/EN):
  - Web: <https://valerie-otero.github.io/AirMultiChrono/PrivacyPolicy.html> (language follows app: ?lang=fr|en)
  - In-app: "Privacy" section, with direct link and "copy" button.


## Compatibility

- iOS 16 or higher
- iPhone and iPad, portrait & landscape


## Safety Tips (Aviation)

- Non-certified assistance tool: does not replace the onboard clock, instruments, or checklist procedures.
- Keep time/fuel margins, verify critical times with a secondary source.
- Stay tuned to frequencies and trajectory; do not let a screen distract attention.


## Quick Troubleshooting (FAQ)

- I don't see the FR/EN toggle for the policy in the app anymore: the app now opens the Web page in the OS language, and displays the link (with copy button).
- Do vibrations exist? Yes, but haptic mode has been removed in favor of system sounds.
- The sound doesn't stop: it repeats as long as the visual alarm is active; switch OFF or change timer.
- The pinch "jumps": smoothing is active; release for a clean snap at the fine step. Let us know if you want different sensitivity.


## Development (for contributors)

- Open `AirMultiChrono.xcodeproj` in Xcode (iOS 16+ SDK)
- Target: iPhone/iPad (SwiftUI)
- Sound: AudioServices (system sounds) + embedded .caf playback as backup
- Main Structure:
  - `AirMultiChrono/ChronoView.swift` (UI, gestures, layouts, totalizer)
  - `AirMultiChrono/ChronoModel.swift` (state, persistence, alarms)
  - `AirMultiChrono/PrivacyPolicyView.swift` (Web link + copy)
  - `docs/PrivacyPolicy.html` (public FR/EN font)
- Screenshots: `Screenshots/` folder (generation via `scripts/`)


## License and Contact

- See privacy policy above.
- Support: open a GitHub "Issue" for bugs/suggestions.

Have a good flight — and good time mastery!
