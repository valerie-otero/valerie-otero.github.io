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
| `monographie.html` | Monographie PDF consultable + DOCX téléchargeable |
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

### Pistes non traitées (site)
- Drag de la couronne directement depuis les étiquettes d'altitude ; molette souris.
- Factorisation de la charte dupliquée dans les pages internes du computeur.
- Recette mobile complète (le responsive est en place mais non testé sur appareil).
- **Règle virtuelle → règle complète** : dès réception des **clichés de la coulisse recto/verso à plat**
  (perpendiculaires, avec réglet, + curseur non fissuré), appliquer le plan de
  `REGLE_VIRTUELLE_transition.md`. Data & calculs déjà vérifiés (18/07/2026).
- **Bibliographie** : trancher [1]/[5] (même page musée), [4] (site amateur de vol virtuel), [7]/[9]
  (préciser ou retirer) ; numérotation sans [3].

---

*Dernière mise à jour du handoff : 18/07/2026 — §8 étendu : nouveau sous-sujet « Règle de navigation »
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
