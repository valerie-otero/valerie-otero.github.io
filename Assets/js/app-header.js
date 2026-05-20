/* ============================================================
 * app-header.js — Universal FR/EN language switcher
 *
 * Works with multiple per-app i18n conventions on the same page:
 *  - html[lang="fr|en"] + CSS rules in app-header.css
 *  - elements with [data-lang="fr|en"]            (header pattern)
 *  - elements with [data-i18n="fr|en"]            (LectioTempo)
 *  - elements with class .lang-content.fr / .en   (ToDoTasks family)
 *
 * Exposes window.setAppLang(lang) and fires a "langchange" CustomEvent
 * so per-app scripts can react (e.g. swap screenshots, run dict-based i18n).
 * ============================================================ */
(function () {
  'use strict';

  var STORAGE_KEY = 'voApps:lang';

  function detectInitialLang() {
    try {
      var stored = localStorage.getItem(STORAGE_KEY);
      if (stored === 'fr' || stored === 'en') return stored;
    } catch (e) { /* ignore */ }
    var htmlLang = (document.documentElement.getAttribute('lang') || '').toLowerCase();
    if (htmlLang.indexOf('en') === 0) return 'en';
    if (htmlLang.indexOf('fr') === 0) return 'fr';
    var navLang = (navigator.language || navigator.userLanguage || 'fr').toLowerCase();
    return navLang.indexOf('fr') === 0 ? 'fr' : 'en';
  }

  function setAppLang(lang) {
    if (lang !== 'fr' && lang !== 'en') lang = 'fr';

    // 1. html[lang] — drives CSS visibility for [data-lang] and [data-i18n]
    document.documentElement.setAttribute('lang', lang);

    // 2. Lang buttons active state
    var btns = document.querySelectorAll('[data-lang-btn]');
    for (var i = 0; i < btns.length; i++) {
      var match = btns[i].getAttribute('data-lang-btn') === lang;
      btns[i].classList.toggle('is-active', match);
      btns[i].setAttribute('aria-pressed', match ? 'true' : 'false');
    }

    // 3. .lang-content.fr / .lang-content.en (ToDoTasks family)
    var contents = document.querySelectorAll('.lang-content');
    for (var j = 0; j < contents.length; j++) {
      var el = contents[j];
      var isThisLang =
        (lang === 'fr' && el.classList.contains('fr')) ||
        (lang === 'en' && el.classList.contains('en'));
      el.classList.toggle('hidden', !isThisLang);
    }

    // 3b. #content-fr / #content-en (QuantumPass / SkyNotes / METAR / AirMulti / CapRoute family)
    var cFr = document.getElementById('content-fr');
    var cEn = document.getElementById('content-en');
    if (cFr) cFr.classList.toggle('hidden', lang !== 'fr');
    if (cEn) cEn.classList.toggle('hidden', lang !== 'en');

    // 3c. <title data-fr="..." data-en="..."> — swap document title
    var titleEl = document.querySelector('title[data-fr][data-en]');
    if (titleEl) {
      var t = titleEl.getAttribute('data-' + lang);
      if (t) {
        titleEl.textContent = t;
        try { document.title = t; } catch (e) { /* ignore */ }
      }
    }

    // 3d. <meta name="description" data-fr="..." data-en="..."> — swap meta description
    var metaDesc = document.querySelector('meta[name="description"][data-fr][data-en]');
    if (metaDesc) {
      var d = metaDesc.getAttribute('data-' + lang);
      if (d) metaDesc.setAttribute('content', d);
    }

    // 4. Persist
    try { localStorage.setItem(STORAGE_KEY, lang); } catch (e) { /* ignore */ }

    // 5. Notify the app for per-app effects (screenshots, dict, etc.)
    try {
      document.dispatchEvent(new CustomEvent('langchange', { detail: { lang: lang } }));
    } catch (e) {
      // Old IE fallback (not needed in production, but safe)
      var ev = document.createEvent('CustomEvent');
      ev.initCustomEvent('langchange', true, true, { lang: lang });
      document.dispatchEvent(ev);
    }
  }

  window.setAppLang = setAppLang;

  // Delegated click handler — works even if header is injected later
  document.addEventListener('click', function (e) {
    var btn = e.target && e.target.closest && e.target.closest('[data-lang-btn]');
    if (!btn) return;
    e.preventDefault();
    setAppLang(btn.getAttribute('data-lang-btn'));
  });

  // Burger toggle for mobile menu
  document.addEventListener('click', function (e) {
    var burger = e.target && e.target.closest && e.target.closest('.app-nav-burger');
    if (burger) {
      e.preventDefault();
      var nav = burger.closest('.app-nav');
      if (nav) nav.classList.toggle('is-open');
      return;
    }
    // Close menu when a link is clicked
    var link = e.target && e.target.closest && e.target.closest('.app-nav-links a');
    if (link) {
      var openNav = document.querySelector('.app-nav.is-open');
      if (openNav) openNav.classList.remove('is-open');
    }
  });

  // Apply body class so layout reserves space for the fixed bar
  function ensureBodyClass() {
    if (document.body && document.querySelector('.app-nav')) {
      document.body.classList.add('has-app-nav');
    }
  }

  function init() {
    ensureBodyClass();
    setAppLang(detectInitialLang());
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
