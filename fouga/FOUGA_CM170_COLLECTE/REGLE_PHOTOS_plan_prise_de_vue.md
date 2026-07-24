# Règle de navigation — plan de prise de vue (remplacement des photos du site)

Objectif : 7 clichés maîtres qui couvrent les **16 emplacements d'images** de
`pages/regle_navigation.html` (les 9 zooms sont des recadrages des vues maîtresses).
Garder les **mêmes noms de fichiers** dans `assets/img/` : aucun HTML à toucher.

## Les 7 clichés

### A — Instrument assemblé (recto)
| # | Prise de vue | Remplace | Recadrages à en tirer |
|---|---|---|---|
| 1 | **Recto assemblé, réglette en place** (règle entière, cadrage paysage) | `regle_recto.jpg` (photo du héros, plein écran) | — |
| 2 | **Recto assemblé, réglette tirée** (en extension : fenêtres de gauche vides, échelles 500→1500 découvertes à droite) | `regle_recto_coulisse.jpg` | — |

### B — Pièces séparées, à plat
| # | Prise de vue | Remplace | Recadrages à en tirer |
|---|---|---|---|
| 3 | **Corps seul, recto** (réglette retirée, fenêtres vides) | `regle_corps_recto.jpg` | `regle_zoom_dmf.jpg` (tableau distance max, panneau gauche) · `regle_zoom_fenetres.jpg` (bloc central : Mach, VITESSE PROPRE, Cons., échelles de temps) · `regle_zoom_calculK.jpg` (abaque de vent, bout droit) · `regle_zoom_chants.jpg` (réglettes carto 1/2 000 000 en haut et 1/1 000 000 en bas — les DEUX bords doivent être nets) |
| 4 | **Corps seul, verso** | `regle_corps_verso.jpg` | `regle_zoom_montee.jpg` (abaque de montée — utilisé 2× sur la page) ; endurance/descentes/sécurités visibles dans le plein cadre |
| 5 | **Réglette seule, recto** | `regle_coulisse_recto.jpg` | `regle_zoom_bandes_vi.jpg` (7 bandes Vit. indiquée + 2 bandes Mach) · `regle_zoom_echelle_mobile.jpg` (double échelle log 10→1500 / 1→150 + flèches Pieds/Naut/Unités métriques) |
| 6 | **Réglette seule, verso — face Victor** | `regle_coulisse_verso.jpg` (utilisé 2×) | `regle_zoom_reglettes_verso.jpg` (chants 1/500 000 et 1/100 000 avec leurs échelles de temps) · `regle_zoom_victor.jpg` (consignes centrales : météo, IFF, procédure d'urgence) |

### C — Détail assemblé (verso)
| # | Prise de vue | Remplace | Recadrages |
|---|---|---|---|
| 7 | **Verso assemblé, bout du rapporteur** (l'extrémité arrondie qui dépasse du corps, double numérotation lisible) | `regle_verso_rapporteur.jpg` | — |

> `regle_verso.jpg` (ancien verso assemblé entier) n'est **plus référencé** par aucune
> page depuis la refonte du 22/07/2026 — inutile de le refaire.

## Bonus si le temps le permet — macros des 3 lectures encore incertaines
- Décimale de la consommation Marboré II au **FL 150** (« 9 l/m », masquée par la fissure du tableau).
- Cote **4′ au FL 50** de l'abaque de montée (attribution II-Pb à confirmer).
- **Titre raturé** de l'abaque de vent (vestiges sous l'encre).

## Consignes techniques
- **Résolution maximale**, appareil **perpendiculaire** au plan de la règle (pas de
  parallaxe) : les zooms sont des recadrages, les graduations fines (0,01 Mach, 5″)
  doivent rester nettes.
- Lumière **homogène, sans reflet** sur la vitre (surtout la zone jaunie du calcul K).
  Une variante en lumière rasante peut aider sur la gravure si besoin.
- **Fond sombre uni** : les cadres du site sont sur fond quasi noir.
- La règle est longue et étroite (≈ 3,2:1) : cadrer serré sur l'objet — la page
  limite les vues pleine largeur à ~300 px de haut.
- Livrer les **HEIC originaux tels quels** : conversion JPEG faite via Pillow **sans
  EXIF** (le tag d'orientation des HEIC iPhone est mensonger ; `sips` le recopie et
  les navigateurs pivotent l'image). Cible site : largeur 2400 px, JPEG q85.
