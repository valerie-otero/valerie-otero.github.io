# Règle de navigation du Cne Claude — Plan de refonte des pages + monographie

*Établi le 22/07/2026 après dépouillement du dossier `../RdN_Cne_Claude/` (workflow 9 agents : notice ×2, scans, photos ×2, audits ×2, gabarit monographie, recoupement adversarial) + 3 contre-vérifications macro manuelles. Complète et débloque `REGLE_VIRTUELLE_transition.md`.*

---

## 0. Les sources nouvelles

| Fichier | Nature | Verdict |
|---|---|---|
| `mode emploi règle Fouga.pdf` (13 p.) | **Notice d'origine** : chapitre 4 d'un cours d'escadron dactylographié, « LA REGLE DE NAVIGATION », § 4.3 « LA REGLE DE NAVIGATION DU CAPITAINE CLAUDE ». Description officielle + **11 procédures a)–k)** avec exemples chiffrés, illustrées de photocopies de la règle réelle. | Source de terminologie et de procédures. |
| `règle Fouga.pdf` (2 p.) | **Scans A4 flatbed 300 dpi** avec réglet 30 cm dans le cadre : corps seul (coulisse retirée) + coulisse à plat, recto puis verso. Métriquement fiables (1 mm = 11,8 px vérifié), zéro parallaxe, module log mesuré **104,5 mm/décade**. | **Ce sont les clichés attendus par `REGLE_VIRTUELLE_transition.md` §C** → transition « règle complète » débloquée. |
| `IMG_3701–3704.HEIC` | Photos HD (4032 px) : coulisse recto (3701), coulisse verso (3702), corps recto (3703), corps verso (3704). | Lecture macro des valeurs fines ; tranchent les points ouverts du 18/07. |

Extraits de travail (crops HD, scans redressés) : scratchpad session `…/scratchpad/rdn/` et `…/scratchpad/regle/`.

## 1. Données tranchées (vérifiées, avec arbitrage des lectures divergentes)

1. **Anatomie : deux éléments seulement** — « une partie fixe formant le corps » + « une réglette coulissante » (notice 4.3.1). **Pas de curseur indépendant** : l'abaque de vent (« représentation graphique du calcul K ») est solidaire du corps. Il n'existe **pas de « position de repos »** des fenêtres.
2. **Correction Pb, colonne Marboré VI : − 0,5 l/m CONFIRMÉ** (zoom scan 300 dpi : « 5 » à barre plate identique dans les deux colonnes ; concorde avec les relectures aveugles du 18/07 sur une troisième capture). La lecture « − 0,8 » faite indépendamment par deux lecteurs sur la photo IMG_3703 est un **artefact de la zone abîmée** (brunissures + flou au coin Pb) — aucune correction à faire sur le site. Leçon : sur cette cellule, seule la majorité multi-captures fait foi.
3. **Réglette coulisse verso 1/100 000 = 280 kts** (notice p. 2 + scan + géométrie photo : 1′ ≈ 4,6 NM, 1′15 ≈ 5,8 NM, 1′30 = 7 NM → 4,67 NM/min). La lecture « 200 kts » d'un des lecteurs est réfutée. 1/500 000 = 240 kts avec échelle de temps 0→12 min (graduée 15 s).
4. **Fréquences de la carte de France : 383,7 / 384,5 / 384,7** (scan 300 dpi sans ambiguïté) ; niveaux refuge **FL 55 (nord/ouest) et FL 115 (est/sud) uniquement** — pas de FL 95.
5. **Carburant aux sommets Marboré II : gravé** — Pb 550 L (FL250, 20′), Gb 720 L (FL250, 24′). Sommets VI : 660 L (Pb FL300, 17′) / 840 L (Gb FL300, 20′). Point ouvert n°1 du 18/07 : clos.
6. **Cotes FL50 : deux cercles seulement** (3′ = VI-Pb prouvé par la cote 6 NM ; 4′ = attribution II-Pb favorisée par la géométrie, à formuler prudemment). Point ouvert n°2 : clos.
7. **Abaque de montée entièrement élucidé** : axe horizontal = **distance en NM** (bord haut = VI, bord bas = II), 4 courbes Pb/Gb, cotes temps + distance + « CARBURANT RESTANT » interlacé Pb/Gb à chaque FL (II : 780/990 → 550/720 ; VI : 800/1010 → 660/840). L'abaque peut désormais être **tabulé**.
8. **Échelles log VITESSE PROPRE** : bande haute chiffrée **10 → 1500** (ticks ~2000), bande basse **1 → 150** (ticks ~200) ; 3 flèches d'index de conversion : **Pieds 32,8 / Naut 54 / Unités métriques 100** (1 km = 3 280 ft = 0,54 NM). Les bandes Vi (100→350), Mach (0,40→0,80) et Cons. (4→20) sont des **échelles log au même module** — pas linéaires.
9. **Échelle de temps haute du corps : 10′ → 60 cerclé → 1¹⁰, 1²⁰, 1³⁰, 1⁴⁰ = 70/80/90/100 min** (1 h 40), pas « 110–140 minutes ».
10. **Repères des 7 fenêtres Vit. indiquée** (±2 kts) : ★ VI ≈ **220 constant** à tous niveaux ; ● II : absent (FL300), 185 (FL250), 195 (FL200 — recoupé par la notice i) « Vi 195 kts »), 200 (FL150), 210 (FL100), 220 (FL50 et 1000′, superposé à ★).
11. **Rapporteur** : demi-limbe ~185°, double numérotation 10–180 / 190–360, résolution 5°, trou central. Fonction (notice) : **cap géographique / préparation d'un déroutement**. « EXECUTION DES VOLS COM TYPE VICTOR EN TRES BASSE ALTITUDE » est le titre du **bloc de consignes** (météo mini, IFF 3/A 13-77, feux, AUTO INFO, procédure d'urgence), pas celui du rapporteur.
12. Réglettes des chants du corps : 1/2 000 000 = 0→170 NM ; 1/1 000 000 = 0→85 (+≈3) NM tête-bêche. Titre de l'abaque de vent (rayé à l'encre) : lecture retenue « angle direction du vent et route à suivre » (notice à l'appui).
13. **Coquilles internes de la notice** (à signaler si on reproduit ses exemples) : b) « 37 minutes 20 secondes » pour 155/250×60 = 37,2 min (= 37′12″ — lecture décimale prise pour min′sec) ; g) « valeur 15 du Ve » vs Ve = 20 établi ; « force 43 Kts de 43 Kts » ; 4.2 « Vi 200 » vs gravure ● 195 au FL200 ; description « astérisque = vitesse théorique » vs objet (★ = Marboré VI, rappel ✱ à chaque ligne).
14. Divers : DMF FL150 II « 9 l/m » (décimale éventuelle sous la fissure) ; marque ronde ≈ M 0,75 sur la bande Mach FL250 = **annotation manuelle d'un utilisateur** (pas un imprimé) ; les 2 catégories gravées VERT 250 L / JAUNE 300 L sont complétées par la notice i) d'un **« terrain bleu »** (atterrissage avec 50 L restants) — doctrine non gravée.

## 2. Phase A — Réorganiser et corriger `pages/regle_navigation.html` (mode d'emploi)

La page actuelle est une belle **anatomie commentée** écrite avant la notice ; il lui manque le mode d'emploi proprement dit, et plusieurs affirmations sont périmées. Nouvelle ossature (I–VII) :

- **I · Présentation** — garder ; enrichir la provenance : la notice est le chapitre 4 d'un cours d'escadron, la règle « du Capitaine Claude » y est enseignée formellement (citer « BUT » et 4.1). Adoucir l'affirmation invérifiée « la seule pièce de l'instrumentation à porter les deux moteurs ».
- **II · Anatomie** — réécrire avec les données §1 : deux éléments (terminologie notice), les fenêtres et leur principe (pas de position de repos), la coulisse recto ET verso (nouvelles photos à plat), l'abaque de vent solidaire du corps. Supprimer le callout « À confirmer sur l'objet » (tranché) et la phrase « toute manipulation de la coulisse sollicite la plaquette ».
- **III · Abaques** — **tabuler l'abaque de montée** (4 courbes × FL : temps/distance/carburant, sommets II FL250) en remplacement du callout « Non tabulé — à relever » ; remplacer les « plages » des Vit. indiquées par les valeurs relevées (§1.10) ; expliquer le plateau 21 000 t/m = **maxi continu** (notice 4.2, ce n'est pas une anomalie).
- **IV · Règle à calcul & vent** — corriger les étendues (log 10→1500 / 1→150, temps → 1 h 40, chants 0→170 / 0→85) ; index de conversion Pieds/Naut/métriques ; vocabulaire « calcul K », « échelle fixe / échelle mobile », « repère 60 (1 heure) ».
- **V · Mode d'emploi officiel (NOUVEAU)** — les 11 procédures de la notice a)→k), chacune : but, étapes (formulation notice), exemple chiffré d'origine ; encart sur les coquilles (§1.13). C'est le cœur qui manquait à la page « Mode d'emploi ».
- **VI · Le verso de la coulisse (NOUVEAU)** — rapporteur (fonction déroutement), réglettes 1/500 000 · 240 kts et 1/100 000 · 280 kts, consignes vols COM type VICTOR TBA : météo mini JOUR/NUIT, IFF 3/A 13-77, AUTO INFO, procédure d'urgence, carte des niveaux refuge FL55/FL115 + fréquences 383,7/384,5/384,7. (Rester descriptif — notice objective, cf. règle mémoire.)
- **VII · Glossaire** — compléter : DMF, calcul K, Vs/Ve/RV, navigation à l'estime, pétrole forfaitaire, point bidons vides, terrain vert/jaune/bleu, maxi continu…

Assets : ajouter les 4 photos HD (corps/coulisse à plat) dans `assets/img/` (recette habituelle : largeur 2400, q85) — proposition de noms `regle_corps_recto.jpg`, `regle_corps_verso.jpg`, `regle_coulisse_recto.jpg`, `regle_coulisse_verso.jpg` ; conserver les 4 vues assemblées existantes.

## 3. Phase B — `pages/regle_navigation_virtuelle.html` : corrections puis « règle complète »

**B1 — corrections de données immédiates** (indépendantes du refactoring) :
- `VI_IND` : valeurs §1.10 (et étiquette « relevé » au lieu d'« approx ») ; `MONTEE` : table complète temps/distance/carburant des 4 courbes (axe réel = distance NM), sommets II 550/720 L, VI 660/840 L ; échelle temps haute → 1 h 40 (70–100 min, ticks 65→100, étiquettes 1¹⁰…1⁴⁰ — NB : TMAX=100 rend `tx` = 220 px/décade = `spx`, les échelles deviennent commensurables par construction) ; footer/« Fidélité » à jour. (`DIST_PB` − 0,5 : confirmé, ne pas toucher.)

**B2 — refactoring « règle complète »** (spec §E, débloquée par les scans ; audit du code au 22/07 : architecture déjà prête, chantier concentré dans `buildCalcBlock` et `buildVerso`) :
1. Coulisse : remplacer la bande dessinée 5→500 par les **échelles réelles** (recommandation : **redessin vectoriel calé sur les positions de ticks mesurées** sur les scans 300 dpi — meilleur rendu que les bitmaps JPEG) ; 2 bandes log 10→1500 / 1→150 + index Pieds/Naut/métriques.
2. Fenêtres traversantes `<clipPath>` : 7 × Vit. indiquée (à créer), 2 × Mach, Cons. — révélées par la translation unique de la coulisse.
3. Échelles commensurables : même px/décade pour temps et vitesse (module réel 104,5 mm/décade) → le glissement lit réellement d = V·t/60 ; échelle temps bornée à 1 h 40.
4. Débattement porté à la course physique réelle (corps 241–242 × 79 mm, coulisse ≈ 250 mm — scans).
5. **Verso de la coulisse** (nouveau `<g>`) : rapporteur double numérotation, réglettes 240/280 kts, carte, consignes.
6. Étiquetage « gravé vs reconstruit » basculé pour les bandes désormais relevées ; purge de la dette relevée à l'audit (borne de `coff` sur la plage de valeurs, clamp des entrées vent, `resetAll` face, commentaires périmés, ticks 60→100).

**Mettre à jour `REGLE_VIRTUELLE_transition.md`** : §A points ouverts clos, §C clichés reçus (scans), §D données extraites → renvoyer vers le présent plan.

## 4. Phase C — Monographie de la règle (modèle : monographie du computeur)

- **Document maître DOCX → PDF** : `assets/docs/Fouga_CM170R_regle_de_navigation.docx` + `.pdf` (chaîne identique au computeur ; 17 p. de référence). Page de titre sur le modèle computeur (silhouette `fouga_face.png`, « Établie par le Cne CLAUDE Ph — GE 00 315, Cognac 1980 », mention « Ne pas diffuser », date de version) ; sommaire ; en-tête courant « Fouga CM 170 R « Marboré II & VI » — Règle de navigation » ; © Valérie Otero — 2026.
- **Plan calqué sur le gabarit computeur** (I présentation / II abaques / III échelles / IV mode d'emploi / glossaire), avec la matière propre à la règle :
  - I. Présentation générale — les deux éléments, les deux faces, conventions ●/★, **provenance** (outil d'unité du GE 00 315 Cognac BA 709, 1980 ; notice = cours d'escadron ; flotte mixte II/VI ; filiation computeur → règle via l'endurance ≡ face 336).
  - II. Les abaques de performances — DMF Gb + correction Pb (− 0,5 les deux), **montée tabulée**, endurance max, descentes, sécurités (+ note terrain bleu).
  - III. Échelles, fenêtres et calcul K — règle à calcul (module log, index 60, conversions Pieds/Naut/métriques), fenêtres Vi/Mach/Cons., réglettes carto, abaque de vent, **verso de la coulisse** (rapporteur, réglettes 240/280 kts, vols VICTOR TBA, carte refuge 1980 — instantané datable de la défense aérienne : IFF 13-77, fréquences 383,7/384,5/384,7, channel GARDE).
  - IV. Mode d'emploi — les 11 procédures de la notice avec leurs exemples ; précautions de lecture (coquilles de la notice, marque M 0,75 = annotation d'usage, état de l'objet : scotch, fissures, rature du titre vent — la règle a servi en vol).
  - Glossaire.
- **Wrapper** `regle-navigation-monographie.html` (clone de `monographie.html` : mono-entete + btn-docx + object PDF, **sans avertissement prototype**, bandeau « Règle de navigation » actif) ; titre « Monographie · Règle de navigation — Fouga CM 170 R Magister ».
- **Sous-nav portée à 3 entrées** (Mode d'emploi / Règle virtuelle / Monographie) dans `regle-navigation.html`, `regle-navigation-virtuelle.html` et le nouveau wrapper.
- **Option** : héberger la notice d'origine dans `assets/docs/` (ex. `Fouga_CM170R_regle_notice_1980.pdf`, 4,3 Mo — compression ghostscript si utile) et la lier depuis la monographie et la page mode d'emploi (« consulter la notice d'origine »).

## 5. Phase D — Transverse

- `LISEZMOI.md` (tableau des enveloppes) + `FOUGA_CM170_COLLECTE/FOUGA_CM170_HANDOFF.md` : nouvelle page, nouveaux assets, sous-nav à 3.
- Mémoire projet : mise à jour faite le 22/07/2026 (sources arrivées, corrections arbitrées).

## 6. Ordre conseillé

1. **A** (mode d'emploi) — gros gain éditorial, indépendant.
2. **B1** (corrections de données de la virtuelle) — rapide (VI_IND, montée, échelle temps).
3. **C** (monographie) — réutilise la matière rédigée en A.
4. **B2** (refonte « règle complète ») — le chantier le plus technique, à faire en dernier.

## 7. Points résiduels (mineurs)

- Attribution du cercle 4′ à FL50 (II-Pb favorisé, non certain) — formuler prudemment.
- Décimale éventuelle de « 9 l/m » (DMF FL150 II) sous la fissure.
- Titre exact de l'abaque de vent (rayé) — lecture retenue « angle direction du vent et route à suivre ».
