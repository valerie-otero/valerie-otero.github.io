# Harnais de test de la règle virtuelle (`pages/regle_navigation_virtuelle.html`)

Recette utilisée pour toutes les passes de fidélité du 23/07/2026 (voir handoff) :

1. **Extraire le script** de la page :
   ```py
   import re
   src = open('pages/regle_navigation_virtuelle.html').read()
   open('page_script.js','w').write('\n;\n'.join(re.findall(r'<script>(.*?)</script>', src, re.S)))
   ```
2. **Smoke test** (exécute tout le script avec un mini-DOM, attrape les exceptions) :
   `node domstub.js page_script.js` → doit afficher `RUNTIME OK`.
3. **Rendu d'une face** (sérialise le SVG construit puis capture) :
   `SC=<dossier> FACE=svgR|svgV|svgC COFF=<décalage coulisse> node render.js`
   puis `"…/Google Chrome" --headless --disable-gpu --screenshot=out.png --window-size=2360,860 file://…/recto.svg`
   (le PNG est en ×4 : px = svg × 4 sur un écran Retina ×2).
4. **Comparer au scan à plat** (`../RdN_Cne_Claude/règle Fouga.pdf`, pages 1–2, `pdftoppm -r 400`
   puis `transpose(ROTATE_270)`) **à échelle identique** : facteur ≈ 0,302 px SVG / px scan 400 dpi.
   Jamais d'ajustement « à l'œil » : mesurer (détection de traits par script), rendre, superposer, itérer.

`render.js` lit `SC` (dossier de travail contenant `page_script.js` et `domstub.js`) et écrit `recto.svg`.
