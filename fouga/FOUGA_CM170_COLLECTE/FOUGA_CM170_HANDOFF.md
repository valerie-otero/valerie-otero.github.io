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

*Dernière mise à jour du handoff : après achèvement des Sections III à VIII (toutes les sections du
manuel sont transcrites). Restent le document maître et l'étude.*
