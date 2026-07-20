--[[
  manuel-filter.lua — re-balise la sortie pandoc des transcriptions OCR
  (Manuel de l'équipage Fouga CM 170) SANS jamais altérer le texte.

  Transformations (niveau AST uniquement) :
   1. Retire le bloc de titre répété en tête de chaque section
      (« FOUGA CM 170 » / « Manuel de l'équipage… » / « CHAPITRE… » / « Édition 1975… »)
      car le liseur le réaffiche dans son en-tête.
   2. Détecte les titres numérotés (7.1., 3.1.1., 8.1 …) rendus en <p> par pandoc
      et les convertit en <h2>/<h3>/<h4> selon la profondeur de numérotation.
   3. Encadrés ATTENTION : tableaux 1 cellule commençant par « ATTENTION »
      → <div class="encadre">.
   4. NOTA / N.B. / IMPORTANT / REMARQUE : paragraphes à amorce grasse
      → <div class="note">.
   5. Corps de texte rendu en <blockquote> par pandoc → paragraphes normaux.
   6. Vrais tableaux de données → classe "data" pour l'habillage à la charte.
]]

local stringify = pandoc.utils.stringify

-- Titres non numérotés des pages liminaires (texte exact -> ancre)
local LIM_HEADINGS = {
  ["Index des pages"]    = "lim-index",
  ["Table des matières"] = "lim-tdm",
  ["Tables des matières"] = "lim-tdm",
}

-- Lignes du bloc de titre à supprimer
local function is_title_block(text)
  if text == "FOUGA CM 170" then return true end
  -- apostrophe typographique = multi-octets : on s'arrête à « Manuel de l »
  if text:match("^Manuel de l") then return true end
  if text:match("^CHAPITRE ") then return true end
  if text:match("^Édition 1975") then return true end
  return false
end

-- Compte les composants d'une numérotation « 7.1.1 » -> 3
local function level_of(num)
  local n = 0
  for _ in num:gmatch("%d+") do n = n + 1 end
  return n
end

function Para(el)
  local text = stringify(el)

  -- 1. bloc de titre répété
  if is_title_block(text) then
    return {}
  end

  -- 1bis. titres non numérotés des liminaires
  local limid = LIM_HEADINGS[text]
  if limid then
    return pandoc.Header(2, el.content, pandoc.Attr(limid))
  end

  -- 4. NOTA / IMPORTANT / N.B. / REMARQUE (amorce grasse en début de paragraphe)
  local first = el.content[1]
  if first and first.t == "Strong" then
    local lead = stringify(first)
    if lead:match("^NOTA") or lead:match("^IMPORTANT") or lead:match("^N%.B%.")
       or lead:match("^REMARQUE") then
      return pandoc.Div(el, { class = "note" })
    end
  end

  -- 2. titre numéroté : « 7.1. », « 3.1.1. », « 8.1 »…
  --    (au moins chiffre.point.chiffre pour éviter « 1) », « 122 l », « 2 réservoirs »)
  local num = text:match("^(%d+%.%d[%d%.]*)")
  if num then
    local lvl = level_of(num)
    if lvl < 2 then lvl = 2 end
    if lvl > 5 then lvl = 5 end
    -- ancre stable d'après la numérotation : « 6.9.2 » -> id="sec-6-9-2"
    local id = "sec-" .. num:gsub("%.$", ""):gsub("%.", "-")
    return pandoc.Header(lvl, el.content, pandoc.Attr(id))
  end

  -- 7. items à numérotation / lettre manuelle (« 1) », « 2) », « a) », « b) »,
  --    « A - », « 1 - »…) : le numéro d'origine est préservé tel quel (jamais
  --    renuméroté), mais l'item reçoit un retrait pendant (les lignes suivantes
  --    s'alignent sous le texte, pas sous le numéro). Détection sur l'amorce.
  if text:match("^%d+%)%s")        -- 1) 2) 10)
     or text:match("^%l%)%s")      -- a) b) c)
     or text:match("^%u%)%s")      -- A) B)
     or text:match("^%d+%s?%-%s%a")-- 1 - / 1-  (suivi d'une LETTRE : exclut les plages « 110 - 120 »)
     or text:match("^%u%s?%-%s%a") -- A - / A-  (idem)
  then
    return pandoc.Div(pandoc.Plain(el.content), { class = "numitem" })
  end

  return nil
end

-- un bloc est-il un Div portant la classe c ?
local function is_div_class(b, c)
  return b and b.t == "Div" and b.attr.classes:includes(c)
end

-- 5 & 8. blockquote pandoc :
--   - NOTE : le 1er bloc est un Div.note (produit par Para règle 4). On REGROUPE
--     tout le blockquote dans un seul encadré. Si des items numérotés (numitem,
--     règle 7) suivent, on construit une « note-list » : le label « NOTA : » est
--     mis en saillie dans une colonne auto-dimensionnée (grille) et les items
--     1) 2) 3)… sont alignés dessous, chacun en retrait pendant. Le 1er item,
--     collé au label sur la même ligne d'origine, est détaché sans altérer le texte.
--   - sinon (corps de texte rendu en blockquote par pandoc) : déballage en paragraphes.
function BlockQuote(el)
  local first = el.content[1]
  if is_div_class(first, "note") then
    local para = first.content[1]                 -- paragraphe amorce (Strong « NOTA : » + reste)
    local rest = {}
    for i = 2, #el.content do rest[#rest + 1] = el.content[i] end
    local has_items = false
    for _, b in ipairs(rest) do
      if is_div_class(b, "numitem") then has_items = true break end
    end

    if has_items and para and para.t == "Para"
       and para.content[1] and para.content[1].t == "Strong" then
      local label = para.content[1]
      -- 1er item = reste du paragraphe amorce (après le label et l'espace initial)
      local item1 = {}
      for i = 2, #para.content do
        local inl = para.content[i]
        if not (#item1 == 0 and inl.t == "Space") then item1[#item1 + 1] = inl end
      end
      local items = {}
      if #item1 > 0 then
        items[#items + 1] = pandoc.Div(pandoc.Plain(item1), { class = "numitem" })
      end
      for _, b in ipairs(rest) do items[#items + 1] = b end
      return pandoc.Div({
        pandoc.Div(pandoc.Plain({ label }), { class = "nl-lbl" }),
        pandoc.Div(items, { class = "nl-items" }),
      }, pandoc.Attr("", { "note", "note-list" }))
    end

    -- note multi-blocs sans items numérotés : tout regrouper dans un seul encadré
    local blocks = { para }
    for _, b in ipairs(rest) do blocks[#blocks + 1] = b end
    return pandoc.Div(blocks, { class = "note" })
  end
  return el.content
end

-- 3 & 6. tableaux
function Table(el)
  local body = el.bodies[1]
  if body and body.body[1] and body.body[1].cells[1] then
    local cell = body.body[1].cells[1]
    local celltext = stringify(cell.contents)
    -- une seule colonne + amorce « ATTENTION » => encadré
    if #el.colspecs == 1 and celltext:match("^%s*ATTENTION") then
      local blocks = cell.contents
      -- baliser le titre ATTENTION si c'est le premier bloc
      if blocks[1] and stringify(blocks[1]):match("^%s*ATTENTION%s*$") then
        blocks[1] = pandoc.Div(blocks[1], { class = "encadre-titre" })
      end
      return pandoc.Div(blocks, { class = "encadre" })
    end
  end
  -- vrai tableau de données
  el.attr.classes:insert("data")
  return el
end
