# Site web — Fouga CM 170 R Magister

Version **HTML statique** : aucun serveur nécessaire, le site s'ouvre
par double-clic sur `index.html` et fonctionne tel quel chez n'importe
quel hébergeur (copie FTP du dossier, sans PHP ni base de données).
Depuis la dernière révision, il fonctionne **entièrement hors-ligne**
(polices hébergées en local, plus aucun appel à Google Fonts).

## Architecture : sujet, sous-sujets, enveloppes

Le **sujet** du site est l'avion **Fouga CM 170 R Magister** ; les
**sous-sujets** (Computeur de vol, Manuel CM 170…) sont rangés dessous.
La navigation est à **deux niveaux** : une nav principale dans le bandeau
(Présentation · Computeur · Manuel CM 170) et, pour les sous-sujets à
plusieurs pages, une **sous-barre** sous le bandeau (`.sous-nav`).

Chaque fichier à la racine est une **enveloppe** (bandeau + navigation +
pied) affichant un **contenu** en cadre pleine page :

| Niveau | Enveloppe (racine) | Onglet | Contenu affiché |
|--------|--------------------|--------|-----------------|
| Présentation | `index.html` | Présentation | accueil minimal : dessin du Fouga + tuiles d'accès |
| Computeur ▸ | `computeur.html` | Mode d'emploi | `pages/mode_emploi.html` (iframe) |
| Computeur ▸ | `computeur-virtuel.html` | Computeur virtuel | `pages/computeur_virtuel.html` (iframe) |
| Computeur ▸ | `monographie.html` | Monographie | `assets/docs/…pdf` (object) + lien `.docx` |
| Manuel | `manuel.html` | Manuel CM 170 | sommaire latéral + `pages/manuel/*.html` (iframe `lecteur`) + volet « Lecture comparée » (scans) |

> Les trois pages du sous-sujet **Computeur** partagent la même sous-barre ;
> l'onglet principal « Computeur » reste actif sur les trois, et la sous-barre
> surligne la page courante. Pour ajouter un sous-sujet, dupliquer ce schéma
> (onglet principal + éventuelle `.sous-nav`).

## Contenu

```
fouga/
├── index.html                 Enveloppe — Présentation (accueil Fouga : dessin + tuiles)
├── computeur.html             Enveloppe — Computeur ▸ Mode d'emploi (faces 131 / 336)
├── computeur-virtuel.html     Enveloppe — Computeur ▸ Computeur virtuel (interactif)
├── monographie.html           Enveloppe — Computeur ▸ Monographie (PDF + .docx)
├── manuel.html                Enveloppe — Manuel CM 170 (liseur, GÉNÉRÉ, voir build/)
├── FOUGA CM.170 TEXTE.pdf          Scan original du manuel (lié page à page depuis le liseur)
├── FOUGA CM.170 ILLUSTRATIONS.pdf  Scan original des planches (onglet « Planches »)
├── assets/
│   ├── css/
│   │   ├── site.css           Charte : crème, bleu Armée #1d3a57, laiton #9a7320
│   │   ├── fonts.css          @font-face locaux (latin + latin-ext)
│   │   └── manuel.css         Habillage du liseur + des pages de transcription
│   ├── js/
│   │   ├── lecture.js         Aides de texte (pliage accents/casse, requêtes),
│   │   │                      relais data-compare vers la lecture comparée,
│   │   │                      surlignage des occurrences (?q=…)
│   │   ├── recherche.js       Moteur de recherche du liseur (simple + avancée)
│   │   └── recherche-index.js Index plein-texte (GÉNÉRÉ, voir build/)
│   ├── fonts/                 Polices woff2 (Fraunces, Saira, Spectral, Spline)
│   ├── img/
│   │   ├── fouga_face.png     Dessin vue de face (accueil)
│   │   ├── IMG_3549…3576.jpeg Photographies d'origine de l'instrument (source de référence)
│   │   └── face131_*.jpg, couronne_*.jpg, abaque_*.jpg, face336_*.jpg
│   │                          Illustrations du mode d'emploi (externalisées du HTML)
│   └── docs/
│       ├── Fouga_CM170R_computeur_de_vol.docx   (document de référence, pied ©)
│       └── Fouga_CM170R_computeur_de_vol.pdf    (copie de consultation à jour)
├── pages/
│   ├── mode_emploi.html       Contenu — mode d'emploi illustré
│   ├── computeur_virtuel.html Contenu — instrument interactif (faces 131 / 336)
│   └── manuel/                Contenu — 9 pages de transcription + planches.html
│                              (index cliquable des planches) (GÉNÉRÉ, voir build/)
├── build/manuel/              Pipeline reproductible (non publié) :
│   ├── manuel-filter.lua      filtre pandoc (re-balise titres/encadrés/NOTA sans toucher au texte)
│   ├── manuel-template.html   gabarit standalone des pages de section
│   ├── build-manuel.sh        DOCX → pages/manuel/*.html, puis enchaîne les 3 scripts node
│   ├── build-refs.js          renvois « planche N » → liens, repères « scan p. N »
│   │                          sur les titres x.x, TdM cliquable, planches.html
│   ├── build-recherche.js     index plein-texte → assets/js/recherche-index.js
│   ├── build-sommaire.js      moissonne les titres x.x → manuel.html (sommaire,
│   │                          recherche, volet comparé)
│   ├── planches-map.json      carte planche ↔ page du PDF ILLUSTRATIONS (lecture visuelle)
│   └── scan-map.json          carte sous-section x.x ↔ page du PDF TEXTE (lecture visuelle)
└── FOUGA_CM170_COLLECTE/      Sources : 9 transcriptions OCR (.docx) + handoff
```

## Section « Manuel CM 170 » (liseur des transcriptions OCR)

Le quatrième onglet donne accès au **Manuel de l'équipage** (Édition 1975,
Révision 06/1977) sous forme d'un **liseur** : un sommaire latéral (les
9 sections, dépliables jusqu'aux sous-sections x.x) charge la transcription
dans un volet de lecture. Chaque section affiche un bouton **« Scan original
— p. N »** qui ouvre le PDF scanné au bon folio (correspondance page PDF ↔
page interne établie dans le handoff), et l'onglet **« Planches »** ouvre
l'**index cliquable des planches** (`pages/manuel/planches.html`).
Les `.docx` ne sont plus proposés au téléchargement (les sources restent
dans `FOUGA_CM170_COLLECTE/`).

### Recherche (simple et avancée)

Une **barre de recherche** en tête du sommaire interroge tout le manuel
(transcriptions + index des planches). Recherche **simple** : tous les mots,
accents et casse ignorés, "guillemets" pour une expression exacte. Recherche
**avancée** (dépliant sous la barre) : tous les mots / au moins un mot /
expression exacte, mots entiers, respect de la casse, respect des accents,
restriction à une section. Les résultats (groupés par section, avec extrait)
s'ouvrent dans le volet de lecture **avec surlignage des occurrences**
(paramètre `?q=…` lu par `lecture.js`) et **synchronisent la lecture
comparée** quand le volet est ouvert (y compris vers le PDF d'illustrations
pour les résultats « planches »).

Le site fonctionnant **sans serveur** (file://), `fetch()` est impossible :
l'index plein-texte est **généré au build** (`build-recherche.js` →
`assets/js/recherche-index.js`, chargé comme un script classique). Sans
JavaScript, le bloc de recherche reste masqué et le liseur fonctionne
comme avant.

### Lecture comparée (transcription ↔ scans)

Les deux PDF scannés (`TEXTE` et `ILLUSTRATIONS`) sont intégrés au liseur
dans un **volet « Lecture comparée »** qui s'affiche côte à côte avec la
transcription :

- le bouton **« Lecture comparée ⇆ »** du sommaire ouvre/ferme le volet ;
- **« Scan original — p. N »** et les repères **« scan p. N »** en fin de
  chaque titre x.x ouvrent le scan TEXTE à la page où commence la
  sous-section (carte `scan-map.json`, relevée par lecture visuelle du scan,
  page par page) ;
- les **renvois « (planche N) » du texte sont des liens** qui ouvrent le PDF
  d'illustrations à la bonne page (carte `planches-map.json`, relevée
  planche par planche sur les 95 pages du scan) ;
- dans les liminaires, la **Table des matières** (folios → scan ; les folios
  annoncés par la TdM d'origine sont conservés tels quels, divergences
  comprises, cf. handoff §6) et la **Table des planches** sont cliquables ;
- la navigation au sommaire **synchronise** le volet quand il est ouvert ;
- la **poignée** entre transcription et scan règle le partage des deux
  volets (glisser ; flèches ←/→ au clavier ; double-clic : moitié-moitié).

Consultation seule : le scan s'affiche **sans la barre d'outils** du
visualiseur PDF (`#toolbar=0&navpanes=0` — pas de bouton télécharger ni
imprimer ; Chrome/Edge/Firefox), il n'y a **pas de bouton « ouvrir dans un
nouvel onglet »**, et dans le liseur les liens scan/planches sont
**neutralisés** par `lecture.js` (cible réelle déplacée en `data-href`,
`href="#"`, `target` retiré, glisser-déposer bloqué) : clic-molette ou
« ouvrir dans un nouvel onglet » n'atteignent plus le PDF. Limite assumée :
le fichier étant servi au navigateur pour être affiché, une récupération
reste techniquement possible (URL directe, outils du navigateur).

Particularités du scan ILLUSTRATIONS (consignées dans `planches-map.json`) :
planches 31 et 32 réunies sur une seule page « non valables pour la présente
version » ; planche 48 en deux feuilles (la seconde non numérotée) ; planches
47 et 49 suivies d'une page de légende non numérotée.

Amélioration progressive : sans JavaScript, ou quand une page de section est
ouverte hors liseur, les liens gardent leur comportement natif
(`target="_blank"` dans les sources — la neutralisation ci-dessus n'opère
que lorsque `lecture.js` tourne dans le liseur) ; le volet n'apparaît que
si JS est actif. La navigation
au folio (`#page=N`) dépend du lecteur PDF du navigateur (Chrome/Firefox :
oui ; Safari peut l'ignorer).

Les pages de `pages/manuel/` et `manuel.html` sont **générées** — ne pas les
éditer à la main. Pour régénérer après modification d'une transcription :

```bash
bash build/manuel/build-manuel.sh      # DOCX → pages/manuel/*.html,
                                       # puis build-refs.js (renvois + planches.html)
                                       # et build-sommaire.js (manuel.html)
```

Le pipeline **préserve le texte à l'identique** (le filtre Lua ne fait que
re-baliser la structure : titres numérotés, encadrés ATTENTION, NOTA, corps,
tableaux ; `build-refs.js` ne fait qu'entourer de liens des fragments
existants — seul le repère « scan p. N », hors texte d'origine, est ajouté
en fin de titre). Vérifié mot à mot sur les 9 sections après chaque étape :
aucun mot ajouté ni altéré ; seul le bloc de titre répété de chaque DOCX est
retiré (réaffiché par l'en-tête du liseur). Dépendance : `pandoc` (≥ 3) et
`node`.

## Source de référence des données

Les **photographies d'origine** `assets/img/IMG_3549…3576.jpeg` font foi
pour toute valeur gravée sur l'instrument. Les tables du site (grilles de
croisière, montée/descente, distance maximale, face 336) et la monographie
ont été **vérifiées cellule par cellule** d'après ces photos.

## Pied de page

Toutes les pages du site et du document Word portent :
© Valérie Otero — 2026.

## Principes retenus

- Les documents HTML de `pages/` sont affichés **pleine page** dans un
  cadre ; leurs styles et interactions sont préservés.
- Le bandeau, le dessin d'accueil et le pied de page reprennent la charte
  (Fraunces / Saira Semi Condensed / Spectral / Spline Sans Mono),
  désormais servies **localement** depuis `assets/fonts/`.
- La monographie Word reste le document de référence ; le PDF n'est qu'une
  copie de consultation, régénérable à tout moment.
- Le computeur interactif affiche par défaut les **valeurs gravées**
  (authentiques) ; une pastille « Comparer au calcul » superpose, sur la
  vitesse vraie (TAS), la valeur recalculée par formule à titre indicatif.
