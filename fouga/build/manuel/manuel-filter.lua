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

  return nil
end

-- 5. corps en blockquote -> paragraphes normaux
function BlockQuote(el)
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
