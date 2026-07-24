# Outils monographie règle de navigation

Le générateur npm `docx` d'origine (22/07/2026) a disparu avec le scratchpad de sa
session : le DOCX `assets/docs/Fouga_CM170R_regle_de_navigation.docx` est désormais
**la seule source**. Les modifications se font par injection XML directe (un DOCX est
un zip de WordprocessingML).

## `add_annexe_v2.py` (24/07/2026)
Ajout de l'annexe « Transcription intégrale de la notice (1980) », **copie conforme
de la transcription océrisée** (exigence de Valérie : identique à l'original) :
- lit `mode emploi règle Fouga - transcription.docx` (RdN_Cne_Claude) : Courier New
  sz20, interligne 276, soulignés et appels (1)–(12) en exposant préservés ;
- **19 figures transposées** (médias copiés en `word/media/notice_*.png`, relations
  ajoutées dans document.xml.rels, docPr re-numérotés à partir de 100, namespaces
  déclarés inline par la sérialisation ElementTree) ;
- **pagination 1:1** : une page de la notice par page du DOCX (pageBreakBefore
  reproduits) ; figures réduites ×0,85 car la Lettre US est plus courte que l'A4
  de la transcription (sans ce facteur, la page 2 déborde → 28 pages au lieu de 27) ;
- ligne de sommaire (tabulation droite 9360 à points, page 13) + date de couverture ;
- rezippe le DOCX (document.xml, rels et médias ajoutés).

Se lance depuis un dossier de travail contenant `mono.docx` (version SANS annexe),
`trans_x/` et `mono_x/` (dézippés). Gabarits : titre de section = smallCaps gras
sz30 + filet bas 8A8A8A ; corps = DejaVu Sans sz21.

## Chaîne PDF
1. `/Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to pdf <docx>`
2. `gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.5 -dPDFSETTINGS=/printer -dNOPAUSE -dBATCH -sOutputFile=out.pdf in.pdf`
   — `/printer` (300 dpi) et non `/ebook` : les figures sont des découpes de scan à
   graduations fines. 9,4 Mo → 2,0 Mo ; 27 pages au 24/07/2026, annexe pp. 13–27
   (titre + chapeau p. 13, notice pp. 14–26, notes de transcription p. 27).

Vérifications d'usage : `pdftotext -f 2 -l 2` (sommaire), alignement page à page
(première ligne de chaque page de la notice vs PDF pp. 14–27), `pdfimages -list`
(19 figures dans l'annexe), dernière page (notes complètes).
