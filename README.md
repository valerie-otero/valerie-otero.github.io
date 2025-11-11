# AirMultiChrono

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
