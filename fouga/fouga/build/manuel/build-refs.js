#!/usr/bin/env node
/* ============================================================================
   build-refs.js — post-traitement des pages générées du liseur Manuel CM 170.
   À lancer APRÈS build-manuel.sh et AVANT build-sommaire.js.

   1) Renvois « planche(s) N » du texte → liens vers le PDF d'illustrations,
      ouverts à la bonne page (carte build/manuel/planches-map.json, établie
      par lecture visuelle du scan, planche par planche).
   2) Repère « scan p. N » ajouté à chaque titre x.x → ouvre le scan TEXTE à
      la page où commence la sous-section (carte build/manuel/scan-map.json).
   3) Pages liminaires : la Table des matières (folios → scan) et la Table
      des planches (N° → planche) deviennent cliquables.
   4) Génère pages/manuel/planches.html — index cliquable des planches.

   Le texte des transcriptions reste STRICTEMENT inchangé : on ne fait
   qu'entourer des fragments existants de balises <a> ; seul le repère
   « scan p. N » (hors texte d'origine) est ajouté en fin de titre.
   Tous les liens portent data-compare : dans le liseur ils s'ouvrent dans
   le volet « Lecture comparée » ; page ouverte seule → nouvel onglet.
   ============================================================================ */
'use strict';
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..', '..');
const MANUEL = path.join(ROOT, 'pages', 'manuel');
const ILL_HREF = '../../FOUGA%20CM.170%20ILLUSTRATIONS.pdf';
const TXT_HREF = '../../FOUGA%20CM.170%20TEXTE.pdf';

const planches = JSON.parse(fs.readFileSync(path.join(__dirname, 'planches-map.json'), 'utf8'));
const scan = JSON.parse(fs.readFileSync(path.join(__dirname, 'scan-map.json'), 'utf8'));

const byNum = new Map(planches.planches.map((p) => [p.num, p]));
const warnings = [];

// Folio interne -> page du PDF TEXTE (offsets du handoff §3, confirmés par
// lecture visuelle folio par folio).
const SEGMENTS = [
  [1, 6, 3], [7, 34, 5], [35, 49, 7], [51, 54, 7], [55, 63, 8],
  [65, 72, 8], [73, 100, 9], [101, 101, 10], [103, 104, 10],
];
const folioToPdf = (f) => {
  const s = SEGMENTS.find(([a, b]) => f >= a && f <= b);
  return s ? f + s[2] : null;
};

const SLUGS = {
  1: 'section_i', 2: 'section_ii', 3: 'section_iii', 4: 'section_iv',
  5: 'section_v', 6: 'section_vi', 7: 'section_vii', 8: 'section_viii',
};

const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;').replace(/"/g, '&quot;');

/* Lien vers une planche ; `shown` est le fragment d'origine, restitué tel quel. */
function plancheAnchor(numRaw, shown) {
  const num = numRaw.replace(/\s+/g, '').toUpperCase();
  const p = byNum.get(num);
  if (!p || !p.page) return null;
  const label = `Planche ${num}` + (p.titre ? ` — ${p.titre}` : '');
  return `<a class="ref-planche" href="${ILL_HREF}#page=${p.page}" target="_blank" rel="noopener"` +
         ` data-compare data-label="${esc(label)}" title="${esc(label)}">${shown}</a>`;
}

/* Lien vers une page du scan TEXTE. */
function scanAnchor(pdfPage, label, shown, cls) {
  return `<a class="${cls}" href="${TXT_HREF}#page=${pdfPage}" target="_blank" rel="noopener"` +
         ` data-compare data-label="${esc(label)}" title="${esc(label)}">${shown}</a>`;
}

/* Applique fn aux seuls segments de texte (hors balises, hors <a> existants). */
function mapText(html, fn) {
  const parts = html.split(/(<[^>]+>)/);
  let aDepth = 0;
  for (let i = 0; i < parts.length; i++) {
    const part = parts[i];
    if (part.startsWith('<')) {
      if (/^<a[\s>]/i.test(part)) aDepth++;
      else if (/^<\/a/i.test(part)) aDepth = Math.max(0, aDepth - 1);
    } else if (part && aDepth === 0) {
      parts[i] = fn(part);
    }
  }
  return parts.join('');
}

/* Renvois « planche(s) 34 et 35, 35M et 36 à 39 » : chaque numéro devient un
   lien. Le mot « planche(s) » doit être suivi d'un numéro — « planche de
   bord » et « plancher » ne matchent donc jamais. */
const REF_RE = /([Pp]lanches?)(\s+)((?:\d+[A-Z]?)(?:(?:\s*,\s*|\s+et\s+|\s+à\s+)\d+[A-Z]?)*)/g;
function linkPlanches(text, file) {
  return text.replace(REF_RE, (full, word, sp, list) => {
    const linked = list.replace(/\d+[A-Z]?/g, (tok) => {
      const a = plancheAnchor(tok, tok);
      if (!a) warnings.push(`${file}: planche « ${tok} » sans page connue — non liée`);
      return a || tok;
    });
    return word + sp + linked;
  });
}

/* Délimite le corps <article class="lecture-corps"> et lui applique fn. */
function inArticle(html, fn) {
  const OPEN = '<article class="lecture-corps">';
  const open = html.indexOf(OPEN);
  const close = html.lastIndexOf('</article>');
  if (open < 0 || close < 0) return html;
  const a = open + OPEN.length;
  return html.slice(0, a) + fn(html.slice(a, close)) + html.slice(close);
}

/* Repère « scan p. N » en fin de chaque titre x.x (h2 id="sec-x-x"). */
function addH2Scan(article) {
  return article.replace(/<h2 id="sec-(\d+)-(\d+)"([^>]*)>([\s\S]*?)<\/h2>/g,
    (m, s, n, attrs, inner) => {
      if (inner.includes('h2-scan')) return m;          // déjà traité
      const key = `${s}.${n}`;
      const page = scan.subsections[key];
      if (!page) { warnings.push(`§ ${key} absent de scan-map.json`); return m; }
      const a = scanAnchor(page, `Scan original — p. ${page} (§ ${key})`,
                           `scan p.&nbsp;${page}`, 'h2-scan');
      return `<h2 id="sec-${s}-${n}"${attrs}>${inner}${a}</h2>`;
    });
}

/* Liminaires — Table des matières : folio cliquable (scan) + titre x.x
   cliquable (transcription de la section). Les folios sont ceux ANNONCÉS
   par la TdM d'origine (fidélité : les divergences connues TdM/corps,
   cf. handoff §6, sont conservées telles quelles). */
function linkTdm(article) {
  const start = article.indexOf('<h2 id="lim-tdm"');
  if (start < 0) return article;
  const end = article.indexOf('</table>', start);
  if (end < 0) return article;
  let seg = article.slice(start, end);

  seg = seg.replace(
    /<td style="text-align: center;">(\d{1,3})<\/td>(\s*)<td style="text-align: left;">([\s\S]*?)<\/td>/g,
    (m, folio, sp, titre) => {
      const pdf = folioToPdf(Number(folio));
      if (!pdf) return m;
      const fcell = scanAnchor(pdf, `Scan original — p. ${pdf} (page interne ${folio})`, folio, 'ref-scan');
      let tcell = titre;
      const mt = titre.replace(/<[^>]+>/g, '').match(/^\s*(\d+)\.(\d+)/);
      if (mt && scan.subsections[`${mt[1]}.${mt[2]}`] !== undefined && !titre.includes('<a ')) {
        const slug = SLUGS[Number(mt[1])];
        if (slug) tcell = `<a class="ref-section" href="${slug}.html#sec-${mt[1]}-${mt[2]}">${titre}</a>`;
      }
      return `<td style="text-align: center;">${fcell}</td>${sp}<td style="text-align: left;">${tcell}</td>`;
    });
  return article.slice(0, start) + seg + article.slice(end);
}

/* Liminaires — Table des planches : chaque N° ouvre la planche. */
function linkTablePlanches(article) {
  const start = article.indexOf('<p>Table des planches</p>');
  if (start < 0) return article;
  const end = article.indexOf('</table>', start);
  if (end < 0) return article;
  let seg = article.slice(start, end);
  seg = seg.replace(/<td style="text-align: center;">(\d+[A-Z]?)<\/td>/g, (m, num) => {
    const a = plancheAnchor(num, num);
    return a ? `<td style="text-align: center;">${a}</td>` : m;
  });
  return article.slice(0, start) + seg + article.slice(end);
}

/* ---------------------------------------------------------------- pages */
const SECTION_FILES = fs.readdirSync(MANUEL)
  .filter((f) => /^(00_liminaires|section_[ivx]+)\.html$/.test(f));

let nbRefs = 0;
for (const file of SECTION_FILES) {
  const p = path.join(MANUEL, file);
  let html = fs.readFileSync(p, 'utf8');
  html = inArticle(html, (article) => {
    article = mapText(article, (t) => linkPlanches(t, file));
    article = addH2Scan(article);
    if (file === '00_liminaires.html') {
      article = linkTdm(article);
      article = linkTablePlanches(article);
    }
    return article;
  });
  const n = (html.match(/class="ref-planche"/g) || []).length;
  nbRefs += n;
  fs.writeFileSync(p, html);
  console.log(`  ✓ ${file} — ${n} renvoi(s) de planche lié(s)`);
}

/* ------------------------------------------------- index des planches */
const rows = planches.planches.map((p) => {
  const cell = p.page
    ? plancheAnchor(p.num, p.num)
    : `${p.num}`;
  const titre = esc(p.titre || '');
  return `<tr id="pl-${p.num}">\n<td style="text-align: center;">${cell}</td>\n<td style="text-align: left;">${titre}</td>\n</tr>`;
}).join('\n');

const indexHtml = `<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Planches · Manuel CM 170</title>
<link rel="stylesheet" href="../../assets/css/fonts.css">
<link rel="stylesheet" href="../../assets/css/manuel.css">
</head>
<body class="lecture">
<header class="lecture-tete">
  <div class="lecture-tete-txt">
    <p class="lecture-chapitre">Manuel de l'équipage — Partie Planches</p>
    <h1 class="lecture-titre">Table des planches</h1>
    <p class="lecture-pages">${planches.planches.length} planches — volume « Illustrations »</p>
  </div>
  <div class="lecture-actions">
    <a class="btn-scan" href="${ILL_HREF}" target="_blank" rel="noopener" data-compare data-label="Planches — volume complet">PDF des planches</a>
  </div>
</header>
<article class="lecture-corps">
<p><em>Les planches sont réunies dans le volume « Partie Planches », distinct
de la Partie Texte. Cliquer un numéro ouvre la planche au bon endroit du
scan — dans le volet de lecture comparée depuis le liseur, dans un nouvel
onglet sinon.</em></p>
<table class="data planches-table">
<colgroup>
<col style="width: 12%" />
<col style="width: 87%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;"><strong>N°</strong></th>
<th style="text-align: left;"><strong>Désignation</strong></th>
</tr>
</thead>
<tbody>
${rows}
</tbody>
</table>
</article>
<footer class="lecture-pied">
  <span>Table des planches d'après les pages liminaires — Manuel de l'équipage, Édition 1975 · Révision 06/1977 — © Valérie Otero — 2026</span>
</footer>
<script src="../../assets/js/lecture.js"></script>
</body>
</html>
`;
fs.writeFileSync(path.join(MANUEL, 'planches.html'), indexHtml);
console.log(`  ✓ planches.html — index de ${planches.planches.length} planches`);
console.log(`Total : ${nbRefs} renvois liés.`);
for (const w of [...new Set(warnings)]) console.warn(`  ! ${w}`);
