#!/usr/bin/env node
/* ============================================================================
   build-sommaire.js — génère l'enveloppe manuel.html (le liseur).
   Moissonne les titres <h2 id="sec-..."> de chaque page de section
   (produites par build-manuel.sh puis build-refs.js) pour construire :
     - un groupe <details> repliable par section,
     - un lien « ouvrir la section » + un lien par sous-section x.x,
       chacun portant data-scan (page du scan TEXTE où commence la
       sous-section, carte build/manuel/scan-map.json) pour la
       synchronisation du volet « Lecture comparée »,
     - un accès « Planches » vers l'index cliquable pages/manuel/planches.html,
     - le volet « Lecture comparée » : le scan (TEXTE ou ILLUSTRATIONS)
       s'affiche côte à côte avec la transcription. Amélioration progressive :
       sans JavaScript, les liens du texte s'ouvrent dans un nouvel onglet
       et le volet n'apparaît pas.
   Pur Node, sans réseau. À relancer après build-manuel.sh + build-refs.js.
   ============================================================================ */
'use strict';
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..', '..');
const MANUEL = path.join(ROOT, 'pages', 'manuel');
const scan = JSON.parse(fs.readFileSync(path.join(__dirname, 'scan-map.json'), 'utf8'));

// Ordre + libellés courts des groupes du sommaire
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
];

const TEXTE = 'FOUGA%20CM.170%20TEXTE.pdf';
const ILLUSTRATIONS = 'FOUGA%20CM.170%20ILLUSTRATIONS.pdf';
const DEFAULT_PAGE = 'pages/manuel/00_liminaires.html';

const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;');

// Décode les entités HTML simples produites par pandoc dans les titres
const decode = (s) => s.replace(/&amp;/g, '&').replace(/&lt;/g, '<')
                       .replace(/&gt;/g, '>').replace(/&#39;/g, '’').replace(/&quot;/g, '"');

// Extrait [{id, text}] des <h2 id="..."> d'un fichier de section
// (en ignorant le repère « scan p. N » ajouté par build-refs.js)
function headings(slug) {
  const html = fs.readFileSync(path.join(MANUEL, `${slug}.html`), 'utf8');
  const out = [];
  const re = /<h2[^>]*\bid="([^"]+)"[^>]*>([\s\S]*?)<\/h2>/g;
  let m;
  while ((m = re.exec(html)) !== null) {
    const id = m[1];
    const inner = m[2].replace(/<a class="h2-scan"[\s\S]*?<\/a>/g, '');
    const text = decode(inner.replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim());
    out.push({ id, text });
  }
  return out;
}

// Page du scan TEXTE où commence la sous-section sec-x-y (sinon début de section)
function scanOf(slug, id) {
  const m = id.match(/^sec-(\d+)-(\d+)$/);
  if (m) {
    const p = scan.subsections[`${m[1]}.${m[2]}`];
    if (p !== undefined) return p;
  }
  return scan.sections[slug];
}

// Construit un groupe <details> de sommaire
function group(sec, open) {
  const hs = headings(sec.slug);
  const href = `pages/manuel/${sec.slug}.html`;
  const secScan = scan.sections[sec.slug];
  const subs = hs.map((h) => {
    const p = scanOf(sec.slug, h.id);
    const ds = p !== undefined ? ` data-scan="${p}"` : '';
    return `        <a href="${href}#${h.id}" target="lecteur"${ds}>${esc(h.text)}</a>`;
  }).join('\n');
  const dsec = secScan !== undefined ? ` data-scan="${secScan}"` : '';
  return `      <details class="grp"${open ? ' open' : ''}>
        <summary>${esc(sec.label)}</summary>
        <div class="sous">
        <a class="lien-sec" href="${href}" target="lecteur"${dsec}>Ouvrir la section ▸</a>
${subs}
        </div>
      </details>`;
}

const groups = SECTIONS.map((s, i) => group(s, i === 0)).join('\n');

// Restriction de portée de la recherche avancée (sections + planches)
const portes = [
  '          <option value="">Tout le manuel</option>',
  ...SECTIONS.map((s) => `          <option value="${s.slug}">${esc(s.label)}</option>`),
  '          <option value="planches">Planches (illustrations)</option>',
].join('\n');

// Bloc de recherche (masqué sans JavaScript ; révélé par recherche.js)
const recherche = `      <div class="recherche" hidden>
        <form class="recherche-form" role="search">
          <input type="search" class="recherche-champ" placeholder="Rechercher dans le manuel…"
                 aria-label="Rechercher dans le manuel" autocomplete="off" spellcheck="false">
          <button type="submit" class="recherche-go" title="Rechercher" aria-label="Rechercher">⌕</button>
        </form>
        <details class="recherche-avancee">
          <summary>Recherche avancée</summary>
          <div class="recherche-options">
            <label><input type="radio" name="rmode" value="et" checked> Tous les mots</label>
            <label><input type="radio" name="rmode" value="ou"> Au moins un mot</label>
            <label><input type="radio" name="rmode" value="phrase"> Expression exacte</label>
            <hr>
            <label><input type="checkbox" class="ropt-entier"> Mots entiers</label>
            <label><input type="checkbox" class="ropt-casse"> Respecter la casse</label>
            <label><input type="checkbox" class="ropt-accents"> Respecter les accents</label>
            <label class="recherche-porte">Chercher dans
              <select class="ropt-porte">
${portes}
              </select>
            </label>
            <p class="recherche-astuce">Astuce&nbsp;: entourez une expression de "guillemets" pour la chercher telle quelle.</p>
          </div>
        </details>
        <p class="recherche-statut" role="status"></p>
        <div class="recherche-resultats" hidden></div>
      </div>`;

const html = `<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manuel CM 170 · Computeur de vol — Fouga CM 170 R Magister</title>
<link rel="stylesheet" href="assets/css/fonts.css">
<link rel="stylesheet" href="assets/css/site.css">
<link rel="stylesheet" href="assets/css/manuel.css">
</head>
<body>
<header class="bandeau">
  <div class="bandeau-titres">
    <h1 class="bandeau-titre">Fouga CM&nbsp;170&nbsp;R <span class="filet">·</span> Magister</h1>
  </div>
  <nav class="bandeau-nav" aria-label="Navigation principale">
    <a href="index.html">Présentation</a>
    <a href="manuel.html" class="actif" aria-current="page">Manuel CM 170</a>
    <a href="computeur.html">Computeur</a>
  </nav>
</header>
<main class="contenu">
  <div class="manuel-shell">
    <aside class="sommaire" aria-label="Sommaire du manuel">
      <div class="sommaire-tete">Manuel de l’équipage</div>
      <nav>
${recherche}
${groups}
        <button class="comparer" type="button" hidden>Lecture comparée ⇆</button>
        <a class="planches" href="pages/manuel/planches.html" target="lecteur">Planches (illustrations)</a>
      </nav>
    </aside>
    <iframe class="lecteur" name="lecteur" src="${DEFAULT_PAGE}" title="Transcription du manuel"></iframe>
    <div class="comparateur-poignee" role="separator" aria-orientation="vertical" tabindex="0"
         aria-label="Régler le partage texte / scan"
         title="Glisser pour régler le partage (double-clic : moitié-moitié)"></div>
    <section class="comparateur" aria-label="Document original — lecture comparée">
      <div class="comparateur-barre">
        <span class="comparateur-label">Scan original</span>
        <span class="comparateur-outils">
          <button class="comparateur-fermer" type="button" title="Fermer la lecture comparée">✕</button>
        </span>
      </div>
      <div class="comparateur-corps"></div>
    </section>
  </div>
</main>
<footer class="pied">
  <span>© Valérie Otero — 2026</span>
</footer>
<script>
/* Liseur : surlignage de l'entrée active + volet « Lecture comparée ».
   Amélioration progressive : sans JS, la navigation iframe fonctionne,
   les liens scan/planches s'ouvrent dans un nouvel onglet. */
(function () {
  var nav = document.querySelector('.sommaire nav');
  var shell = document.querySelector('.manuel-shell');
  var pane = document.querySelector('.comparateur');
  var corps = pane.querySelector('.comparateur-corps');
  var label = pane.querySelector('.comparateur-label');
  var btn = document.querySelector('.sommaire .comparer');
  var cur = { href: '${TEXTE}#page=4', label: 'Scan original — p. 4' };

  btn.hidden = false;

  /* Visualiseur PDF sans sa barre d'outils : pas de bouton télécharger /
     imprimer (Chrome, Edge, Firefox ; Safari n'a pas de barre intégrée). */
  function pdf(href) {
    return href + (href.indexOf('#') === -1 ? '#' : '&') + 'toolbar=0&navpanes=0';
  }

  function show(d) {
    cur = d;
    label.textContent = d.label;
    label.title = d.label;
    corps.innerHTML = '';
    var f = document.createElement('iframe');
    f.className = 'comparateur-pdf';
    f.title = 'Document original (scan)';
    f.src = pdf(d.href);
    corps.appendChild(f);
    shell.classList.add('compare');
    btn.classList.add('ouvert');
    btn.textContent = 'Fermer la comparaison ✕';
  }
  function hide() {
    shell.classList.remove('compare');
    corps.innerHTML = '';
    btn.classList.remove('ouvert');
    btn.textContent = 'Lecture comparée ⇆';
  }

  btn.addEventListener('click', function () {
    if (shell.classList.contains('compare')) hide(); else show(cur);
  });
  pane.querySelector('.comparateur-fermer').addEventListener('click', hide);

  /* Poignée : réglage du partage texte / scan. Glisser (la capture du
     pointeur maintient le suivi au-dessus des iframes), flèches gauche /
     droite au clavier, double-clic : retour moitié-moitié. */
  var poignee = document.querySelector('.comparateur-poignee');
  function partage(largeur) {
    var r = shell.getBoundingClientRect();
    var texte = shell.querySelector('.lecteur').getBoundingClientRect();
    var maxi = Math.max(r.right - texte.left - 280, 280); /* garder 280px de texte */
    pane.style.flex = '0 1 ' + Math.round(Math.max(280, Math.min(largeur, maxi))) + 'px';
  }
  poignee.addEventListener('pointerdown', function (e) {
    e.preventDefault();
    poignee.setPointerCapture(e.pointerId);
    shell.classList.add('reglage');
  });
  poignee.addEventListener('pointermove', function (e) {
    if (shell.classList.contains('reglage')) {
      partage(shell.getBoundingClientRect().right - e.clientX);
    }
  });
  poignee.addEventListener('pointerup', function () { shell.classList.remove('reglage'); });
  poignee.addEventListener('lostpointercapture', function () { shell.classList.remove('reglage'); });
  poignee.addEventListener('dblclick', function () { pane.style.flex = ''; });
  poignee.addEventListener('keydown', function (e) {
    if (e.key !== 'ArrowLeft' && e.key !== 'ArrowRight') return;
    e.preventDefault();
    partage(pane.getBoundingClientRect().width + (e.key === 'ArrowLeft' ? 48 : -48));
  });

  /* Liens data-compare des pages affichées dans le lecteur (scan original,
     renvois de planches, repères de titres) — relayés par postMessage. */
  window.addEventListener('message', function (e) {
    var d = e.data;
    if (!d || d.type !== 'fouga-compare' || !d.href) return;
    show({ href: d.href, label: d.label || 'Document original' });
  });

  /* Sommaire et résultats de recherche : surlignage actif +
     synchronisation de la lecture comparée (data-scan / data-scan-ill). */
  if (!nav) return;
  nav.addEventListener('click', function (e) {
    var a = e.target.closest('a[target="lecteur"]');
    if (!a) return;
    var prev = nav.querySelector('a.actif');
    if (prev) { prev.classList.remove('actif'); prev.removeAttribute('aria-current'); }
    a.classList.add('actif');
    a.setAttribute('aria-current', 'true');
    var pi = a.getAttribute('data-scan-ill');
    var p = a.getAttribute('data-scan');
    var d = null;
    if (pi) d = { href: '${ILLUSTRATIONS}#page=' + pi,
                  label: a.getAttribute('data-label') || 'Planche' };
    else if (p) d = { href: '${TEXTE}#page=' + p, label: 'Scan original — p. ' + p };
    if (d) {
      if (shell.classList.contains('compare')) show(d); else cur = d;
    }
  });
})();
</script>
<script src="assets/js/lecture.js"></script>
<script src="assets/js/recherche-index.js"></script>
<script src="assets/js/recherche.js"></script>
</body>
</html>
`;

fs.writeFileSync(path.join(ROOT, 'manuel.html'), html);
const total = SECTIONS.reduce((n, s) => n + headings(s.slug).length, 0);
console.log(`manuel.html généré — ${SECTIONS.length} groupes, ${total} sous-sections.`);
