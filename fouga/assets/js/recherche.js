/* ============================================================
   recherche.js — moteur de recherche du liseur (manuel.html).
   S'appuie sur :
     - window.FOUGA_RECHERCHE (index généré, recherche-index.js)
     - window.FougaRecherche  (aides de texte, lecture.js)
   Barre simple : tous les mots, accents et casse ignorés,
   "guillemets" pour une expression exacte.
   Recherche avancée : tous les mots / au moins un / expression,
   mots entiers, casse, accents, restriction à une section.
   Les résultats s'ouvrent dans le volet de lecture avec surlignage
   (?q=…) et synchronisent la lecture comparée (data-scan).
   Sans JavaScript, le bloc de recherche reste masqué.
   ============================================================ */
(function () {
  'use strict';
  var IDX = window.FOUGA_RECHERCHE;
  var LIB = window.FougaRecherche;
  var box = document.querySelector('.recherche');
  if (!IDX || !LIB || !box) return;

  var sommaire = document.querySelector('.sommaire');
  var form = box.querySelector('.recherche-form');
  var champ = box.querySelector('.recherche-champ');
  var resBox = box.querySelector('.recherche-resultats');
  var statut = box.querySelector('.recherche-statut');
  var porte = box.querySelector('.ropt-porte');

  box.hidden = false;

  var MAX_HITS = 400;     // arrêt du balayage
  var MAX_AFFICHE = 250;  // résultats rendus

  function options() {
    var mode = box.querySelector('input[name="rmode"]:checked');
    return {
      mode: mode ? mode.value : 'et',
      entier: box.querySelector('.ropt-entier').checked,
      casse: box.querySelector('.ropt-casse').checked,
      accents: box.querySelector('.ropt-accents').checked,
      porte: porte ? porte.value : ''
    };
  }

  /* Textes pliés des blocs, recalculés quand casse/accents changent. */
  var cacheCle = null, cachePlie = null;
  function blocsPlies(o) {
    var cle = (o.casse ? 'c' : '') + (o.accents ? 'a' : '');
    if (cle !== cacheCle) {
      cachePlie = IDX.blocs.map(function (b) { return LIB.fold(b[2], o.casse, o.accents); });
      cacheCle = cle;
    }
    return cachePlie;
  }

  var esc = function (s) {
    return s.replace(/&/g, '&amp;').replace(/</g, '&lt;')
            .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  };

  /* Extrait ±90 caractères autour de la première occurrence, toutes les
     occurrences de la fenêtre marquées. */
  function extrait(texte, ranges) {
    var parts = LIB.merge(ranges);
    var a = Math.max(0, parts[0][0] - 55);
    var b = Math.min(texte.length, parts[0][1] + 95);
    var html = a > 0 ? '… ' : '';
    var pos = a;
    for (var i = 0; i < parts.length; i++) {
      var r = parts[i];
      if (r[0] >= b) break;
      if (r[0] > pos) html += esc(texte.slice(pos, r[0]));
      html += '<mark>' + esc(texte.slice(r[0], Math.min(r[1], b))) + '</mark>';
      pos = Math.min(r[1], b);
    }
    if (pos < b) html += esc(texte.slice(pos, b));
    if (b < texte.length) html += ' …';
    return html;
  }

  function ferme() {
    resBox.hidden = true;
    resBox.innerHTML = '';
    if (statut) statut.textContent = '';
    sommaire.classList.remove('recherche-active');
  }

  function lance() {
    var q = champ.value.trim();
    var o = options();
    if (q.replace(/["«»“”]/g, '').trim().length < 2) { ferme(); return; }
    var terms = LIB.parseQuery(q, o.mode).map(function (t) {
      return LIB.fold(t, o.casse, o.accents);
    }).filter(Boolean);
    if (!terms.length) { ferme(); return; }

    var plies = blocsPlies(o);
    var hits = [];
    for (var i = 0; i < IDX.blocs.length && hits.length < MAX_HITS; i++) {
      var b = IDX.blocs[i];
      if (o.porte && IDX.sections[b[0]].slug !== o.porte) continue;
      var f = plies[i];
      var trouves = 0, ranges = [];
      for (var t = 0; t < terms.length; t++) {
        var ms = LIB.findMatches(f, terms[t]);
        if (o.entier) {
          ms = ms.filter(function (r) { return LIB.wordOk(f, r[0], r[1]); });
        }
        if (ms.length) { trouves++; ranges = ranges.concat(ms); }
        else if (o.mode !== 'ou') break;        // ET / expression : tout requis
      }
      var ok = o.mode === 'ou' ? trouves > 0 : trouves === terms.length;
      if (ok) hits.push({ b: b, ranges: ranges });
    }
    affiche(q, o, hits);
  }

  function urlDe(sec, ancre, q, o) {
    var u = 'pages/manuel/' + sec.slug + '.html?q=' + encodeURIComponent(q) +
            '&m=' + o.mode +
            (o.entier ? '&e=1' : '') + (o.casse ? '&c=1' : '') + (o.accents ? '&a=1' : '');
    return ancre ? u + '#' + ancre : u;
  }

  function affiche(q, o, hits) {
    var bilan = hits.length
      ? (hits.length >= MAX_HITS ? hits.length + '+' : hits.length) +
        ' résultat' + (hits.length > 1 ? 's' : '')
      : 'Aucun résultat';
    if (statut) statut.textContent = bilan;   // annonce lecteur d'écran (role=status)
    var html = '<div class="recherche-bilan"><span>' + bilan +
      '</span><button type="button" class="recherche-effacer" title="Effacer la recherche">effacer ✕</button></div>';

    var courant = -1, rendus = 0;
    for (var i = 0; i < hits.length && rendus < MAX_AFFICHE; i++) {
      var h = hits[i], b = h.b, sec = IDX.sections[b[0]];
      if (b[0] !== courant) {
        var n = hits.filter(function (x) { return x.b[0] === b[0]; }).length;
        html += '<div class="res-sec">' + esc(sec.label) + ' <span>' + n + '</span></div>';
        courant = b[0];
      }
      var ancre = b[1];
      var attrs = ' target="lecteur"';
      if (ancre && IDX.planches[ancre] !== undefined) {
        attrs += ' data-scan-ill="' + IDX.planches[ancre] + '"' +
                 ' data-label="Planche ' + esc(ancre.slice(3)) + '"';
      } else if (ancre && IDX.scans[ancre] !== undefined) {
        attrs += ' data-scan="' + IDX.scans[ancre] + '"';
      } else if (sec.scan) {
        attrs += ' data-scan="' + sec.scan + '"';
      }
      var contexte = b[3] ? sec.label
        : (ancre && IDX.titres[b[0]][ancre]) ? IDX.titres[b[0]][ancre] : sec.label;
      html += '<a class="res-item" href="' + esc(urlDe(sec, ancre, q, o)) + '"' + attrs + '>' +
              '<span class="res-titre">' + esc(contexte) + '</span>' +
              '<span class="res-extrait">' + extrait(b[2], h.ranges) + '</span></a>';
      rendus++;
    }
    if (hits.length > MAX_AFFICHE) {
      html += '<p class="res-tronque">' + (hits.length - MAX_AFFICHE) +
              ' autres résultats non affichés — précisez la recherche.</p>';
    }
    resBox.innerHTML = html;
    resBox.hidden = false;
    sommaire.classList.add('recherche-active');
    var eff = resBox.querySelector('.recherche-effacer');
    if (eff) eff.addEventListener('click', function () { champ.value = ''; ferme(); champ.focus(); });
  }

  /* Saisie : recherche en direct (300 ms), Entrée, Échap pour effacer. */
  var minuterie = null;
  champ.addEventListener('input', function () {
    clearTimeout(minuterie);
    minuterie = setTimeout(lance, 300);
  });
  champ.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') { champ.value = ''; ferme(); }
  });
  form.addEventListener('submit', function (e) { e.preventDefault(); clearTimeout(minuterie); lance(); });
  box.querySelectorAll('input[name="rmode"], .ropt-entier, .ropt-casse, .ropt-accents, .ropt-porte')
    .forEach(function (el) {
      el.addEventListener('change', function () {
        if (champ.value.trim().length >= 2) lance();
      });
    });
})();
