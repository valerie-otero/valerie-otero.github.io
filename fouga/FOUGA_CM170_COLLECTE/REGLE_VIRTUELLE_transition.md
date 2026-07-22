# Règle de navigation virtuelle — Vérification & plan de transition vers la « règle complète »

> **⚑ TRANSITION RÉALISÉE le 22/07/2026.** Les clichés attendus (§C) sont arrivés dans
> `../RdN_Cne_Claude/` (scans A4 300 dpi avec réglet = coulisse & corps à plat, recto/verso,
> + 4 photos HD + **notice d'origine 13 p.**) et le refactoring §E est appliqué :
> échelle mobile réelle 10→1500 / 1→150 avec flèches de conversion, fenêtres traversantes
> `<clipPath>` (7 Vi + 2 Mach + Cons.) lues par translation unique, échelles commensurables
> (TMAX=100 min → tx = spx = 220 px/décade), lecture au repère 60, montée sur l'axe distance
> gravé avec carburant complet, rapporteur demi-limbe à double numérotation.
> Les deux points ouverts du §A sont **clos** (sommets II gravés 550/720 L ; FL50 = 2 cercles,
> 3′ VI-Pb prouvé / 4′ attribué II-Pb). Voir `REGLE_REFONTE_plan.md` (données tranchées,
> arbitrages 280 kts / fréquences 38x,x / Pb −0,5 confirmé) — ce fichier est conservé
> comme trace de l'état du 18/07/2026.

*Fichier concerné : `pages/regle_navigation_virtuelle.html`. Établi le 18/07/2026 après vérification adversariale (relectures aveugles des photos + audit des calculs + chasse aux bugs + smoke test jsdom). Sources = les 4 clichés `assets/img/regle_*.jpg`.*

---

## A. Résultat de la vérification (état validé)

**Données gravées — fidèles à 100 %.** Trois relectures aveugles indépendantes par sous-table (distance, endurance, montée), unanimes et confrontées cellule par cellule au code : **aucune divergence**.
- Distance max Gb (7 FL × II/VI + correction Pb −200/−500 & −0,5) : conforme.
- Endurance max (5 alt × II/VI) : conforme, et **≡ exact** à la face 336 du computeur pour Z 5→25 (recoupement de deux gravures indépendantes).
- Abaque de montée (4 courbes, cotes de temps + carburant sommets 660/840 L) : conforme.
- Descentes, sécurités (250/300 L), Mach 0,50, rapporteur 360° : conformes.

**Calculs — numériquement exacts** (audit adversarial des 5 cibles) :
- `d = V·t/60` (règle à calcul) et ses 3 inverses : exacts.
- Correction petits bidons : soustractive, arrondie, appliquée à la seule distance : exacte.
- Descentes (taux × altitude) : exactes.
- Vent (triangle des vitesses) : grandeurs exactes.
- Géométrie log de la coulisse : `updateVPfromSlide` est l'inverse algébrique **exact** de `alignSlide` sur la plage d'usage.

**Correctifs appliqués le 18/07/2026** (aucun ne touche une donnée gravée ; smoke test jsdom = 0 exception) :
1. Sortie TVD étiquetée `Nm/km` (au lieu du « km » trompeur : V peut être en nœuds).
2. Note du vent réécrite : l'abaque est un quart de cercle 0–90° donnant une **grandeur** ; suppression de la fausse promesse « − face ».
3. Footer : le recoupement face 336 est désormais attribué à la **seule endurance Marboré II** (identité exacte), plus à « distance + endurance ».
4. Accessibilité clavier de la coulisse (`role=slider`, `tabindex`, `aria-value*`, flèches ←→ + Maj fin + Origine/Fin) — parité avec le computeur.
5. Robustesse : altitude de descente bornée à 0–30 ; décimales cohérentes (conso Pb « 8,0 », percée « 12,5 L ») ; moins Unicode homogène ; constante `VPREF` (fin des 270 en dur) et helper `clampCoff`.

**Deux points de lecture restés ouverts** (n'affectent pas le code, majorité 2/3 respectée — à confirmer sur macro haute déf) :
- Carburant au **sommet des courbes Marboré II** : un lecteur lit « 550 / 720 L », deux lisent « non gravé ». (Distinguer cote de sommet vs graduation d'axe « carburant restant ».)
- Cotes **FL50 médianes** de VI-Gb / II-Pb : gravées individuellement ou courbes groupées ?

---

## B. Ce qui reste « reconstruit » (schématique) aujourd'hui

| Élément | État actuel | Pourquoi |
|---|---|---|
| Coulisse VITESSE PROPRE | **1 seule décade log** dessinée, `SPMIN=5..SPMAX=500` | La coulisse réelle porte **3 sous-échelles** (Pieds / Naut / Unités métriques) et **s'étend au-delà de la fenêtre** (on lit 500…1500 à droite de l'abaque de vent sur `regle_recto_coulisse.jpg`). |
| Lecture graphique d=V·t/60 | Impossible par glissement | `tx` (échelle temps, 205 px/décade) et `spx` (échelle vitesse, 220 px/décade) **non commensurables** ; seul `vpCompute` fait foi. |
| Fenêtres Mach / Cons. / Vit. indiquée | Dessinées statiques | Pas de vraie fenêtre traversante révélant la coulisse. |
| Verso de la coulisse | **Inconnu total** | Aucune photo. |
| Signes du vent (arrière/face, dr./g.) | Convention (quart de cercle) | L'abaque physique ne donne qu'une grandeur. |

---

## C. Clichés encore nécessaires (attendus) — angle & éclairage

1. **Coulisse RECTO à plat, sortie du corps** — strictement perpendiculaire (zéro parallaxe), éclairage uniforme, **un réglet de référence dans le cadre**, haute résolution. But : mesurer l'espacement log réel des 3 sous-échelles.
2. **Coulisse VERSO à plat** — capture complète bout à bout (contenu à découvrir).
3. **Curseur transparent SEUL, de face** — idéalement un exemplaire **non fissuré** (l'actuel est jauni/cassé sur l'abaque de vent).
4. **Corps recto ET verso SANS le curseur** — position exacte des fenêtres, index fixes, réglettes 1/2.000.000 et 1/1.000.000.
5. **Deux clichés « datum »** : coulisse au **repos/référence** ET en **sortie complète** — pour figer le décalage coulisse↔fenêtres.
6. **Macros en lumière rasante** : les 2 fenêtres Mach (FL300/FL250, avec le repère ★), la fenêtre « Cons. l/minute », les 7 cadrans « Vit. indiquée », et les sommets de courbes Marboré II (points ouverts A).

---

## D. Données à extraire de ces clichés

- Échelle VITESSE PROPRE, **2 bandes complètes** (haute ≈ 20→1500, basse ≈ 2→150) : position de chaque majeur **et** du motif de ticks mineurs.
- Position des **3 index de conversion** Pieds / Naut / Unités métriques (confirmer que ce sont des index et non 3 échelles séparées).
- Les **7 valeurs « Vit. indiquée »** (confiance aujourd'hui faible : ~150/200/250/300 selon FL).
- Les **2 strips Mach** FL300/FL250 (graduation 0…0,50 + rôle du ★).
- Le **strip « Cons. l/minute »** (valeurs fines actuellement illisibles).
- Géométrie de l'**abaque de vent** sur un curseur non fissuré (arcs force, dérive, VP 100→300).
- **Contenu du verso de la coulisse.**

---

## E. Refactoring code recommandé (à la réception des photos)

1. **Remplacer les échelles dessinées par les strips photographiés** rectifiés (dé-parallaxés), posés en `<image>`/`<pattern>` SVG ; la coulisse devient un `<g>` piloté par une **seule** `translateX(coff)`.
2. **Fenêtres traversantes réelles** via `<clipPath>` : « Vit. indiquée » (×7), « Nbre de Mach » (×2), « Cons. l/minute » — chaque fenêtre révèle la portion de coulisse au droit de son index et se met à jour **par simple translation** (fin du calcul de contenu par fenêtre ; reproduit le blanchiment des fenêtres quand on tire la coulisse).
3. **Rendre les échelles commensurables** avant de figer : même px/décade pour `tx` et `spx`, pour que le glissement lise réellement `d = V·t/60`. Poser l'index fixe sur la vraie référence (`VPREF` déjà extraite en constante).
4. **Étendre le débattement** de la coulisse à sa course physique réelle (aujourd'hui bridé `COFF_MIN/MAX = ±260` pour contenir le schéma dans le cadre) — possible une fois les strips à la bonne échelle.
5. **Verso de la coulisse** : nouveau `<g>` symétrique une fois les données connues.
6. **Conserver l'étiquetage « gravé vs reconstruit »** : la section « Fidélité » doit faire basculer les strips photographiés (Vit. indiquée, Mach, Cons.) de « approché » vers « relevé sur l'instrument ».
7. Reporter l'accessibilité clavier déjà en place sur la nouvelle coulisse.

## F. Ce qui restera reconstruit même après

- Le **couplage** opératoire d = V·t/60 (les cotes sont gravées, le couplage reste numérique — l'usure/parallaxe interdit une lecture au pixel gravé).
- L'**interprétation des signes du vent** (côté, tête/queue) — hors instrument.
- L'**extrapolation hors plage** (descente > 30 000 ft, angle > 90°) — non gravée.
- Toute **zone masquée par le curseur fissuré** si aucun exemplaire sain n'est photographié.
