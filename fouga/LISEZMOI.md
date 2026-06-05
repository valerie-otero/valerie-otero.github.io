# Site web — Computeur de vol Fouga CM 170 R Magister

Version **HTML statique** : aucun serveur nécessaire, le site s'ouvre
par double-clic sur `index.html` et fonctionne tel quel chez n'importe
quel hébergeur (copie FTP du dossier, sans PHP ni base de données).

## Contenu

```
site_fouga/
├── index.html                 Accueil : dessin du Fouga + mode d'emploi illustré
├── computeur.html             Computeur de vol virtuel (faces 131 / 336)
├── monographie.html           Monographie : lecture PDF + téléchargement du .docx
├── assets/
│   ├── css/site.css           Charte : crème, bleu Armée #1d3a57, laiton #9a7320
│   ├── img/fouga_face.png     Dessin vue de face (détouré, teinte gravure)
│   └── docs/
│       ├── Fouga_CM170R_computeur_de_vol.docx   (page de garde illustrée, pied ©)
│       └── Fouga_CM170R_computeur_de_vol.pdf    (copie de consultation à jour)
└── pages/
    ├── mode_emploi.html       (livré, inchangé)
    └── computeur_virtuel.html (livré, inchangé)
```

## Pied de page

Toutes les pages du site et du document Word portent :
© Valérie Otero — 2026.

## Principes retenus

- Les documents HTML livrés sont servis **intacts** dans un cadre
  pleine page : styles, polices et interactions préservés à l'identique.
- Le bandeau, le dessin d'accueil et le pied de page reprennent la
  charte des livrables (Fraunces / Saira Semi Condensed / Spectral /
  Spline Sans Mono).
- La monographie Word reste le document de référence ; le PDF n'est
  qu'une copie de consultation, régénérable à tout moment.
