#!/usr/bin/env bash
# ============================================================================
# build-manuel.sh — génère les pages HTML du liseur « Manuel CM 170 »
#   à partir des transcriptions OCR (.docx de FOUGA_CM170_COLLECTE).
#
#   DOCX --pandoc + manuel-filter.lua + manuel-template.html--> pages/manuel/*.html
#
# Reproductible : relancer ce script régénère intégralement les pages.
# Le texte est préservé à l'identique ; seul l'habillage (titres, encadrés,
# corps) est rebalisé. Dépend de `pandoc` (>= 3).
#
#   Folio du scan = 1re page interne de la section, via la table de
#   correspondance page PDF <-> page interne (FOUGA_CM170_HANDOFF.md §3).
# ============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC="$ROOT/FOUGA_CM170_COLLECTE"
OUT="$ROOT/pages/manuel"
FILTER="$ROOT/build/manuel/manuel-filter.lua"
TPL="$ROOT/build/manuel/manuel-template.html"
SCAN="../../FOUGA%20CM.170%20TEXTE.pdf"   # PDF scanné (racine), chemin URL-encodé

mkdir -p "$OUT"

# slug | docx | titre | chapitre | pages internes | folio scan
RECORDS=(
  "00_liminaires|FOUGA_CM170_00_Liminaires.docx|Pages liminaires|Manuel de l'équipage — Partie Texte|Index + Tables (1 à 6)|4"
  "section_i|FOUGA_CM170_Section_I_Description.docx|Section I — Description|Chapitre I — Description|7 à 34|12"
  "section_ii|FOUGA_CM170_Section_II_Utilisation_courante.docx|Section II — Utilisation courante|Chapitre II — Utilisation de l'avion|35 à 49|42"
  "section_iii|FOUGA_CM170_Section_III_Limitations.docx|Section III — Limitations|Chapitre II — Utilisation de l'avion|51 à 54|58"
  "section_iv|FOUGA_CM170_Section_IV_Cas_particuliers_de_vol.docx|Section IV — Cas particuliers de vol|Chapitre II — Utilisation de l'avion|55 à 63|63"
  "section_v|FOUGA_CM170_Section_V_Utilisation_des_equipements.docx|Section V — Utilisation des équipements|Chapitre II — Utilisation de l'avion|65 à 72|73"
  "section_vi|FOUGA_CM170_Section_VI_Incidents_pannes_secours.docx|Section VI — Incidents, pannes et manœuvres de secours|Chapitre II — Utilisation de l'avion|73 à 100|82"
  "section_vii|FOUGA_CM170_Section_VII_Armement.docx|Section VII — Armement|Chapitre II — Utilisation de l'avion|101|111"
  "section_viii|FOUGA_CM170_Section_VIII_Conditions_climatiques_extremes.docx|Section VIII — Conditions climatiques extrêmes|Chapitre II — Utilisation de l'avion|103 à 104|113"
)

echo "Build liseur Manuel CM 170 -> $OUT"
for rec in "${RECORDS[@]}"; do
  IFS='|' read -r slug docx titre chapitre pages folio <<< "$rec"
  src="$SRC/$docx"
  [ -f "$src" ] || { echo "  ! manquant: $docx" >&2; exit 1; }

  pandoc "$src" \
    --lua-filter="$FILTER" \
    --template="$TPL" \
    -M sectiontitle="$titre" \
    -M chapitre="$chapitre" \
    -M pagesinternes="$pages" \
    -M scanpage="$folio" \
    -M scanhref="$SCAN#page=$folio" \
    -o "$OUT/$slug.html"

  echo "  ✓ $slug.html  (scan p.$folio, internes $pages)"
done

# Post-traitement : renvois de planches + repères scan + index des planches,
# index de recherche, puis régénération du sommaire (manuel.html).
node "$ROOT/build/manuel/build-refs.js"
node "$ROOT/build/manuel/build-recherche.js"
node "$ROOT/build/manuel/build-sommaire.js"

echo "Terminé : $(ls "$OUT"/*.html | wc -l | tr -d ' ') pages."
