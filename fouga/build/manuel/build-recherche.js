#!/usr/bin/env node
/* ============================================================================
   build-recherche.js — génère assets/js/recherche-index.js, l'index de
   recherche plein-texte du liseur Manuel CM 170.
   À lancer APRÈS build-refs.js (il indexe les pages générées, planches.html
   comprise).

   Le site fonctionne en file:// sans serveur : fetch() y est interdit, donc
   l'index est livré comme un script classique qui définit
   window.FOUGA_RECHERCHE. Structure :
     sections : [{slug, label, scan}]            (scan = page de début, PDF TEXTE)
     titres   : [{ancre: "texte du titre"}]      (par section, pour le contexte)
     scans    : {ancre: page PDF TEXTE}          (synchronisation lecture comparée)
     planches : {ancre pl-N: page PDF ILLUSTR.}  (idem, volet planches)
     blocs    : [[iSection, ancre|null, texte, estTitre]]
   Un bloc = un paragraphe / item de liste / ligne de tableau / titre, rattaché
   à l'ancre (h2/h3/h4 sec-…, lim-…, ou ligne pl-N) la plus proche.
   ============================================================================ */
'use strict';
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..', '..');
const MANUEL = path.join(ROOT, 'pages', 'manuel');
const scan = JSON.parse(fs.readFileSync(path.join(__dirname, 'scan-map.json'), 'utf8'));
const planchesMap = JSON.parse(fs.readFileSync(path.join(__dirname, 'planches-map.json'), 'utf8'));

const SECTIONS = [
  { slug: '00_liminaires', label: 'Pages liminaires' },
  { slug: 'section_i',     label: 'I — Description' },
  { slug: 'section_ii',    label: 'II — Utilisation courante' },
  { slug: 'section_iii',   label: 'III — Limitations' },
  { slug: 'section_iv',    label: 'IV — Cas particuliers de vol' },
  { slug: 'section_v',     label: 'V — Utilisation des équipements' },
  { slug: 'section_vi',    label: 'VI — Incidents, pannes, secours' },
  { slug: 'section_vii',   label: 'VII — Armement' },
  { slug: 'section_viii',  label: 'VIII — Conditions climatiques extrêmes' },
  { slug: 'planches',      label: 'Planches (illustrations)' },
];

const decode = (s) => s.replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>')
                       .replace(/&#39;/g, '’').replace(/&quot;/g, '"')
                       .replace(/&nbsp;/g, ' ').replace(/ /g, ' ');

const BLOCK_TAGS = ['h2', 'h3', 'h4', 'h5', 'p', 'li', 'tr'];

/* Extrait les blocs de texte d'une page de section (article uniquement). */
function extraire(slug) {
  let html = fs.readFileSync(path.join(MANUEL, `${slug}.html`), 'utf8');
  const open = html.indexOf('<article class="lecture-corps">');
  const close = html.lastIndexOf('</article>');
  let article = html.slice(open, close);
  // le repère « scan p. N » n'est pas du texte d'origine : exclu de l'index
  article = article.replace(/<a class="h2-scan"[\s\S]*?<\/a>/g, '');

  const parts = article.split(/(<[^>]+>)/);
  const blocs = [];
  const titres = {};
  let ancre = null;
  let buf = '';
  let dansTitre = false;

  const flush = (estFinDeTitre) => {
    const t = decode(buf).replace(/\s*·\s*$/, '').replace(/\s+/g, ' ').trim();
    buf = '';
    if (!t) return;
    blocs.push([ancre, t, dansTitre ? 1 : 0]);
    if (estFinDeTitre && ancre && titres[ancre] === undefined) titres[ancre] = t;
  };

  for (const part of parts) {
    if (part.startsWith('<')) {
      const m = part.match(/^<(\/?)([a-zA-Z0-9]+)/);
      if (!m) continue;
      const closing = m[1] === '/';
      const tag = m[2].toLowerCase();
      if (BLOCK_TAGS.includes(tag)) {
        const finTitre = closing && /^h\d$/.test(tag) && dansTitre;
        flush(finTitre);
        if (!closing) {
          const idm = part.match(/\bid="([^"]+)"/);
          if (idm) ancre = idm[1];
          if (/^h\d$/.test(tag)) dansTitre = true;
        } else if (/^h\d$/.test(tag)) {
          dansTitre = false;
        }
      } else if ((tag === 'td' || tag === 'th') && closing) {
        buf += ' · ';                      // séparateur de cellules d'une ligne
      }
    } else {
      buf += part;
    }
  }
  flush(false);
  return { blocs, titres };
}

const sections = [];
const titresParSection = [];
const blocs = [];
const scans = {};
const planches = {};

SECTIONS.forEach((sec, si) => {
  sections.push({ slug: sec.slug, label: sec.label, scan: scan.sections[sec.slug] || null });
  const { blocs: bs, titres } = extraire(sec.slug);
  titresParSection.push(titres);
  for (const [ancre, texte, estTitre] of bs) {
    blocs.push([si, ancre, texte, estTitre]);
    if (ancre && scans[ancre] === undefined) {
      const m = ancre.match(/^sec-(\d+)-(\d+)/);
      if (m) {
        const page = scan.subsections[`${m[1]}.${m[2]}`];
        if (page !== undefined) scans[ancre] = page;
      } else if (/^lim-/.test(ancre)) {
        scans[ancre] = scan.sections['00_liminaires'];
      }
    }
  }
});

for (const p of planchesMap.planches) {
  if (p.page) planches[`pl-${p.num}`] = p.page;
}

const index = { sections, titres: titresParSection, scans, planches, blocs };
const js = `/* GÉNÉRÉ par build/manuel/build-recherche.js — ne pas éditer.
   Index de recherche plein-texte du liseur Manuel CM 170 (chargé en
   <script> classique : fonctionne en file://, sans serveur ni fetch). */
window.FOUGA_RECHERCHE = ${JSON.stringify(index)};
`;
fs.writeFileSync(path.join(ROOT, 'assets', 'js', 'recherche-index.js'), js);
const ko = Math.round(Buffer.byteLength(js, 'utf8') / 1024);
console.log(`recherche-index.js généré — ${blocs.length} blocs, ${Object.keys(scans).length} ancres scan, ${ko} Ko.`);
