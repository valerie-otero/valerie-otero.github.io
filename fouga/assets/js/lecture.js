/* ============================================================
   lecture.js — bibliothèque commune du liseur Manuel CM 170.

   1) FougaRecherche : aides de texte partagées entre la recherche
      (manuel.html) et le surlignage (pages de transcription) :
      pliage casse/accents avec correspondance 1:1 des indices,
      analyse de requête (guillemets = expression exacte),
      recherche d'occurrences, contrôle « mot entier ».
   2) Pages affichées DANS le liseur : les liens data-compare
      (Scan original, renvois de planches) sont interceptés et envoyés
      à l'enveloppe → volet « Lecture comparée ». Hors liseur ou sans
      JavaScript, comportement natif (_blank).
   3) Surlignage : si l'URL porte ?q=…(&m=&e=&c=&a=), les occurrences
      sont marquées dans le corps de l'article et la première est
      amenée à l'écran (utilisé par les résultats de recherche).
      La recherche se fait sur la CONCATÉNATION des nœuds texte :
      une occurrence peut chevaucher un lien ou une mise en gras
      (ex. « planche <a>58</a> ») et reçoit alors plusieurs <mark>.
   ============================================================ */
(function () {
  'use strict';

  /* ---------- 1. Aides de texte (window.FougaRecherche) ---------- */

  /* Plie un caractère : espaces exotiques → espace, apostrophe typographique
     → droite, accents retirés (sauf keepAccents), minuscules (sauf keepCase).
     Caractère par caractère : les indices restent alignés sur l'original. */
  function fold(s, keepCase, keepAccents) {
    var out = '';
    for (var i = 0; i < s.length; i++) {
      var c = s[i];
      if (c === ' ' || c === ' ' || c === '\t' || c === '\n' || c === '\r') c = ' ';
      else if (c === '’') c = "'";
      else {
        if (!keepAccents) c = c.normalize('NFD').charAt(0);
        if (!keepCase) c = c.toLowerCase();
      }
      out += c;
    }
    return out;
  }

  /* Découpe la requête en termes ; "guillemets" (ou « ») = expression.
     mode 'phrase' : toute la requête est une seule expression.
     Les guillemets orphelins (expression en cours de frappe ou non fermée)
     sont retirés des mots : la recherche retombe sur le mot à mot. */
  function parseQuery(q, mode) {
    q = q.replace(/[«»“”]/g, '"');
    if (mode === 'phrase') {
      var t = q.replace(/"/g, ' ').replace(/\s+/g, ' ').trim();
      return t ? [t] : [];
    }
    var terms = [], m, re = /"([^"]+)"|(\S+)/g;
    while ((m = re.exec(q)) !== null) {
      var t2 = (m[1] || m[2].replace(/"/g, '')).replace(/\s+/g, ' ').trim();
      if (t2) terms.push(t2);
    }
    return terms;
  }

  /* Toutes les occurrences (indices [début, fin[) de term dans folded. */
  function findMatches(folded, term) {
    var out = [], i = 0;
    if (!term) return out;
    while ((i = folded.indexOf(term, i)) !== -1) {
      out.push([i, i + term.length]);
      i += 1;
    }
    return out;
  }

  var WORD = /[0-9A-Za-zÀ-ɏ]/;
  /* Vrai si l'occurrence [a,b[ est bornée par des non-lettres (mot entier). */
  function wordOk(folded, a, b) {
    if (a > 0 && WORD.test(folded.charAt(a - 1))) return false;
    if (b < folded.length && WORD.test(folded.charAt(b))) return false;
    return true;
  }

  /* Fusionne des intervalles [a,b[ triés/chevauchants. */
  function merge(ranges) {
    if (!ranges.length) return ranges;
    ranges.sort(function (x, y) { return x[0] - y[0] || x[1] - y[1]; });
    var out = [ranges[0].slice()];
    for (var i = 1; i < ranges.length; i++) {
      var last = out[out.length - 1];
      if (ranges[i][0] <= last[1]) last[1] = Math.max(last[1], ranges[i][1]);
      else out.push(ranges[i].slice());
    }
    return out;
  }

  window.FougaRecherche = {
    fold: fold, parseQuery: parseQuery,
    findMatches: findMatches, wordOk: wordOk, merge: merge
  };

  /* ---------- 2. Relais des liens data-compare vers le liseur ---------- */
  if (window.parent !== window) {
    /* Dans le liseur, les liens scan/planches ne mènent plus directement au
       PDF : la cible réelle passe en data-href et l'attribut target saute,
       pour qu'un clic-molette, un « ouvrir dans un nouvel onglet » ou un
       glisser-déposer n'ouvre ni ne télécharge le document. */
    function proteger() {
      var liens = document.querySelectorAll('a[data-compare]');
      for (var i = 0; i < liens.length; i++) {
        var a = liens[i];
        a.setAttribute('data-href', a.href);
        a.setAttribute('href', '#');
        a.removeAttribute('target');
        a.addEventListener('dragstart', function (e) { e.preventDefault(); });
      }
    }
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', proteger);
    } else {
      proteger();
    }

    document.addEventListener('click', function (e) {
      var a = e.target.closest('a[data-compare]');
      if (!a) return;
      e.preventDefault();
      window.parent.postMessage({
        type: 'fouga-compare',
        href: a.getAttribute('data-href') || a.href,
        label: a.getAttribute('data-label') || a.textContent.replace(/\s+/g, ' ').trim()
      }, '*');
    });
  }

  /* ---------- 3. Surlignage des occurrences (?q=…) ---------- */
  function surligne() {
    var art = document.querySelector('article.lecture-corps');
    if (!art || !window.URLSearchParams) return;
    var p = new URLSearchParams(location.search);
    var q = p.get('q');
    if (!q) return;
    var mode = p.get('m') || 'et';
    var keepCase = p.get('c') === '1';
    var keepAcc = p.get('a') === '1';
    var entier = p.get('e') === '1';
    var terms = parseQuery(q, mode).map(function (t) {
      return fold(t, keepCase, keepAcc);
    }).filter(Boolean);
    if (!terms.length) return;

    /* Nœuds texte de l'article (hors repère d'interface « scan p. N »),
       concaténés en une seule chaîne pliée : fold étant 1:1, l'offset
       global se remappe exactement en (nœud, indice local). */
    var walker = document.createTreeWalker(art, NodeFilter.SHOW_TEXT, null);
    var nodes = [], starts = [], concat = '', n;
    while ((n = walker.nextNode())) {
      var pn = n.parentNode;
      if (pn && pn.closest && pn.closest('a.h2-scan')) continue;
      nodes.push(n);
      starts.push(concat.length);
      concat += fold(n.nodeValue, keepCase, keepAcc);
    }
    if (!concat) return;

    var ranges = [];
    terms.forEach(function (t) {
      findMatches(concat, t).forEach(function (r) {
        if (!entier || wordOk(concat, r[0], r[1])) ranges.push(r);
      });
    });
    if (!ranges.length) return;
    var parts = merge(ranges).slice(0, 1500);

    /* Découpe de chaque intervalle global en segments par nœud. */
    var parNoeud = nodes.map(function () { return []; });
    var ni = 0;
    parts.forEach(function (r) {
      while (ni + 1 < nodes.length && starts[ni + 1] <= r[0]) ni++;
      var i = ni, pos = r[0];
      while (pos < r[1] && i < nodes.length) {
        var debut = starts[i];
        var fin = debut + nodes[i].nodeValue.length;
        var a = Math.max(pos, debut), b = Math.min(r[1], fin);
        if (b > a) parNoeud[i].push([a - debut, b - debut]);
        pos = Math.max(pos, fin);
        i++;
      }
    });

    for (var k = 0; k < nodes.length; k++) {
      var rs = parNoeud[k];
      if (!rs.length) continue;
      var node = nodes[k], txt = node.nodeValue;
      var frag = document.createDocumentFragment(), pos = 0;
      for (var j = 0; j < rs.length; j++) {
        var r = rs[j];
        if (r[0] > pos) frag.appendChild(document.createTextNode(txt.slice(pos, r[0])));
        var mk = document.createElement('mark');
        mk.className = 'surligne';
        mk.textContent = txt.slice(r[0], r[1]);
        frag.appendChild(mk);
        pos = r[1];
      }
      if (pos < txt.length) frag.appendChild(document.createTextNode(txt.slice(pos)));
      node.parentNode.replaceChild(frag, node);
    }

    /* Amener à l'écran la première occurrence pertinente : après l'ancre
       ciblée s'il y en a une (le navigateur a déjà sauté au titre).
       Si aucune marque ne suit l'ancre (plafond atteint avant elle),
       ne pas défiler : rester sur l'ancre. */
    var marks = art.querySelectorAll('mark.surligne');
    if (!marks.length) return;
    var first = marks[0];
    if (location.hash) {
      var cible = document.getElementById(location.hash.slice(1));
      if (cible) {
        first = null;
        for (var i2 = 0; i2 < marks.length; i2++) {
          if (cible.compareDocumentPosition(marks[i2]) & Node.DOCUMENT_POSITION_FOLLOWING) {
            first = marks[i2];
            break;
          }
        }
      }
    }
    if (first) {
      var premier = first;
      setTimeout(function () {
        premier.scrollIntoView({ block: 'center', behavior: 'auto' });
      }, 40);
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', surligne);
  } else {
    surligne();
  }
})();
