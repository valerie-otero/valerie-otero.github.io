# FOUGA CM 170 — Manuel de l'équipage (Partie Texte) — Document de passation

**Objet du projet :** OCR + restitution en DOCX éditables, fidèles à l'original, du
*Manuel de l'équipage des avions Fouga CM 170 — Bi-réacteur Turboméca — Partie Texte*
(Édition 1975, Révision 06/1977). Objectif final : un **document maître assemblé** + une **étude**.

**Source :** `FOUGA_CM_170_TEXTE.pdf`
- 115 pages physiques, ~86 Mo, **entièrement scanné** (aucune couche texte exploitable ; seul un
  filigrane revendeur « RONSAVIATIONSHOP » figure dans la couche texte). OCR requis partout.
- Page physique paysage 1532 × 1225 pts ; chaque page = une image JPEG.

**Mode de livraison :** **un fichier DOCX par section**, archivés au fur et à mesure, pour
assemblage final + étude.

> **MISE À JOUR (cette passation) : les Sections III à VIII sont désormais terminées.
> Toutes les sections du manuel (liminaires + I→VIII) sont transcrites.
> Restent uniquement le document maître assemblé et l'étude.**

---

## 1. Avancement

| Livrable | Fichier | Pages internes | État |
|---|---|---|---|
| Pages liminaires | `FOUGA_CM170_00_Liminaires.docx` | Index + Tables (1–6) | ✅ |
| Section I — Description | `FOUGA_CM170_Section_I_Description.docx` | 7–34 | ✅ |
| Section II — Utilisation courante | `FOUGA_CM170_Section_II_Utilisation_courante.docx` | 35–49 | ✅ |
| Section III — Limitations | `FOUGA_CM170_Section_III_Limitations.docx` | 51–54 | ✅ |
| Section IV — Cas particuliers de vol | `FOUGA_CM170_Section_IV_Cas_particuliers_de_vol.docx` | 55–63 | ✅ |
| Section V — Utilisation des équipements | `FOUGA_CM170_Section_V_Utilisation_des_equipements.docx` | 65–72 | ✅ |
| Section VI — Incidents, pannes, secours | `FOUGA_CM170_Section_VI_Incidents_pannes_secours.docx` | 73–100 | ✅ |
| Section VII — Armement | `FOUGA_CM170_Section_VII_Armement.docx` | 101 | ✅ |
| Section VIII — Conditions climatiques extrêmes | `FOUGA_CM170_Section_VIII_Conditions_climatiques_extremes.docx` | 103–104 | ✅ |
| **Document maître assemblé** | — | tout | ⬜ |
| **Étude** | — | — | ⬜ |

Les 9 fichiers DOCX sont regroupés dans l'archive `FOUGA_CM170_COLLECTE.zip`.

---

## 2. Structure du document (référence)

Chapitre I — Description (Section I). Chapitre II — Utilisation (Sections II à VIII).
Sous-sections : 2.1→2.16 ; 3.1→3.3 ; 4.1→4.8 ; 5.1→5.3 ; 6.1→6.16 ; 7.1→7.3 ; 8.1 (8.1.1→8.1.5).

**Pages internes manquantes** (numérotation d'origine non contiguë, confirmé par l'Index) :
**50, 64, 102** n'existent pas.

---

## 3. Correspondance pages PDF ↔ pages internes (TABLE COMPLÈTE, confirmée)

Le PDF intercale des **pages-titres de couleur** (intercalaires) qui décalent la numérotation.
Tous les offsets ci-dessous ont été **vérifiés folio par folio**.

| Section | Intercalaire(s) PDF | Contenu PDF | Internes | Offset (interne = PDF − x) |
|---|---|---|---|---|
| Liminaires | 1–3 (couv., index) | 4–9 | 1–6 | −3 |
| I — Description | 10 (Chap. I), 11 (Sect. I) | 12–39 | 7–34 | **−5** |
| II — Utilisation courante | 40 (Chap. II), 41 (Sect. II) | 42–56 | 35–49 | **−7** |
| III — Limitations | 57 (Sect. III) | 58–61 | 51–54 | **−7** |
| IV — Cas particuliers de vol | 62 (Sect. IV) | 63–71 | 55–63 | **−8** |
| V — Utilisation des équipements | 72 (Sect. V) | 73–80 | 65–72 | **−8** |
| VI — Incidents, pannes, secours | 81 (Sect. VI) | 82–109 | 73–100 | **−9** |
| VII — Armement | 110 (Sect. VII) | 111 | 101 | **−10** |
| VIII — Conditions climatiques extrêmes | 112 (Sect. VIII) | 113–114 | 103–104 | **−10** |

> Remarque : l'offset croît de +1 à chaque intercalaire de section ; les pages internes manquantes
> (50, 64, 102) compensent parfois ce décalage (ex. V conserve −8 car la 64 manquante et
> l'intercalaire Section V s'annulent). **Toujours recaler l'offset sur le folio imprimé** de
> chaque page de contenu (coin bas) et sur le marqueur de chapitre en haut (ex. « 6.9 »).
> PDF 115 = dernière page (hors plage de contenu interne).

---

## 4. Méthode de production (à reproduire à l'identique)

**Environnement :** `bash` réseau désactivé ; `docx` (npm global) déjà installé.
Exécuter Node avec `export NODE_PATH=$(npm root -g)`.

> **⚠️ CAVEAT ENVIRONNEMENT — IMPORTANT :** le système de fichiers de l'environnement est
> **réinitialisé entre les tours/sessions**. Seuls persistent : `/mnt/user-data/uploads/`
> (lecture seule) et `/mnt/user-data/outputs/`. À chaque reprise il faut **re-extraire
> `files.zip`** (ou l'archive collecte) et re-vérifier `require('docx')`. Pour l'assemblage du
> document maître, **joindre en entrée l'archive de tous les fichiers de section** (les DOCX
> produits en session précédente ne survivent pas, sauf ceux copiés dans `outputs/`).

**Workflow par section :**
1. Rasteriser le lot de pages basse résolution pour repérer les intercalaires :
   `pdftoppm -jpeg -r 90 -f <pdf_start> -l <pdf_end> <pdf> /tmp/map`
   (les intercalaires sont des JPEG légers, ~35–65 Ko, fond blanc + « SECTION x » centré).
2. Rasteriser le contenu en HR : `pdftoppm -jpeg -r 150 -f <a> -l <b> <pdf> /tmp/s`.
3. **OCR = lecture visuelle** des images via l'outil `view` (plus fiable que tesseract sur titres
   stylisés et chiffres). Lire ~1 page par appel, vérifier le folio à chaque page.
4. Construire le DOCX avec un **script JS unique par section**. Pour les sections longues
   (ex. VI, 28 pages), **découper le script en plusieurs fichiers** qui s'enchaînent via
   `require()` et `module.exports = { b, … }` afin d'éviter la troncature d'un trop gros
   `create_file` ; le dernier fichier assemble le `Document` et écrit le DOCX.
5. Valider : `python /mnt/skills/public/docx/scripts/office/validate.py <docx>`.
6. QA visuel : `soffice.py --convert-to pdf` → `pdftoppm` → `view` (vérifier titres, encadrés,
   puces imbriquées, alignements).
7. Copier vers `/mnt/user-data/outputs/` et présenter.

**Mise en page :** A4 portrait, marges 1″, police Arial 11 pt (taille docx 22).
Bloc de titre en tête de chaque section : Title « FOUGA CM 170 » + ligne centrée grasse
« Manuel de l'équipage — Partie Texte » + ligne centrée « CHAPITRE n — Section : … ».

**Styles de titres (identiques sur toutes les sections III→VIII) :**
- `Heading1` — niveaux x.x (sections, ex. 6.1) : Arial 15 pt, gras, couleur 1F3864.
- `Heading2` — niveaux x.x.x (ex. 6.1.1) : Arial 12 pt, gras, **souligné**, couleur 2E5496.
- `Heading3` — niveaux x.x.x.x (ex. 5.1.5.1, 6.1.9.1) : Arial 11 pt, gras, **italique**,
  couleur 2E5496. *(Introduit à partir de la Section V.)*

**Bibliothèque de helpers (définie dans chaque build script ; reprendre telle quelle) :**
- `h1/h2/h3(num, titre)` — titres (num + deux espaces + titre).
- `para(t)` — paragraphe justifié, indent 340. `subpara(t)` — idem indent 700 (corps d'un a)/b)/c)).
- `plain(t)` — ligne indentée non justifiée. `subline(t)` — continuation indentée (700) sans puce.
- `lead(gras, reste)` — paragraphe à amorce en gras (ex. « Emission : … »).
- `bullet(t, niveau)` — puce réf. « tirets » : **niveau 0 = « – », niveau 1 = « · »,
  niveau 2 = « – »** (3 niveaux ; le niveau 2 a été ajouté en Section VI pour les listes de
  procédures profondément imbriquées).
- `numitem(label, t, sep, indent)` — item à **numérotation manuelle** (préserve numéros d'origine
  ET sauts). Ex. `numitem("1)", t, " ")`, `numitem("a)", t)`, `numitem("A -", t)`.
- `note(t, label="NOTA")` — paragraphe « **NOTA :** … ». Variantes par `label` :
  `"N.B."`, `"IMPORTANT"`, `"REMARQUE IMPORTANTE"`.
- `attention(items, {align})` — encadré bordé 1 cellule, titre **ATTENTION** centré. `items` accepte
  des chaînes (centrées ou alignées à gauche selon `align:'left'`) **ET des paragraphes
  pré-construits** (ex. `boxbullet(t)` pour des puces internes, ou des lignes numérotées « 1 - / 2 - »).
- `notebox`/`boxbullet` — variantes d'encadré et de puce interne d'encadré.
- `dataTable(headers, rows, widths, aligns)` — tableau bordé, en-tête grisé (D9D9D9). Une cellule
  peut être une chaîne **ou un tableau de chaînes** (multi-lignes) ; `aligns` = alignement par
  colonne (`'left'`/`'center'`). Utilisé en I, III, IV (décrochages), V (correction « en crabe »).
- `kvline(label, valeur, indent, tabPos)` — ligne « libellé \t valeur » alignée par tabulation
  (sans points de conduite). Pour les listes à colonnes (Plafond, ressources, vitesses voltige,
  VHF/VOR…).
- `val(label, valeur)` — ligne « libellé …… valeur » avec **points de conduite** (LeaderType.DOT).
  Surtout Section I.
- `subhead(t)` — sous-titre **italique souligné** (ex. « Reprise de contrôle sans moteur »,
  « Le pompage : », « place avant »).
- `numsubhead`/`ulead` — sous-titre numéroté souligné (« 1) Altitude d'évacuation : ») / amorce
  soulignée en début de ligne (« place avant - … », « au décollage : … »). Sections VI, VIII.
- `flow(t)` — étiquette de procédure non soulignée (ex. « Configuration », « Entrée de bande »,
  « Vent arrière »). Sections VI.
- `greynote(t)` — note éditoriale en *italique gris* (18) pour les divergences TdM/corps et les
  éléments non reproductibles (accolades).
- `banner(t)` — bandeau centré gras non encadré (ex. « INTERROMPRE LE DECOLLAGE »).

**Numérotation (config docx) :** une seule référence `"tirets"` à 3 niveaux (voir `bullet`).
Toujours `cantSplit:true` sur les lignes de tableau de données.

---

## 5. Règles de fidélité (conventions éditoriales adoptées)

- **Numérotation d'origine préservée telle quelle**, y compris les sauts → numérotation **manuelle**
  (`numitem`), jamais auto.
- **Titres réellement imprimés** transcrits même s'ils diffèrent de la table des matières ; la
  divergence est signalée en *italique gris* (`greynote`) dans le corps.
- **Valeurs illisibles/omises dans l'original** → `[valeur omise dans l'original]` en italique gris
  (ne rien inventer).
- **Encadrés ATTENTION / NOTA / N.B. / IMPORTANT** reproduits comme encadrés ou paragraphes à amorce.
- **Renvois planches/repères et § croisés conservés à l'identique.**
- Apostrophes/guillemets typographiques (', « »).
- **Coquilles triviales corrigées silencieusement** (voir log §6) ; toute correction non triviale
  est laissée telle quelle et consignée.
- Les **accolades** de l'original (regroupements verticaux) ne sont pas reproductibles en DOCX
  simple : leur sens est restitué par une `greynote`.

---

## 6. Anomalies / points relevés (LOG CONSOLIDÉ pour l'étude finale)

**Liminaires & Section I** (relevés initiaux) :
1. 1.5 : titre imprimé « CIRCUIT D'HUILE » ≠ TdM « Circuit lubrifiant ».
2. 1.5.3 : une valeur de pression **omise dans l'original** (« …tombe au-dessous de . »).
3. 1.10 / 1.11 : décalage TdM (p.29/30) ↔ corps imprimé.
4. Planches dans un volume « Partie Planches » distinct, non couvert ici.
5. Coquilles d'origine ponctuelles (« des lampes lampes », « Volmètre »).

**Section III** :
6. **Incohérence capacité bidons** : 3.2.1 et 3.2.7 « bidons 122 litres » mais 3.2.3 a)
   « bidons 125 litres ». Transcrit tel quel.
7. 3.3 : titre imprimé ajoute « (maxi ou mini) » absent de la TdM → signalé en gris.
8. Corrections triviales : « grace »→« grâce » (3.1.3) ; « inxtinctions »→« extinctions » (3.2.5) ;
   « 3 2.7. »→« 3.2.7. ».

**Section IV** :
9. 4.4.2 titre imprimé « Voltiges classique » (pluriel/singulier discordant) — transcrit tel quel.
10. Corrections triviales : « d'effectue »→« s'effectue » (4.4.2) ; « lampe B.P, »→« lampe B.P. ».
11. La Section IV emploie partout « 122 l »/« 230 l » → renforce l'anomalie 122/125 (cf. §6.6, §6.16).

**Section V** :
12. **Décalage TdM/corps (−1 page)** : TdM annonce 5.2 p.69 et 5.3 p.71 ; corps imprimé 5.2 p.70,
    5.3 p.72 (analogue à l'anomalie 1.10/1.11).
13. TdM « Radio - navigation » vs imprimé « RADIO NAVIGATION ».
14. Correction triviale : « rampe rouge témoin »→« lampe rouge témoin » (5.3.1).
15. Position « A » au volume du VHF de secours (5.1.6) là où le reste utilise « ▲ ».

**Section VI** :
16. 6.12 : imprimé « INCIDENTS DE CIRCUITS EQUIPEMENT » (pluriel) vs TdM « circuit équipement ».
17. Corrections triviales : « le décollage est *position* en toute sécurité »→« *possible* »
    (6.9.2.1 NOTA, p.85) ; « la *pompe* rouge GENE »→« la *lampe* rouge GENE » (6.11.2) ;
    numérotation « 6.1 9.1 / 6.1 9.2 »→« 6.1.9.1 / 6.1.9.2 ».
18. 6.9.2.1 NOTA mentionne encore « réservoirs de 125 litres » → 3e occurrence du couple 122/125.
19. 6.6.2 (p.81) : accolade regroupant les points 5–7 « si vue du sol » → `greynote`.
20. 6.9.6.1 : numéro inline avec le texte (pas de titre distinct) contrairement à 6.9.6.2 → rendu
    en paragraphe à numéro gras.

**Section VIII** :
21. Titre imprimé « CLIMATIQUES EXTREMES » (majuscules sans accent) vs TdM « climatiques extrêmes ».
22. 8.1.5 : accolade reliant « niveau 180 » et « Vi = 140 nœuds » à la remarque pompe BP → `greynote`.

> **Fil rouge pour l'étude — l'incohérence 122/125 litres** : le couple « bidons 122 l »
> (capacité réelle des petits bidons) vs « 125 l » apparaît au moins en 3.2.3, 6.9.2.1 (NOTA) ;
> à recenser exhaustivement et à expliquer (probable coquille répétée pour 122).

---

## 7. Reste à faire

1. **Document maître** : assembler liminaires + Sections I→VIII en un seul DOCX.
   - Conserver les styles Heading déjà en place (permet une **TOC Word automatique**).
   - Sauts de section entre chapitres ; en-têtes/pieds (ex. « CM 170 » / folio / « Révision 06/1977 »).
   - Vérifier l'homogénéité des blocs de titre et la continuité de la numérotation.
   - **Entrée nécessaire** : l'archive `FOUGA_CM170_COLLECTE.zip` (9 DOCX) — voir caveat §4.
2. **Étude** : synthèse documentaire — architecture du manuel ; points techniques saillants
   (Marboré VI, empennage papillon, circuits hydraulique/carburant/électrique, conditionnement d'air,
   armement) ; log d'anomalies §6 (notamment le fil rouge 122/125) ; comparaison TdM ↔ corps ;
   particularités des procédures de secours (vrille rapide, rallumage, monoréacteur, évacuation).

---

## 8. Site web (`SITE/Global/fouga`) — état et journal

Le projet s'est étendu à un **site statique de restitution** (HTML/CSS/JS, sans dépendance) :

| Page | Rôle |
|---|---|
| `index.html` | Présentation du CM.170 + bibliographie repliable |
| `manuel.html` → `pages/manuel/*` | Manuel de l'équipage en HTML (pipeline `build/manuel/`) |
| `computeur.html` → `pages/mode_emploi.html` | Mode d'emploi illustré du computeur (long-form, iframe) |
| `computeur-virtuel.html` → `pages/computeur_virtuel.html` | Computeur virtuel interactif SVG (recto 131 / verso 336) |
| `monographie.html` | Monographie PDF **illustrée** (6 photos + date de version) consultable + DOCX téléchargeable |
| `regle-navigation.html` → `pages/regle_navigation.html` | Mode d'emploi illustré de la règle de navigation (Marboré II & VI) |
| `regle-navigation-virtuelle.html` → `pages/regle_navigation_virtuelle.html` | Règle de navigation virtuelle interactive SVG (recto calcul / verso montée) |

**Charte** : crème/bleu Armée/laiton, définie dans `assets/css/site.css` (variables `--paper`,
`--blue`, `--brass`…) ; les pages internes du computeur embarquent leur propre copie de la charte.

### Journal des interventions

**2026-06-11 — Page de présentation**
- Nouveau texte de présentation (5 paragraphes) avec **appels de notes en exposant** ([1]…[15])
  reliés à une **bibliographie repliable** (`<details class="biblio">`) ; styles dédiés dans `site.css`.
- Correctif layout : `body` en `min-height:100%` (au lieu de `height:100%`) + `flex-shrink:0` sur
  `.pied` — le pied de page suit désormais le contenu long au lieu de rester figé à mi-page.

**2026-07-17 — Audit + correctifs du computeur**
- **Contrôle croisé des données** : grilles de croisière du computeur virtuel (`D`) ≡ tableaux du
  mode d'emploi (3 régimes sondés) ; rappels gravés cohérents ; formule TAS (`sigma`) validée (<1 %
  d'écart avec les valeurs gravées).
- **Logo** : le trois-vues base64 (`FOUGA`) était déclaré mais jamais injecté → `titleLogo.src=FOUGA`.
- **Table 336** : barre diagonale tracée uniquement quand deux valeurs coexistent (Vi 140/150) ;
  régimes uniques centrés. Harmonisations : « 140/150 kt » (sans s), conso « 5,0 » l/min à Z=30.
- **Outil TAS verso** : altitude bornée à 30 000 ft (limite instrument), écrêtage dans `calcTAS`.
- **Accessibilité clavier** : couronnes focusables (`tabindex`, `role=slider`, `aria-valuetext`),
  flèches ←→ (Maj = réglage fin au verso), hints mis à jour.
  ⚠️ **Piège rencontré** : ne jamais mettre d'`outline` de focus sur un groupe SVG tourné par
  `transform:rotate()` — la boîte englobante tourne avec lui (grandes diagonales parasites à
  l'écran). Solution retenue : `outline:none` sur les groupes, indicateur reporté sur le conteneur
  via `svg.instr:has(.couronne:focus-visible){outline:…;border-radius:50%}`.
- **Couronne recto** : des repères ▲ par altitude ont été ajoutés puis **retirés à la demande**
  (confusion : sur l'original, le seul repère ▲ est l'**index fixe** en haut du cadran, déjà
  présent en rouge). Le groupe SVG `#marks` reste volontairement vide.
- **Textes du mode d'emploi** : « paliers de **45 à 55 L** » (710→665 = 45 L, l'ancien
  « 50 à 55 » était inexact) ; lede reformulé (« …établi pour l'avion-école et ses réacteurs… »,
  l'instrument n'ayant pas de réacteurs) ; footer interne réduit à un colophon d'une ligne
  (suppression du double pied de page avec le bandeau du site).

**2026-07-17/18 — Nouveau sous-sujet « Règle de navigation » (Marboré II & VI)**
- Sous-sujet ajouté à la nav principale + sous-barre à 2 pages, sur le schéma du sous-sujet Computeur.
  ⚠️ **L'onglet principal est répété dans 6 fichiers**, dont `manuel.html` **généré** (bandeau dans
  `build/manuel/build-sommaire.js`) : toute modif de nav doit aussi toucher le script, sinon l'onglet
  disparaît au prochain `build-manuel.sh`. Liens sortants des pages `pages/` en `target="_top"`.
- **Mode d'emploi** (`pages/regle_navigation.html`) : règle à calcul linéaire « Cne Claude Ph, GE 00 315,
  Cognac 1980 », **seul instrument portant les deux moteurs** (● Marboré II / ★ Marboré VI). Tables
  transcrites **d'après les photos** `../RegNavMVI/MVI1–4` : distance max Gb + correction Pb, endurance
  max (II & VI), descentes, sécurités 250/300 L, montée. **Recoupement clé** : la ligne endurance
  Marboré II ≡ à l'identique la face 336 du computeur (validation croisée).
- Précision « Marboré II » ajoutée au computeur (il ne connaît que ce moteur ; renvoi croisé vers la règle).

**2026-07-18 — Règle de navigation virtuelle (instrument interactif)**
- `pages/regle_navigation_virtuelle.html` : frère du computeur virtuel. Recto = tableaux sélectables
  (moteur / bidons / niveau ; cas **FL300-II vide** géré) + règle à calcul VITESSE PROPRE (coulisse
  glissante, `d = V·t/60`) + abaque de vent (triangle des vitesses). Verso = abaque de montée
  (4 courbes digitalisées), endurance, descentes, rapporteur 360°.
- **Méthode** : workflow d'**extraction fidèle** (8 lecteurs sur les photos 4096 px → 0 divergence avec
  la transcription et la face 336), puis workflow de **revue adversariale** (fidélité données =
  0 erreur ; 9 findings code/UX/étiquetage corrigés).
- **Principe respecté** : valeurs **gravées** par défaut ; reconstructions (règle à calcul, vent) et
  approximations (repères ●/★, montée en temps, rapporteur/réglettes schématiques) **explicitement
  étiquetées** (section « Fidélité à la règle d'origine »).
- Photos déposées et découpées : `assets/img/regle_*.jpg` ; plan 3-vues `../magister_3v.jpg` séparé en
  `fouga_profil / dessus / dessous.png` (PNG transparents, encre sépia).

**2026-07-18 — Objectivation des notices (computeur + règle)**
- Retrait de tout contenu de **conduite de vol** (préparer une navigation pas à pas, bilan carburant,
  choix de l'avion, préparation du pilote) — hors sujet + hors compétence (**consigne Valérie**).
  Computeur §IV « Préparer un vol » → objective **« La règle à calcul »** ; règle §V « Préparer une
  navigation » **supprimée** (déjà couverte par §IV). Impératifs au pilote neutralisés. Les notices ne
  gardent que la **description objective** de l'instrument (parties, échelles, tables, lecture).

**2026-07-18 — Page de présentation**
- **Bandeau d'avertissement** : prototype en cours de réalisation, usage privé (non diffusé), peut
  comporter erreurs/approximations, **ne convient pas à un vol** (style `.avertissement` dans `site.css`).
- **Illustrations** : dessin de face conservé (haute déf.) ; les 3 autres vues du plan 3-vues séparées,
  en **rail vertical dans la marge gauche** (wrapper `.accueil-corps` = rail de vues + texte).

**2026-07-18 — Bibliographies**
- Biblio web **vérifiée** (workflow : recherche + `fetch` de chaque URL) → 12 sites web à URL confirmée
  + 1 publication ([10] W. Dorn) ; **[7]/[9] invérifiables** → laissées sans lien, signalées. Erreurs
  corrigées : titre [2] (traduction anglaise → vrai titre FR), nom [14] (Nationaal → **Nederlands**
  Transport Museum). Liens cliquables ajoutés ; mentions « consultation du … » retirées. Bloc renommé
  **« Notes et références numériques »**.
- **« Bibliographie sélective »** ajoutée : 7 sections (I ouvrages … VII catalogues), **53 entrées**
  fournies par Valérie, reproduites fidèlement (styles `.biblio-sel`).
- **Typographie française** : petit script (même que le manuel) **limité aux `.biblio`** (insécables
  avant `; : ! ?` et dans `«…»`), sans toucher au texte d'accueil ; police des biblios grossie.

**2026-07-18 — Règle virtuelle : vérification + spec de transition**
- **Contrôle et véracité** (workflow adversarial : 3 lecteurs *aveugles* par sous-table + 5 audits de
  calcul + 2 chasses aux bugs + synthèse ; puis smoke test jsdom bout à bout, 0 exception) :
  **données gravées fidèles à 100 %** (distance, endurance, montée, descentes, sécurités, Mach —
  aucune divergence cellule par cellule) ; **calculs numériquement exacts** (d=V·t/60 et inverses,
  correction Pb, descentes, vent, géométrie log de la coulisse). Recoupement **endurance Marboré II ≡
  face 336** revérifié (Z 5→25, identité exacte).
- **Correctifs appliqués** (aucun ne touche une valeur gravée) : sortie TVD étiquetée « Nm/km » (fin du
  « km » trompeur) ; note du vent honnête (quart de cercle 0–90°, grandeur seule, plus de fausse
  « − face ») ; footer recentré sur le recoupement **endurance** (le côté distance n'était pas une
  identité) ; **accessibilité clavier de la coulisse** (`role=slider`/flèches, parité computeur) ;
  robustesse (descente bornée 0–30, décimales & moins Unicode cohérents, constante `VPREF`).
- **Points de lecture ouverts** (majorité respectée, à confirmer sur macro) : carburant au sommet des
  courbes Marboré II (550/720 L ?) ; cotes FL50 médianes.
- **Spec de transition** vers la **règle complète** écrite dans
  `FOUGA_CM170_COLLECTE/REGLE_VIRTUELLE_transition.md` (clichés coulisse recto/verso à plat encore
  **en attente** : voir §C–E — coulisse à 3 sous-échelles Pieds/Naut/métrique, fenêtres traversantes
  en `<clipPath>`, échelles à rendre commensurables, verso inconnu).

**2026-07-18 — Manuel HTML : retrait pendant des items numérotés / lettrés**
- Bug d'affichage : les items à **numérotation manuelle** (« 1) 2) 3) », « a) b) c) », « A - »,
  « 1 - ») étaient rendus par pandoc en `<p>` simples → les lignes suivantes revenaient à la marge
  gauche (sous le numéro) au lieu de s'aligner sous le texte. Corrigé **dans le pipeline** (reproductible) :
  - `build/manuel/manuel-filter.lua` : nouvelle règle (7) — un paragraphe dont l'amorce est un marqueur
    d'item (`^%d+%)`, `^%l%)`, `^%u%)`, `^%d+ ?- `, `^%u ?- `) devient `<div class="numitem">`. **Le numéro
    d'origine reste dans le texte (jamais renuméroté) ;** ordre : après NOTA et titres numérotés `x.y`.
  - `assets/css/manuel.css` : `.numitem` = `padding-left:1.7em; text-indent:-1.7em` (retrait pendant),
    justifié dans le corps, à gauche dans `.note`/`.encadre`.
  - `assets/css/manuel.css` : `.numitem` = `padding-left:1.7em; text-indent:-1.7em` (retrait pendant).
- **2e correctif (même jour) — regroupement des NOTA multi-paragraphes.** Bug relevé sur le scan (source de
  vérité, PDF p.67 § 4.4.2) : une NOTA introduisant une liste « NOTA : 1) … 2) … 3) … » est **un seul**
  blockquote dans le DOCX, mais le filtre ne mettait que le 1) dans l'encadré (barre + fond) et laissait 2)/3)
  déborder dehors. Corrigé :
  - `manuel-filter.lua` : `BlockQuote` regroupe désormais **tout** le blockquote-note dans un seul encadré ;
    s'il contient des items numérotés → **`note-list`** : le label (« NOTA : », « N.B. : », « NOTA 1 : ») est
    détaché dans une **grille `auto 1fr`** (colonne auto-dimensionnée, donc juste quel que soit le label) et
    les items 1) 2) 3)… alignés dessous en retrait pendant. 1er item détaché du label **sans altérer le texte**.
    Les notes multi-paragraphes **sans** items sont aussi regroupées (ex. § 4.3.1).
  - `manuel.css` : styles `.note-list` (grille) + `.nl-lbl` / `.nl-items`.
- **Vérifs** : `build-manuel.sh` relancé ; ~132 items en retrait pendant + **2 notes-listes** regroupées
  (§ 4.4.2 voltige, 1 en section VI) ; **texte préservé au caractère près** (diff sans balises = vide sur les
  9 pages) ; nav règle de `manuel.html` intacte ; refs planches + index recherche OK. Rendu de la **page réelle**
  vérifié par capture Chrome headless (voltige = 1)/2)/3) dans un seul encadré, conforme au scan).
  - ⚠️ **Toute modif du rendu passe par le filtre/CSS puis un rebuild**, jamais par les `pages/manuel/*.html`
    générés (écrasés au prochain build).
- **3e correctif — numérotation d'origine restaurée (DOCX + site).** Constat (scan = source de vérité,
  PDF p. 22-23 § 1.6.2/1.6.3) : la transcription DOCX avait rendu deux **listes numérotées « 1) 2) 3) »**
  d'origine en **puces tiret**. Corrigé **à la source (DOCX)** puis régénéré :
  - Outil `scratchpad/docx_fix.py` (réutilisable, piloté par spec JSON) : chirurgie XML ciblée sur
    `word/document.xml` — retire le `<w:numPr>` de l'item visé et préfixe le marqueur d'origine « N) » ;
    sauvegarde `.orig` auto, écriture atomique, idempotent. `FOUGA_CM170_Section_I_Description.docx` corrigé
    (§ 1.6.2 « bouton de test » 1-3 ; § 1.6.3 « Remarques freins » 1-3). Backup : `*.docx.orig`.
  - Une fois le DOCX en « N) » texte, ma règle `numitem` fait le reste au rebuild (retrait pendant).
  - **Audit complet des 8 sections** (workflow, un lecteur/section confrontant HTML ↔ pages scan) :
    **aucune autre** liste `<ul>` à convertir — les 222 puces `<ul>` sont d'**authentiques tirets** de
    l'original, et toutes les vraies listes numérotées/lettrées étaient déjà en `numitem`. **Le défaut
    n'était pas systémique** (2 listes seulement).
  - **Régression corrigée** (débusquée par l'audit) : ma règle `numitem` prenait « 110 - 120 nœuds » (§ 2.9)
    pour un marqueur « 110 - » → motif tiret durci (doit être suivi d'une **lettre**, pas d'un chiffre).
- **4e correctif — typographie des tirets (DOCX + site).** Le manuel d'origine est **dactylographié**
  (machine à écrire = seulement le trait d'union « - ») ; confirmé sur le scan de la table des matières
  (« 3.1. - Réacteurs », « 69 - Vitesses… - Petits bidons »). La transcription avait introduit **272**
  tirets cadratins « — » / demi-cadratins « – ». Ramenés tous à « - » **dans le corps** (outil
  `scratchpad/dash_fix.py`, backup `.predash`), en **excluant le bloc-titre** du transcripteur (« Manuel
  de l'équipage — Partie Texte », « CHAPITRE… », stripé du HTML de toute façon). ~261 remplacements
  (Section II 159, Liminaires 63). **Effet de bord bénéfique** : les marqueurs de checklists « 1 – Etat
  de la calotte… » redeviennent « 1 - » et **repassent en items numérotés** (`numitem`, retrait pendant) —
  Section II passe de ~20 à 159 `numitem`. **Vérifs** : rebuild OK ; **texte identique au caractère près**
  (tirets normalisés, aucun mot perdu — seules diffs = les « 1) 2) 3) » du 3e correctif) ; le corps du
  manuel ne contient **plus aucun** « – »/« — » (les tirets longs restants du HTML sont 100 % de la
  **chrome du site** : en-têtes « Section I — Description », tooltips « Planche 47 — Poste… », colophon) ;
  rendu réel vérifié par capture Chrome headless.
  - **Point de design laissé tel quel** (à trancher) : la puce CSS de niveau 1 est un « – » (en-dash) —
    `li::before{content:"–"}` — alors que l'original a « - ». C'est un **choix graphique du site**
    (hiérarchie –/·/◦ documentée), distinct de la fidélité du texte ; passable à « - » en une ligne de CSS
    si l'on veut coller au dactylographe.
  - § 5.1.6 : `<ul>` dont le scan use des marqueurs « . » (points) — laissé en tiret (marqueur non standard,
    hors typographie des tirets).

**2026-07-18 — Bibliographie sélective : ajouts d'ouvrages & nouvelle rubrique articles**
- **Ouvrages ajoutés** (détails vérifiés par recherche + fetch, comme le reste de la biblio) : *Le Fouga sous
  toutes ses couleurs* (Rambeau ; Moreau ; Audouin — Addim, 1993) en **Section I** ; *CEAM… une histoire de
  l'Armée de l'air* (Pena — Histoire & Collections, 2014) et *Planeurs et avions… Robert Castello… Éts Fouga*
  (Castello — Le Lézard, 1993) en **Section II**.
- **Nouvelle Section IV « Le Fouga dans la revue *Le Fana de l'Aviation* »** insérée après les Articles ; les
  sections suivantes **renumérotées V→VIII**. 29 articles « consacrés au Fouga » (Magister/Zéphyr) + 6
  « contexte » (sélection) sous un sous-libellé (`.bs-sub`, **nouveau style dans `site.css`**). Données
  nettoyées des annotations de catalogage (Index, [1], notes ODS, descriptions A/B/C, « Maquette Heller »)
  et **harmonisées au style maison** : « NOM, Prénom. », titres entre « … », revue en *italique*, **« no »**
  (la biblio existante n'emploie pas « n° »), anonymes commençant par le titre ; insécables posées par le
  script typo `.biblio`. Rendu vérifié (details ouvert temporairement puis refermé).
  - Laissés en attente : **entrée C** (« renvoi apparenté » Super Magister CM 1070) **écartée** — vide de sens
    une fois l'annotation Index retirée, et « non Fouga strict » ; le sous-groupe « contexte » ne contient que
    les **6 exemples** fournis (les **51 références complètes sont dans les fichiers ODS de Valérie**, non
    transmis). Soft points : ville de « Le Lézard » introuvable (entrée sans ville) ; pagination Castello
    329 p. (catalogues).

**2026-07-18 — Bandeau d'avertissement étendu aux instruments**
- Le bandeau `.avertissement` (« prototype… peut comporter erreurs… ne convient pas à un vol ») apparaît
  désormais aussi sur les **4 enveloppes** `computeur.html`, `computeur-virtuel.html`, `regle-navigation.html`,
  `regle-navigation-virtuelle.html` — inséré entre la sous-nav et le `<main>`/iframe (même markup/style que
  l'accueil, ces pages chargeant déjà `site.css`). ⚠️ Pages **maintenues à la main** → pas de rebuild, pas
  d'écrasement. Non ajouté à `monographie.html` (document, pas prototype).

**2026-07-18 — Contraste des heros (mode d'emploi computeur & règle)**
- Titres crème peu lisibles sur les photos d'instruments argentés. Sur les heros de `pages/mode_emploi.html`
  et `pages/regle_navigation.html` : photo assombrie (`filter … brightness(.8)`), voile dégradé plus dense
  sous le titre (.76 à 60 %, .96 en bas), **ombre de titre resserrée** (`0 1px 2px .6` + halo, au lieu du halo
  diffus `0 2px 30px .4`), lede en `weight:400` + ombre. Rendu vérifié par capture ; réglage identique sur les
  deux pages (ajustable au `brightness` page par page si besoin).

**2026-07-20 — Mode d'emploi computeur : échelles des courbes de croisière**
- Bug de présentation (pas de données) dans les 4 courbes SVG de la grille de croisière
  (`pages/mode_emploi.html`, IIFE `cruise-charts`) : axe Y tronqué à min−10 % avec **ligne du bas
  pleine** → lue comme un zéro (distance ×1,6 perçue ×4 ; conso ÷2,2 perçue ÷6,5), graduations
  non rondes (245/505/765/1025). Corrigé : graduations rondes (`niceStep` 1/2/2,5/5×10ⁿ),
  **ancrage à zéro si min/max < 0,6** (Conso, Distance), resserré sinon (TAS, Rendement — un axe
  zéro les écraserait) ; trait plein réservé au vrai zéro ; note d'axes sous la légende.
  Données des courbes revérifiées ≡ tableaux ≡ computeur virtuel (aucune erreur).
- ⚠️ Relevés au passage (non corrigés, à trancher) : le panneau « Rendement » est exactement
  TAS/60 (redondant, et il est **plat** alors que le chapô promet un « meilleur rendement en
  altitude » — le vrai rendement km/L n'est pas gravé sur l'instrument) ; IAS 260 kt à
  20.000 t/m / 5.000′ (écart IAS−CAS de 18 kt, partout ailleurs 6–12 kt).

**2026-07-20 — Vérification de la grille de croisière contre les photos (workflow, 77 agents)**
- **Triptyque cohérent** : site ≡ monographie DOCX ≡ monographie PDF, cellule par cellule (3×7×8).
- **La fiche de relevé brute `SITE/computeur_131_grille (1).docx` est fausse** sur le régime
  19.000 t/m : altitudes décalées d'un cran (affectation avouée « par ordre de consommation
  croissante », heuristique) et temps 1 h 26 à 20.000 t/m / 20.000′ (calcul et photos ⇒ 1 h 20).
  La monographie avait déjà redressé — **ne pas « corriger » le site d'après cette fiche**.
- **Photos = arbitre** (32 clichés `SITE/IMG_3549–3599.jpeg`, 20 vues de fenêtres, chaque lecture
  contre-vérifiée par 2 relecteurs adverses dont un dédié au cran de couronne) : affectations
  confirmées, dont le point litigieux 30.000′/400 L au régime 20.000 (verrouillé par TAS/CAS =
  1,60 ⇒ σ≈0,39 ⇒ ~30.000 ft) ; fenêtre vierge attendue à 19.000 t/m / 30.000′ (gravure 336 :
  « Si Z<30.000′ afficher 19.000 T/m »). Détail par cliché : sortie du workflow
  (`tasks/wkqkz4v2o.output` du scratchpad de session). Compte-rendu de couverture cellule par
  cellule **encore à rédiger/publier** (notes sur la page).

**2026-07-20 — Réglette cartographique : échelle de la face 336 (photo à l'appui)**
- La face 336 porte, gravé sur les deux bords de la plaque : « Km. Echelle **1/500.000ᵉ** » et
  « MILES NAUTIQUE Echelle 1/500.000ᵉ » (photo fournie par Valérie ; la fiche brute le disait déjà).
  La monographie et le site ne connaissaient que le 1/1.000.000ᵉ (face 131).
- Corrigés : cadre C de `pages/mode_emploi.html` (les deux échelles par face) ; monographie DOCX
  en 3 passages (§ I, § III.3, § IV synthèse) par remplacement XML garde-fou « occurrence unique »
  (script `scratchpad/fix_mono.py`) ; PDF régénéré.

**2026-07-20 — Monographie illustrée + date de version (DOCX & PDF)**
- **6 photos de l'instrument insérées** dans le DOCX (script `scratchpad/add_images.py` : gabarit
  `<w:drawing>` cloné, rels + `[Content_Types]` jpg, légendes italique gris) : face 131 (§ I),
  fenêtres 131 (§ II.1), abaque Montée/Descente (§ II.2), face 336 (§ II.3), Distance max (§ II.4),
  couronne litres (§ III.1). **Date de version** en page de titre (« Dernière mise à jour —
  20 juillet 2026 » — à tenir à jour à chaque édition). 12 → 17 pages.
- ⚠️ **Orientation volontaire** : les 3 photos portrait sont dans l'orientation d'**usage**
  (fenêtres/valeurs à l'endroit, bandeau « COMPUTEUR » tête-bêche) — identique au site. Ne pas
  les « redresser » : cela retournerait les données.
- **Chaîne PDF** : LibreOffice headless (`soffice --headless --convert-to pdf`) reproduit la mise
  en page à l'identique **mais n'y recompresse pas les JPEG** (14,9 Mo) → Ghostscript
  `-dPDFSETTINGS=/ebook -dColorImageResolution=150` ⇒ **647 Ko**, petits chiffres vérifiés
  lisibles. Recette complète pour les prochaines éditions : modifier le DOCX → soffice → gs.
- Backups (DOCX/PDF d'origine + pré-images) déplacés **hors du dossier publié**, dans le
  scratchpad de session (`backups_docs/`).

**2026-07-21 — Accueil : vue de dessus du rail 3-vues corrigée**
- `assets/img/fouga_dessus.png` était **amputée du bord d'attaque à l'emplanture droite**
  (effacement collatéral du dessin voisin lors de la découpe du plan `../magister_3v.jpg`, dont la
  vue de dessous mord sur cette zone) + pointe d'antenne de queue écrêtée + fragment de roue de la
  vue de profil flottant en haut à droite. **Regénérée depuis l'original** (script PIL : découpe
  large, masques d'effacement des voisins, encre RGB 51/45/28, rampe alpha calée pour conserver les
  verrières grisées — gris 223 → alpha ≈ 41 comme l'ancien). Vue de dessous contrôlée : saine.
  Ancienne image dans `backups_docs/` (scratchpad de session).

### Pistes non traitées (site)
- **Computeur — suites de la vérification photo (20/07)** : rédiger/publier les notes sur la page
  (couverture cellule par cellule de la grille : quelles cases sont attestées par un cliché lisible) ;
  trancher l'**IAS 260 kt** à 20.000 t/m / 5.000′ (écart IAS−CAS de 18 kt, ailleurs 6–12 — chercher le
  cliché de cette fenêtre) ; panneau « **Rendement** » des courbes = TAS/60 (redondant et contredit le
  chapô) → renommer « Distance parcourue par minute » ou supprimer. Détail des relevés :
  `tasks/wkqkz4v2o.output` (scratchpad de session).
- **Monographie** : date de version en page de titre (« Dernière mise à jour — 20 juillet 2026 ») à
  tenir à jour à chaque édition ; recette PDF = soffice --headless puis ghostscript /ebook 150 dpi.
- Drag de la couronne directement depuis les étiquettes d'altitude ; molette souris.
- Factorisation de la charte dupliquée dans les pages internes du computeur.
- Recette mobile complète (le responsive est en place mais non testé sur appareil).
- ~~Règle virtuelle → règle complète~~ **FAIT** : transition réalisée le 22/07 (clichés reçus) puis
  **fidélité pixel le 23/07** (recto, verso, réglette Victor — voir mise à jour 23/07 et
  `REGLE_VIRTUELLE_transition.md` points 1–7). Restes éventuels : verso de la coulisse recto
  (bandes VP) sans macro dédiée du curseur sain ; polices (Spline Sans Mono vs grotesque gravée)
  assumées comme choix du site.
- **Bibliographie** : trancher [1]/[5] (même page musée), [4] (site amateur de vol virtuel), [7]/[9]
  (préciser ou retirer) ; numérotation sans [3].

---

*Mise à jour 18/07/2026 — §8 étendu : nouveau sous-sujet « Règle de navigation »
(mode d'emploi + règle virtuelle interactive, Marboré II & VI ; construits par extraction fidèle des
photos + revue adversariale, 0 erreur de données), objectivation des notices (retrait de la conduite
de vol), page de présentation (avertissement « prototype non diffusable » + illustrations 3-vues en
marge), bibliographies (vérification web par fetch + « Bibliographie sélective » de 53 entrées +
typographie insécable). Volet transcription DOCX inchangé : restent le document maître et l'étude.*

*Compléments 18/07/2026 (suite) : (1) **règle virtuelle** vérifiée (données 100 % fidèles, calculs exacts)
avec la spec de transition `REGLE_VIRTUELLE_transition.md` ; (2) **manuel HTML** — retrait pendant des items
numérotés/lettrés, regroupement des NOTA multi-paragraphes, **restauration de la numérotation d'origine**
de 2 listes (DOCX corrigés via `docx_fix.py`, backups `.orig`) après **audit des 8 sections** (défaut non
systémique), et **typographie des tirets** ramenée au « - » du dactylographe (272 corrigés via `dash_fix.py`,
backups `.predash`) — texte préservé au caractère près, rendus vérifiés par capture ; (3) **bibliographie
sélective** — 3 ouvrages + nouvelle **Section IV** (articles du *Fana de l'Aviation*, renumérotation V→VIII) ;
(4) **bandeau d'avertissement** étendu aux 4 pages computeur/règle ; (5) **contraste des heros** computeur &
règle renforcé. Outils réutilisables dans `FOUGA_CM170_COLLECTE/` (scripts) et `scratchpad/`.*

*Mise à jour 20/07/2026 : (1) **courbes de croisière** du mode d'emploi — échelles corrigées (axes
zéro/graduations rondes ; données déjà exactes) ; (2) **vérification photo de la grille** (workflow
77 agents) — site ≡ monographie confirmés par les clichés, **fiche brute `computeur_131_grille (1).docx`
invalidée** (décalage d'altitudes au 19.000 t/m) ; (3) **échelle 1/500.000ᵉ de la face 336** (gravée sur
la plaque, photo à l'appui) reportée dans le cadre C du mode d'emploi + monographie (3 passages) ;
(4) **monographie illustrée** — 6 photos + date de version dans le DOCX, chaîne PDF
soffice → ghostscript (647 Ko).*

*Mise à jour 21/07/2026 : vue de dessus du rail 3-vues de l'accueil regénérée depuis
`../magister_3v.jpg` (bord d'attaque d'emplanture droite restauré, antenne complète, fragments
voisins effacés) — voir l'entrée du journal §8.*

*Mise à jour 22/07/2026 — **règle de navigation, refonte complète** (sources primaires arrivées
dans `../RdN_Cne_Claude/` : notice d'époque 13 p. « la règle de navigation du Capitaine CLAUDE »
= chap. 4 d'un cours d'escadron, scans A4 300 dpi avec réglet, 4 photos HD corps/réglette à plat ;
dépouillement par workflow 9 agents + recoupement adversarial + 3 contre-vérifications macro,
plan dans `REGLE_REFONTE_plan.md`) : (1) **`pages/regle_navigation.html` réécrite** en 7 sections —
anatomie corrigée (2 pièces, pas de curseur ni de « position de repos »), **abaque de montée
tabulé** (temps/distance/carburant, axe gravé = distance Nm), repères ●/★ des 7 fenêtres relevés
(★ ≈ 220 constant), **mode d'emploi officiel a)–k)** avec exemples d'origine et coquilles
signalées, **face « Victor »** du verso de la réglette (rapporteur demi-limbe double numérotation,
réglettes 240/280 kts, IFF 3/A 13-77, carte refuge FL 55/115, fréquences 383,7/384,5/384,7) ;
(2) **règle virtuelle « complète »** (`REGLE_VIRTUELLE_transition.md` §E réalisé) : échelle mobile
réelle 10→1500 / 1→150 + flèches de conversion, **fenêtres traversantes `<clipPath>`** lues par
translation unique, échelles commensurables (TMAX = 100 min = gravure 1⁴⁰ → 220 px/décade partout),
lecture au **repère 60** (les exemples de la notice tombent juste : 262→Vi 190 au FL 200 ;
272→M 0,45 au FL 250), montée sur axe distance + carburant, débattement réel, vent borné 0–90° ;
smoke tests jsdom 20/20 ; (3) **monographie de la règle** : `Fouga_CM170R_regle_de_navigation.docx`
(généré par script npm `docx`, gabarit computeur : Lettre, DejaVu Sans, en-tête petites capitales,
12 p., 5 photos) + PDF ghostscript 358 Ko + enveloppe `regle-navigation-monographie.html` +
**sous-nav règle à 3 entrées** (3 fichiers) ; (4) **notice d'époque hébergée**
(`assets/docs/Fouga_CM170R_regle_notice_1980.pdf`, 1,65 Mo, liée depuis la page mode d'emploi) ;
(5) 4 nouveaux clichés à plat dans `assets/img/` (`regle_corps_*`, `regle_coulisse_*`).
Arbitrages de données consignés dans le plan : réglette 1/100 000 = **280 kts** (géométrie 1′30 = 7 NM),
fréquences carte = **38x,x** (scan tranche), correction Pb VI = **− 0,5 confirmé** (la lecture − 0,8
sur IMG_3703 était un artefact de la zone abîmée).*

*Complément 22/07/2026 (soir) — **photos de la page règle** : les 4 clichés à plat étaient servis avec
un **tag EXIF orientation=6 mensonger** recopié des HEIC par sips → les navigateurs les pivotaient en
bandes verticales de ~3 000 px (« images immenses » signalées par Valérie). Régénérés via **Pillow**
(décodage brut + rotation +90, zéro EXIF — recette : scratchpad session `venv` + script dans le journal) ;
ajout de **9 zooms de zone** `regle_zoom_*.jpg` (façon face131_*/face336_* du computeur) utilisés par les
figures de détail de `pages/regle_navigation.html`, et **plafond de hauteur CSS** (`.plate img` 300 px,
`.figure img` 320 px, largeur auto centrée). Les 4 vues d'ensemble restent en pleine page plafonnée.*

*Complément 22/07/2026 (océrisation notice) — **transcription DOCX fidèle de la notice 13 p.**
→ `../RdN_Cne_Claude/mode emploi règle Fouga - transcription.docx` (à côté du PDF source).
Méthode : lecture visuelle page à page du PDF (aucune couche texte), **python-docx** (venv scratchpad
session, `build_docx.py`), Courier New 10, **pagination 1:1** avec l'original (13 p. + 1 p. de notes ;
⚠️ sauts de page via `page_break_before` sur le 1ᵉʳ paragraphe de chaque page — un paragraphe de saut
dédié crée une page blanche après les pages pleines). **19 figures** découpées du scan et réinsérées à
leur place (`crop_manual.py` : pdftoppm 150 dpi + bandes y manuelles + rognage auto PIL — la détection
automatique par longueur de traits ou densité de gris **échoue** sur cette photocopie pointillée/pâle).
Fidélité : coquilles **conservées** avec appels de note en exposant ; **12 notes de transcription** en
fin de document, alignées sur §1.13 du plan (en soit, Vi 200 vs ● 195, dittographie DMF, astérisque=VI,
37′20″→37′12″, « est » manquant, sol225, valeur 15→20, « 43 Kts » dupliqué, consommablessoit, ave→avec,
scories). Non signalés à dessein : « 1/100000 · 280 Kts » (conforme à l'objet, cf. arbitrages) et
« vertical une balise » (jargon aéro normal). Typo : **91 insécables** posés (après « , avant » , devant
: ; ! ?) à la demande de Valérie. Contrôle : conversion LibreOffice → PDF, 14 pages, aucune blanche,
relecture visuelle intégrale.*

*Mise à jour 23/07/2026 — **règle virtuelle : fidélité pixel de l'instrument** (journée de passes
successives sur retours de Valérie, tout mesuré par **analyse d'image des scans 400 dpi à plat**
`../RdN_Cne_Claude/règle Fouga.pdf`, chaque passe vérifiée par **rendu Chrome headless** comparé au
scan ; détail complet en tête de `REGLE_VIRTUELLE_transition.md`, points 1–7) :
(1) **zone centrale recto** — échelles des minutes PARALLÈLES pleine fenêtre (1′ sous 10′, 6′ sous
le 60 cerclé, module unique ≈ 105 mm/décade, `tx` piecewise), graduations réelles (½′/1′/5′ en haut,
5″/15″/30″ en bas, chiffres alternés grands/petits), **double lumière** à barrette
« — VITESSE —— PROPRE — » finissant en **flèche-index** sous le 60 (trait rouge ET curseur pointillé
supprimés — notice 4.3.1 : pas de curseur), bandes re-gravées **trait par trait** (rail haut/bas,
chiffres mêmes stations ×1/÷10, flèches Pieds 32,8 / Naut 54 / Unités métriques gravées sur la
coulisse à queues courtes ; piège : le « 16 » lu sur photo = **10** usé, prouvé par le pas log) ;
(2) **hauteur & partie gauche** — viewBox 1180×430, face aux **proportions réelles ≈ 3,2:1**
(module 510 px/décade), tableau resserré aligné sur les 7 fenêtres Vi (entraxes réels, FL150 à
l'aplomb de la barrette), **grosses flèches pleines**, ligne-index continue, **grande accolade**,
légende tournée « Distance Maximum Franchissable Gb », bloc **Pb →** gravé, **Mach empilées**
FL300/FL250 à index commun (0,01/0,05/0,10), **Cons. graduée fine** (0,1/0,25, tous entiers
chiffrés) ; **arbitrage ferme** : la colonne des FL est une gravure FIXE (7 rangées FL300→1 000 ft
dans TOUS les modes, l'endurance ne substitue que les cellules) et ne jamais réduire les titres ;
(3) **abaque de vent refait** — origine en BAS-GAUCHE, grille perpendiculaire pas de 5 bornée au
limbe, force 20→50 chiffrée **au centre des angles**, rangée « dérive → » 1°→10°, **verticales
communes** vers l'abaque VP 300→100 (rayons 1°→10° + 12°/15°/20°), textes exacts (« angle direction
du vent et route à suivre », « V P » devant l'accolade) ; (4) **verso refait** — montée à double
réglet Nm au ras des chants (VI haut / II bas, cotes de paliers, « CARBURANT RESTANT » et litres en
écriture tournée sur pointillés, temps Pb dessus / Gb dessous), tableau **ENDURANCE MAX encadré à
l'identique** (cartouche à cheval, Régime/Conso l/m, VITESSE, SECURITE à accolade, DESCENTES
ECO/PERCEE) ; (5) **réglette sortie = image virtuelle À PART** (`svgC` sous le flip) — face
« EXECUTION DES VOLS COM TYPE VICTOR / EN TRES BASSE ALTITUDE » complète : **rapporteur concentrique
au chant** (moyeu au centre de la courbure, couronne 5°/10° strictement 180→360, chiffres radiaux
rot 90−a, **demi-rose gauche 0→180 à un rayon par 10°** — jamais de rose 360°), réglettes
**1/500 000 · 240 kts** (quarts/demies/minutes + rangée NM) et **1/100 000 · 280 kts** inversée
(NM/demi-NM + chant aux 5″), JOUR/NUIT (500 m/5 km, 800 m/10 km), IFF mode 3/A 13-77, **carte de
France au contour géographique** (598→766 × 126→298 mesurés, ligne mixte débordante, FL 55/FL 115 +
383,7/384,5/384,7), procédure d'urgence — textes grossis aux tailles du scan ; (6) **aide au geste**
(choix Valérie « main + amorce ») : main 👆⟷ oscillante + aller-retour réel de la coulisse au
chargement, disparition au premier geste ou 6,5 s, `prefers-reduced-motion` respecté.
⚠️ Méthode qui a fait ses preuves : **jamais à l'œil** — mesurer sur le scan (détection de traits
par script), rendre, **comparer côte à côte à échelle identique**, itérer. Harnais de test
**pérennisé** dans `FOUGA_CM170_COLLECTE/outils_regle_virtuelle/` (domstub.js + render.js +
LISEZMOI avec la recette complète : extraction du script, smoke test node, rendu Chrome headless,
facteur scan→SVG ≈ 0,302).*

*Complément 23/07/2026 (soir) — **règle virtuelle : re-contrôle des tables & calculs + refonte de la
section « Fidélité »** : (1) **re-contrôle indépendant** (demande Valérie) — constantes JS de
`pages/regle_navigation_virtuelle.html` recoupées contre la transcription du mode d'emploi ET la
face 336 du computeur virtuel : **conformes cellule par cellule** (distance Gb + correction Pb
−200/−500 & −0,5, endurance II/VI 5→25 ≡ face 336 pour II, montée 4 courbes temps/distance/carburant
avec recoupement notice §4.2 à FL 200, descentes, sécurités) ; **calculs numériquement exacts** —
d = V·t/60 et inverses redémontrés sur la géométrie log de bout en bout (module commun, bande basse
÷10 juste pour 1′→10′), correction Pb soustractive arrondie au dixième, vent W·cos A / asin(W·sin A/VP),
descentes taux × altitude bornée 0–30, facteurs `FL_F` retombant sur les 4 exemples de calage de la
notice + atmosphère standard, `MACH_A` 589/604 kt = vitesse du son FL 300/250. Micro-remarques
laissées en l'état : « +0 arrière » affiché à 90° (grandeur nulle), « ≈ » des distances II-Pb
(≈ 10 / ≈ 70 Nm du mode d'emploi) non signalés dans le readout montée (seule la cote 4′ l'est),
deux gardes `vp-cursor` mortes (inoffensives depuis la suppression du curseur). Au passage :
« ENDURANCE MAX » = terme de la gravure elle-même (cartouche verso + face 336), objectif
complémentaire de la DMF — minutes par litre à 140/150 kt, contre milles par litre. (2) **Section
« Fidélité à la règle d'origine » restructurée** (retour Valérie : pavé illisible) : les deux cartes
passent en **pleine largeur** ; l'inventaire « Relevé sur l'instrument » éclaté en **5 groupes
titrés par zone** (`.fzones`/`.fz` : Recto · tableaux & fenêtres, Règle à calcul · corps & coulisse,
Abaque de vent · curseur, Verso du corps, Réglette sortie · face Victor) en grille responsive
(minmax 320 px) ; « Reconstruit ou approché » en **liste 2 colonnes** (`.flist`). Contenu factuel
**conservé à l'identique** (aucun fait perdu ni reformulé), paragraphe d'introduction inchangé ;
le script de typographie française couvre les nouveaux nœuds. Balisage vérifié équilibré ;
⚠️ capture Chrome headless **non réalisée** dans la session (lancement bloqué, Chrome de bureau
ouvert) → un contrôle visuel au rechargement reste à faire.*

*Point d'étape du 23/07/2026. En suspens (computeur) : notes à publier —
couverture cellule par cellule de la grille, IAS 260/242, panneau « Rendement » = TAS/60 ;
voir « Pistes non traitées ». En suspens (règle) : macro dédiée du titre raturé de l'abaque de
vent (lecture retenue « angle direction du vent et route à suivre ») ; attribution du cercle 4′
à FL 50 (II-Pb, géométrie) ; décimale éventuelle du « 9 l/m » FL 150 sous la fissure ; verso de la
coulisse recto (bandes VP) si un curseur sain est photographié un jour ; contrôle visuel de la
nouvelle section « Fidélité » (capture headless non réalisée le 23/07 au soir).*

**2026-07-24 — Mode d'emploi computeur : couronnes de conversion de la face 336**
Section IV (« La règle à calcul ») de `pages/mode_emploi.html` enrichie d'après IMG_3593.jpeg
(vue d'ensemble face 336, photos font foi) : (1) nouveau bloc « Les couronnes de la face 336 »
avec l'organisation concentrique — pourtour fixe NAUT. ↔ ST. MILES (cartouche « 60 » à encoche)
en haut, couronne ALTITUDE VRAIE, couronne intérieure VITESSE CORRIGÉE (libellés vers la
graduation 45), échelle mobile au bord du disque ; (2) tableau « Repères de conversion gravés
sur le pourtour » : UNITÉS MÉTRIQUES (« 10 », à droite), PIEDS (à gauche, entre 30 et 35 ≈ 32,8),
PSI (≈ 14,2) puis VITESSE PROPRE (libellé 15–17) en bas, GAL. U.K. (≈ 22) et GAL. U.S. (≈ 26,4) ;
(3) encart « règle de trois gravée » (1 NM ≈ 1,15 SM ; 10 m = 32,8 pieds ; 100 L = 22 gal UK
= 26,4 gal US ; 1 kg/cm² ≈ 14,2 PSI) ; (4) ligne TAS du tableau des opérations précisée
(couronnes VITESSE CORRIGÉE / ALTITUDE VRAIE, lecture au repère VITESSE PROPRE). Nouvel asset
`assets/img/face336_couronnes.jpg` (recadrage IMG_3593 redressé, Pillow sans EXIF, 1561×1600).
Rapports cohérents relevés : 100 km = 54 NM = 62 SM (sur la photo, couronne calée 60 sous
ST. MILES, pas au neutre). **À venir (demande Valérie)** : passe de corrections sur
`pages/computeur_virtuel.html` pour une **réplique exacte des deux faces** — écarts déjà notés
au verso virtuel : NAUT. à 52 / ST MILES à 60 (à confronter au couple 54/62), repères PSI,
VITESSE PROPRE, GAL. U.K./U.S. absents, double couronne ALTITUDE VRAIE + VITESSE CORRIGÉE
non modélisée.

**2026-07-24 (soir) — Computeur virtuel : réplique exacte des deux faces**
Refonte de `pages/computeur_virtuel.html` sur relevés photographiques (workflow 6 agents, ~1,1 M
tokens : triage des 33 photos, structure des anneaux par déroulé polaire, positions d'index au
comptage de graduations, motif des pas, fidélité recto, transcription verso signe à signe).
MODÈLE ÉTABLI (verso 336) : deux pièces seulement — plaque fixe (échelle haute noire sur clair,
noms gravés VITESSE PROPRE et ALTITUDE VRAIE, TOUS les cartouches/index) et disque central mobile
(couronne noire = échelle basse VITESSE CORRIGÉE, solidaire de la table ; pastille 10 ovale,
fenêtre 60 à chevron). Index mesurés : UNITÉS MÉTRIQUES 10,00 · P.S.I. 14,2 · GAL. U.K. 22,0 ·
GAL. U.S. 26,4 · PIEDS 32,8 · NAUT. 54,0 (52,2 exclu) · fanion 60 = repère minutes · taquet
ST MILES mesuré ≈62 (mesure complémentaire 61,9 ±0,2 sur IMG_3593/3595), rapport exact 62,14
retenu (54 × 1,151). VITESSE PROPRE n'est PAS une flèche-index : c'est le nom de l'échelle
(chiffre 16 enchâssé). Toutes les photos verso sont en coïncidence neutre 10/10.
IMPLÉMENTATION : échelles génératives fidèles (pas 0,1/0,2/0,5/1, la couronne garde 0,5
jusqu'à 60, chiffres coupés par leur trait « 1|4 », demi-décades), cartouches aux formes relevées,
mentions gravées exactes (« .DISTANCE. Max. », « .30.000′ _ 20.000 T/m. », fractions verticales
Vi 5/10, Régime partagé sans trait avec « — » à droite du rivet, « Si<350ℓ garder Z », Nº 336
« au feutre »), rotation du disque entier (drag/clavier, aria-slider complet), outils : lecture
sous chaque index, conversions par paires d'index, repère 60 (V sous le fanion, d = V·t/60),
calage CAS→TAS (σ standard). Recto : graphies exactes (VI Turbulence = 210Kts, REACTEURS MARBORE II,
.ETABLI PAR LA B.A 709. .COGNAC., légende ▲ 3 lignes, bloc accolade avec « roulagé). » d'époque,
4 lignes Rem.gaz/G.C.A), couronne à cartouches en arc « ▲455Litres .25.000 pieds. » + pavés,
« 131 » et tampon-logo PNG retirés du disque, silhouette gravée ajoutée. Mode d'emploi mis en
cohérence (taquet ST MILES, fanion 60, VITESSE PROPRE nom d'échelle, graphies ST MILES/P.S.I.,
« échelle haute/basse », tirets d'incise purgés de la page). VÉRIFICATION : workflow adversarial
4 agents → 30 constats, tous traités sauf 2 rejetés motivés (suppression du taquet : réfutée par
mesure directe ; double logo : faux positif) et 1 différé (réglettes des bords de plaque, hors
cadre circulaire du virtuel). Banc d'essai headless : 11/11 tests verts (conversions, repère 60,
TAS, reset, recto). Captures : recette Chrome headless QUI MARCHE malgré Chrome de bureau ouvert :
profil neuf + --no-sandbox --disable-dev-shm-usage --timeout=20000 --virtual-time-budget + attente
par polling (le lancement direct pend sinon). Nouveau : paramètre d'URL `?face=verso` à l'init.
Assumé (réinterprétations affichées comme telles) : fenêtre de lecture moderne au recto (pas de
secteur en éventail à fenêtres biseautées), lunette laiton décorative, pas de plaque rectangulaire.

**2026-07-24 (nuit) — Recto 131 : secteur en éventail mécanique (demande Valérie)**
La « fenêtre de lecture » moderne (tableau rectangulaire central) est REMPLACÉE par le mécanisme
réel relevé sur face131_vue.jpg / face131_disque.jpg : secteur en éventail au bas de la plaque
fixe (7 bandes RÉGIME → TEMPS DE VOYAGE, noms des grandeurs gravés à gauche de la fenêtre, unités
à droite — TOURS/MINUTE, Litres Heure·Minute, NOEUDS à cheval sur Vi/Vc, KM Heure·Minute, KM.,
Heures et minutes), fenêtre en coin biseautée (clipPath, technique de la règle virtuelle) et zone
hachurée adjacente. Les valeurs de la grille `D` sont gravées sur un disque solidaire de la
couronne : 21 colonnes (3 régimes × 7 calages, pas 360/21 ≈ 17,14°), colonne 19.000 t/m / 30.000′
vierge comme sur l'instrument. Sélection MÉCANIQUE conforme aux photos : le cartouche choisi vient
face à la fenêtre EN BAS (plus d'alignement en haut), cartouches regravés « orientés fenêtre »
(tête-bêche en haut de face, à l'endroit près de la fenêtre — identique aux photos), index rouge
déplacé sur la lunette en bas, glisser possible sur la couronne ET sur la fenêtre, encliquetage
sur la colonne la plus proche, flèches = cran par cran (aria-slider 21 crans), boutons de régime
du panneau = rotation d'un cran. Le panneau latéral (table, grands cadrans, comparer au calcul,
note fenêtre vierge) est conservé et reste synchrone. Interprétations nouvelles, non tranchables
sur les 2 photos : ordre 19/20/21 autour du cartouche (19.000 côté anti-horaire), zone hachurée
purement décorative, bandeau COMPUTEUR maintenu à l'endroit (l'original est tête-bêche par rapport
à l'éventail). Vérifié par captures headless : défaut 20.000/20.000′ (450·7,5/205/197/492·8,2/
631/1h20), 21.000/SOL (960·16,0/298/286), 19.000/30.000′ (fenêtre vierge + note), verso intact.
IMPORTANT capture : l'URL file:// doit être ENCODÉE (espaces + apostrophe de « Fouga z'elles »,
via `urllib.parse.quote`), sinon Chrome sort en exit 0 SANS écrire le PNG ; harnais d'interaction
= page iframe (src encodé) + `--allow-file-access-from-files`, appel de `selectCol(z, reg, false)`
dans la frame.

**2026-07-24 (nuit, 2ᵉ passe) — Recto 131 : éventail relevé EN HAUT (arbitrage lisibilité, demande Valérie)**
Sur retour immédiat de Valérie (« textes dans l'autre sens et volet en haut »), l'orientation
« fenêtre basse » de l'original est ABANDONNÉE au profit de la lisibilité : le secteur en éventail
est relevé au haut de la face (fenêtre en coin sous l'index rouge, revenu en haut), disposition
en miroir vertical (noms des grandeurs toujours à gauche, unités à droite, hachures entre fenêtre
et unités), et TOUTES les gravures du recto repassent « à l'endroit en haut » (cartouches de la
couronne, libellés de l'éventail, colonnes de valeurs du disque : sélection = cartouche sous
l'index, comme avant la refonte). Conséquence : le bandeau d'identité COMPUTEUR / silhouette /
FOUGA CM 170 R / REACTEURS MARBORE II / .ETABLI… descend au bas de la face (translation +206,
aucune collision avec les légendes ni la couronne). Le mécanisme (21 colonnes solidaires de la
couronne, crans, fenêtre vierge 19.000/30.000′, panneau synchrone) est inchangé ; seuls le sens
des arcs (`arcTextB` sweep 1), les constantes `FAN` (win [−8,8], names [314,352], units [15.5,48],
hatch [9.5,15.5]), les rayons de baseline (−0,35·fs) et les cibles de rotation (−ang au lieu de
180−ang) changent. Vérifié par captures : défaut 20.000/20.000′, 21.000/SOL, 19.000/30.000′
vierge. Fidélité : l'original grave l'éventail « orienté bas » avec bandeau tête-bêche ;
c'est désormais une réinterprétation assumée de plus (l'anatomie de l'éventail, elle, reste
conforme aux photos).

**2026-07-26 — Recto 131 : le hachurage était mal interprété (correction, demande Valérie)**
Valérie signale (photo IMG_3576 à l'appui) une erreur d'interprétation du hachurage : la réplique
le dessinait en COIN FIXE DE LA PLAQUE, à côté de la fenêtre (`FAN.hatch=[9.5,15.5]`). Relevé
systématique par workflow (24 lecteurs, un par cliché IMG_3555–3576 + face131_vue/disque,
mesures angulaires autour du rivet) : le hachurage est GRAVÉ SUR LE DISQUE MOBILE ; c'est la
CASE SANS OBJET 19.000 t/m / 30.000′ (rendue « vierge » jusqu'ici), remplie d'un motif en
arête de poisson, seule case hachurée des 21 (IMG_3555/3576 : fenêtre pleine, cartouches
455/25.000 et 400/30.000 de part et d'autre ; IMG_3556 : lisière contre la colonne 20.000/30.000′ ;
IMG_3575 : liseré au bord horaire de la colonne 21.000/25.000′ = bord du même secteur ; AUCUN
hachurage sur la plaque ni ailleurs sur le disque, unanimité des 24 lecteurs). Même convention
« sans objet » que les cases hachurées de la table Distance max (§ mode d'emploi).
CORRIGÉ dans `computeur_virtuel.html` : coin de plaque supprimé, secteur hachuré gravé sur le
disque (zigzag CONTINU par bande de ligne : les chevrons plient sur les arcs, ≈45° du rayon en
haut, raidis vers le pivot, pas 2,3°, cf. photos) et il tourne avec la couronne.
Le relevé a aussi livré la STRUCTURE DES CELLULES, implémentée dans la foulée :
chaque colonne = caisson gravé (bords radiaux, arcs de bande SAUF entre Vi et Vc), paires
heure/minute et Vi/Vc décalées haut-gauche / bas-droite et séparées par un RENVOI COURBE
(apex vers le pivot ; celui de Vi/Vc enjambe deux bandes) ; « ,0 » final non gravé (« 7 »,
« 13 », « 16 » — IMG_3558/3559/3560) ; TEMPS gravé « H,MM » d'un bloc (« 1,33 » net sur
IMG_3570, virgule souvent estompée ailleurs) ; fenêtre portée à 16,8° (mesures 16,5–19°,
bords radiaux, pas de décrochement) ; caissons 13° (marges 1–2° constatées). Sur la plaque :
libellés « Litres/KM Heure · Minute » décalés + renvoi courbe entre eux (relevé photo).
Notes mises à jour (panneau virtuel + note-mini du mode d'emploi : « fenêtre vierge » →
« case hachurée sans objet »). Vérifs : syntaxe Node, captures headless côte à côte à échelle
comparable avec IMG_3555 (hachures) et IMG_3558 (caisson 19.000/SOL) — densité, chevrons,
empilement 670⟍11,2 / 233⟍225 / 422⟍7 / 446 / 1,04 conformes ; états 20.000/20.000′ et
19.000/30.000′ recontrôlés. Harnais de capture recréé (scratchpad session `harnais/capture.py`,
recette URL encodée du 24/07).

**2026-07-26 (suite) — Recto 131 : fenêtre redessinée, valeurs grossies, vraie vue de face (demande Valérie)**
(1) La fenêtre de lecture n'est plus un cadre doré rapporté : DÉCOUPE biseautée conforme aux
photos (trait de coupe sombre extérieur, tranche métallique claire `#ddd3b6`/`#efe8d2`,
filet d'ombre portée sur le disque). (2) Valeurs de la fenêtre grossies (RÉGIME 11,
valeurs 9,5, petites valeurs de paire 8, temps 8,5 — tiennent dans le caisson de 13°).
(3) La silhouette filaire du bandeau d'identité est remplacée par la VUE DE FACE du site
(`<image>` SVG → `../assets/img/fouga_face.png`, 150×35, opacité .92 ; la page référence
donc désormais un asset externe, comme les pages règle) ; bandeau desserré en conséquence
(FOUGA CM 170 R à y=447, REACTEURS/MARBORE II 461, ETABLI 475). Vérifié par captures
headless (bandeau sans collision, fenêtre 20.000/20.000′ et cas hachuré intacts).
(4) Symétrie des deux zones de libellés (retour Valérie) : la zone des unités démarrait à
+15,5° (héritage de l'ancien coin hachuré supprimé) contre −8° côté noms ; `FAN.units`
ramené à `[8,46]`, les deux zones sont au ras de la fenêtre, en miroir, comme sur l'original.

---

*Dernière mise à jour du handoff : 26/07/2026 — recto 131 : correction du HACHURAGE
(case sans objet 19.000 t/m / 30.000′ gravée sur le disque, relevé workflow 24 lecteurs,
plus aucun hachurage sur la plaque) + structure des cellules (caissons, renvois courbes,
paires décalées, « ,0 » non gravé, temps « H,MM »), fenêtre redessinée en découpe biseautée,
valeurs grossies, vue de face du site dans le bandeau d'identité, zones de libellés
symétriques au ras de la fenêtre. En suspens (computeur) : notes à publier — couverture
cellule par cellule de la grille, IAS 260/242, panneau « Rendement » = TAS/60 ; réglettes
des bords de plaque non modélisées ; décrochement éventuel du coin haut-droit de la fenêtre
(lecture minoritaire IMG_3556, bords radiaux francs retenus). En suspens (règle) : macro du
titre raturé de l'abaque de vent ; cercle 4′ à FL 50 ; décimale du « 9 l/m » FL 150 ; verso
de la coulisse recto si un curseur sain est photographié. Volet transcription : restent le
document maître assemblé et l'étude.*
