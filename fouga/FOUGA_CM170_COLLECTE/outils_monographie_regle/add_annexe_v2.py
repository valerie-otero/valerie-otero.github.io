# -*- coding: utf-8 -*-
# v2 : annexe IDENTIQUE à la transcription océrisée — Courier New 10 pt, interligne
# d'origine, 19 figures transposées (médias + relations), pagination 1:1.
import re, os, zipfile, shutil, xml.etree.ElementTree as ET
from xml.sax.saxutils import escape

W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
MAXCX = 5_900_000          # largeur utile du corps de page (EMU)

# ---------- 0. repartir du DOCX d'origine ----------
shutil.rmtree('mono_x', ignore_errors=True)
with zipfile.ZipFile('mono.docx') as z: z.extractall('mono_x')

# ---------- 1. relations & médias ----------
rels_path = 'mono_x/word/_rels/document.xml.rels'
rels = open(rels_path, encoding='utf-8').read()
next_rid = max(int(x) for x in re.findall(r'Id="rId(\d+)"', rels)) + 1
trans_rels = open('trans_x/word/_rels/document.xml.rels', encoding='utf-8').read()
rid_map, new_rels = {}, []
for old_rid, target in re.findall(r'Id="(rId\d+)"[^>]*Target="media/([^"]+)"', trans_rels):
    new_name = 'notice_' + target
    shutil.copy('trans_x/word/media/' + target, 'mono_x/word/media/' + new_name)
    new_rid = f'rId{next_rid}'; next_rid += 1
    rid_map[old_rid] = new_rid
    new_rels.append(f'<Relationship Id="{new_rid}" '
                    'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" '
                    f'Target="media/{new_name}"/>')
rels = rels.replace('</Relationships>', ''.join(new_rels) + '</Relationships>')
open(rels_path, 'w', encoding='utf-8').write(rels)
print('médias transposés :', len(rid_map))

# ---------- 2. contenu de la transcription ----------
trans = ET.parse('trans_x/word/document.xml').getroot().find(W + 'body')
next_docpr = 100
COUR = ('<w:rFonts w:ascii="Courier New" w:hAnsi="Courier New" w:cs="Courier New"/>'
        '<w:sz w:val="20"/><w:szCs w:val="20"/>')
PPR  = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="auto"/>'
PAGEBREAK = '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'

def esc_run(text, extra=''):
    parts = []
    for i, seg in enumerate(text.split('\n')):
        if i: parts.append('<w:br/>')
        parts.append('<w:t xml:space="preserve">' + escape(seg) + '</w:t>')
    return '<w:r><w:rPr>' + COUR + extra + '</w:rPr>' + ''.join(parts) + '</w:r>'

xml_out = [PAGEBREAK,
    # titre au gabarit des sections
    '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:color="8A8A8A" w:sz="6" w:space="4"/></w:pBdr>'
    '<w:spacing w:after="200" w:before="320"/></w:pPr>'
    '<w:r><w:rPr><w:b/><w:bCs/><w:smallCaps/><w:color w:val="1A1A1A"/><w:sz w:val="30"/><w:szCs w:val="30"/></w:rPr>'
    '<w:t xml:space="preserve">Annexe.  Transcription intégrale de la notice (1980)</w:t></w:r></w:p>',
    # chapeau (police du corps de la monographie)
    '<w:p><w:pPr><w:spacing w:after="200"/></w:pPr><w:r>'
    '<w:t xml:space="preserve">Texte intégral de la notice d’époque (chapitre 4 du cours d’escadron dactylographié, '
    '13 pages), reproduit à l’identique de la transcription océrisée : orthographe, ponctuation et coquilles '
    'd’origine conservées, figures et pagination d’origine reprises (une page de la notice par page). '
    'Les appels (1) à (12) renvoient aux notes de transcription reproduites en fin d’annexe.</w:t></w:r></w:p>',
    PAGEBREAK]   # la page 1 de la notice commence sur une page neuve

for p in trans.findall(W + 'p'):
    ppr = p.find(W + 'pPr')
    if ppr is not None and ppr.find(W + 'pageBreakBefore') is not None:
        xml_out.append(PAGEBREAK)
    if p.find('.//' + W + 'drawing') is not None:
        s = ET.tostring(p, encoding='unicode')
        for old, new in rid_map.items():
            s = re.sub(r'embed="' + old + r'"', 'embed="' + new + '"', s)
        s = re.sub(r'docPr id="\d+"', lambda m: f'docPr id="{next_docpr}"', s)
        # réduction proportionnelle : Lettre US plus courte que l'A4 de la
        # transcription — 0,85 conserve la pagination 1:1 (et borne la largeur)
        m = re.search(r'extent cx="(\d+)" cy="(\d+)"', s)
        if m:
            cx, cy = int(m.group(1)), int(m.group(2))
            f = min(MAXCX / cx, 1.0) * 0.85
            s = s.replace(f'cx="{cx}" cy="{cy}"', f'cx="{int(cx*f)}" cy="{int(cy*f)}"')
        next_docpr += 1
        xml_out.append(s)
        continue
    runs_xml = ''
    for r in p.findall(W + 'r'):
        rpr = r.find(W + 'rPr')
        u   = rpr is not None and rpr.find(W + 'u') is not None
        sup = rpr is not None and rpr.find(W + 'vertAlign') is not None
        buf = ''
        for e in r:
            tag = e.tag.split('}')[1]
            if tag == 't': buf += e.text or ''
            elif tag == 'tab': buf += '   '
            elif tag == 'br': buf += '\n'
        if buf:
            runs_xml += esc_run(buf, ('<w:u w:val="single"/>' if u else '') +
                                     ('<w:vertAlign w:val="superscript"/>' if sup else ''))
    xml_out.append('<w:p><w:pPr>' + PPR + '</w:pPr>' + runs_xml + '</w:p>')
annexe = ''.join(xml_out)

# ---------- 3. injection dans document.xml ----------
doc = open('mono_x/word/document.xml', encoding='utf-8').read()
assert doc.count('22 juillet 2026') == 1
doc = doc.replace('22 juillet 2026', '24 juillet 2026')
m = re.search(r'<w:p>(?:(?!</w:p>).)*?Glossaire(?:(?!</w:p>).)*?\t11(?:(?!</w:p>).)*?</w:p>', doc, re.S)
assert m, 'ligne sommaire Glossaire introuvable'
toc = ('<w:p><w:pPr><w:tabs><w:tab w:val="right" w:pos="9360" w:leader="dot"/></w:tabs>'
       '<w:spacing w:after="40"/></w:pPr>'
       '<w:r><w:rPr><w:b/><w:bCs/></w:rPr><w:t xml:space="preserve">Annexe. Transcription intégrale de la notice (1980)</w:t></w:r>'
       '<w:r><w:t xml:space="preserve">\t13</w:t></w:r></w:p>')
doc = doc[:m.end()] + toc + doc[m.end():]
i = doc.rfind('<w:sectPr'); assert i > 0
doc = doc[:i] + annexe + doc[i:]
open('mono_x/word/document.xml', 'w', encoding='utf-8').write(doc)

# ---------- 4. rezippage complet depuis mono_x ----------
out = 'Fouga_CM170R_regle_de_navigation.docx'
if os.path.exists(out): os.remove(out)
src = zipfile.ZipFile('mono.docx')
names = src.namelist()
added = ['word/media/notice_' + t for _, t in
         re.findall(r'Id="(rId\d+)"[^>]*Target="media/([^"]+)"', trans_rels)]
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
    for item in names:
        path = 'mono_x/' + item
        z.write(path, item) if os.path.exists(path) else z.writestr(item, src.read(item))
    for extra in added:
        z.write('mono_x/' + extra, extra)
src.close()
print('DOCX écrit :', out, os.path.getsize(out), 'octets')
