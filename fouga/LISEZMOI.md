# Site web — Computeur de vol Fouga CM 170 R Magister

Version **HTML statique** : aucun serveur nécessaire, le site s'ouvre
par double-clic sur `index.html` et fonctionne tel quel chez n'importe
quel hébergeur (copie FTP du dossier, sans PHP ni base de données).
Depuis la dernière révision, il fonctionne **entièrement hors-ligne**
(polices hébergées en local, plus aucun appel à Google Fonts).

## Architecture : enveloppes et contenus

Le site suit un schéma régulier. Les trois fichiers à la racine sont des
**enveloppes** (bandeau + navigation + pied de page) ; chacune affiche un
**contenu** dans un cadre pleine page :

| Enveloppe (racine) | Onglet | Contenu affiché |
|--------------------|--------|-----------------|
| `index.html`       | Mode d'emploi      | `pages/mode_emploi.html` (iframe) |
| `computeur.html`   | Computeur virtuel  | `pages/computeur_virtuel.html` (iframe) |
| `monographie.html` | Monographie        | `assets/docs/…pdf` (object) + lien `.docx` |

> `computeur.html` est donc l'**enveloppe** (page de navigation) et
> `pages/computeur_virtuel.html` le **contenu interactif** (l'outil
> lui-même) — même rapport qu'entre `index.html` et `mode_emploi.html`.

## Contenu

```
fouga/
├── index.html                 Enveloppe — accueil : dessin du Fouga + mode d'emploi
├── computeur.html             Enveloppe — computeur de vol virtuel (faces 131 / 336)
├── monographie.html           Enveloppe — lecture PDF + téléchargement du .docx
├── assets/
│   ├── css/
│   │   ├── site.css           Charte : crème, bleu Armée #1d3a57, laiton #9a7320
│   │   └── fonts.css          @font-face locaux (latin + latin-ext)
│   ├── fonts/                 Polices woff2 (Fraunces, Saira, Spectral, Spline)
│   ├── img/
│   │   ├── fouga_face.png     Dessin vue de face (accueil)
│   │   ├── IMG_3549…3576.jpeg Photographies d'origine de l'instrument (source de référence)
│   │   └── face131_*.jpg, couronne_*.jpg, abaque_*.jpg, face336_*.jpg
│   │                          Illustrations du mode d'emploi (externalisées du HTML)
│   └── docs/
│       ├── Fouga_CM170R_computeur_de_vol.docx   (document de référence, pied ©)
│       └── Fouga_CM170R_computeur_de_vol.pdf    (copie de consultation à jour)
└── pages/
    ├── mode_emploi.html       Contenu — mode d'emploi illustré
    └── computeur_virtuel.html Contenu — instrument interactif (faces 131 / 336)
```

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
