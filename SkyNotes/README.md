# SkyNotes — Spécification Technique v2.0

Auteur: Valérie Otero  
Application: SkyNotes (iOS & macOS, SwiftUI + SwiftData)  
Date: 22/11/2025

---

## 1. Objet et périmètre

Document de référence pour développeurs et chefs de projet. Décrit les fonctionnalités, modèles de données, formats d’échange, flux UI, choix techniques et lignes directrices pour portage multi‑plateformes (Android, desktop macOS/Windows, Web). Cible la version 2.0 (iOS & macOS).

## 2. Résumé fonctionnel

- Projets (titre, détail, dates) et checklists associées
- Checklists colorées, items réordonnables, statut coché/non coché
- Types de liste: Checklist vs To‑Do (icône, teinte, sémantique)
- Recherche par mots‑clés sur titres et contenu (items et notes), insensible aux accents/majuscules
- Tri local (titre, dates, position, nombre d’items)
- Duplication de projets et de checklists
- Corbeille (isDeleted) avec restauration/suppression définitive
- Import/Export: Markdown (.md) et CSV (.csv)
  - Single project & multi-projets (séparateurs Markdown ou colonne ProjectTitle)
- Export multi-projets (sélection ou global)
- À propos (métadonnées, crédits, politique de confidentialité)

## 3. Architecture et technologies (référence iOS & macOS)

- UI: SwiftUI (adaptatif iOS/macOS)
- Persistance: SwiftData (@Model, @Query, ModelContext)
- Navigation: NavigationStack + navigation par UUID (refetch sécurisé)
- Fichiers: FileDocument/UTType; sandbox avec accès « security‑scoped »
- Design system: couleurs via enum PostItColor, icônes SF Symbols
- macOS Spécifique:
  - Suppression des ombres et contours système sur les boutons
  - Fonds blancs pour les vues principales
  - Gestion des fenêtres et menus natifs

## 4. Modèle de données (conceptuel et iOS)

### 4.1 Entités

- Project
  - id: UUID (unique)
  - title: String
  - detail: String
  - createdAt: Date
  - updatedAt: Date
  - checklists: [Checklist] (deleteRule: cascade)
- Checklist
  - id: UUID (unique)
  - title: String
  - color: PostItColor (String rawValue)
  - items: [ChecklistItem]
  - project: Project?
  - createdAt: Date
  - updatedAt: Date
  - isDeleted: Bool (corbeille)
  - position: Int? (ordre visuel)
  - typeRaw: String (Checklist | todo)
- ChecklistItem
  - id: UUID (unique)
  - text: String
  - note: String?
  - isChecked: Bool
  - order: Int

### 4.2 Règles et contraintes

- Cascade delete: suppression d’un Project supprime ses Checklists
- position: compacte et réindexée lors des réordonnancements
- typeRaw: expose `type: ChecklistType` (checklist|todo)
- Sécurité: pas de navigation avec références invalides (refetch par id)

## 5. Formats d’échange

### 5.1 Markdown (.md)

- Projet (single):
  - Titre: `# <Project Title>`
  - Détail (optionnel): `> Detail: <one-line>`
  - Checklist: `## <Checklist Title> [type=<checklist|todo>][color=<postitcolor>]`
  - Item: `- [x] Text ::: Note` (ou `[ ]`)
- Multi-projets:
  - Concaténation de blocs single séparés par `---` (lignes seules)
  - À l’import: split par `---` ou par titres `#` multiples

### 5.2 CSV (.csv)

- Projet (single):
  - En‑tête: `ChecklistTitle,Type,Color,ItemOrder,Checked,Text,Note`
- Multi-projets:
  - En‑tête: `ProjectTitle,ChecklistTitle,Type,Color,ItemOrder,Checked,Text,Note`
  - Groupement à l’import par `ProjectTitle` puis `ChecklistTitle`

### 5.3 Règles communes

- Échappement CSV: guillemets doublés, champs entre quotes si nécessaire
- Markdown: `:::` dans les notes est échappé en `::‧` à l’export
- Import diacritique‑robuste pour `type` et `color` (fallback par défaut)
- Titre projet unique: suffixe `(n)` en cas de collision

## 6. Flux UI (référence iOS)

- ProjectsView
  - Liste triée/recherchable, création/renommage/duplication, import/export (mono, multi), About
  - Navigation vers ProjectDetail via UUID
- ProjectDetailView
  - Grille de checklists, ajout avec type, tri, recherche locale, export projet
  - Couleurs via menu, réordonnancement, corbeille
- HomeView
  - Grille globale des checklists, recherche/tri, filtrage par type
- TrashView
  - Restauration/suppression définitive

## 7. Recherche et tri

- Recherche par tokens (split espaces), pliage diacritique + case‑insensitive
- AND logique: tous les tokens doivent correspondre dans (titres, items, notes, titre projet)
- Tri: titre (A→Z/Z→A), dates (créé/MAJ), position, nombre d’items

## 8. Règles de migration / portage multi‑plateformes

### 8.1 Couches à isoler

- Domaine (entités, services import/export, règles métier)
- Persistance (ORM/DB) : adapter selon plateforme
- UI (composants, navigation)

### 8.2 Mapping par plateforme

- Android (Kotlin)
  - UI: Jetpack Compose
  - Persistance: Room/SQLDelight (entities: Project, Checklist, ChecklistItem)
  - Fichiers: SAF (Storage Access Framework) ; import/export en `text/markdown` et `text/csv`
  - Sélection fichiers: ACTION_OPEN_DOCUMENT / CREATE_DOCUMENT
- Desktop macOS (Swift)
  - AppKit/SwiftUI + CoreData/SwiftData équivalent
- Windows (C#/.NET)
  - UI: WPF/WinUI/MAUI
  - Persistance: EF Core (SQLite), classes POCO mappées
  - Fichiers: FilePicker/SavePicker, encodage UTF‑8
- Web
  - UI: React/Vue/Svelte
  - Persistance: IndexedDB/SQLite WASM si offline
  - Import/Export via Blob (text/markdown; text/csv)

### 8.3 Modèle de données (agnostique)

- Project { id: UUID, title: string, detail: string, createdAt: date, updatedAt: date }
- Checklist { id: UUID, projectId: UUID, title: string, color: string, createdAt: date, updatedAt: date, isDeleted: bool, position: int?, type: string }
- ChecklistItem { id: UUID, checklistId: UUID, text: string, note?: string, isChecked: bool, order: int }
- Contraintes: FK (on delete cascade), index: (projectId, position), (checklistId, order)

### 8.4 Services d’import/export (agnostiques)

- MarkdownService: `toMarkdown(project)`, `toMarkdownMany(projects)`; `fromMarkdown(string)` → [Project]
- CsvService: `toCsv(project)`, `toCsvMany(projects)`; `fromCsv(string)` → [Project]
- Invariants: id internes non exportés; titres servent de clé humaine

### 8.5 Migrations de données

- Ajout de `type` et `position`: valeurs par défaut si absentes
- Conversion de couleurs: énumération stable en chaîne
- Corbeille: transformer soft‑delete (booléen) en table/flag équivalent

## 9. Qualité, tests et outillage

- Unitaires: parse/serialize Markdown & CSV (happy path + champs manquants, couleurs/Type inconnus)
- Intégration: export→import (round‑trip) multi‑projets
- UI tests: création, recherche, tri, duplication, corbeille, export/import
- Outils recommandés:
  - iOS: XCTest, XCUITest
  - Kotlin/Android: JUnit, Espresso
  - .NET: xUnit/NUnit, Playwright pour desktop/web

## 10. Sécurité et confidentialité

- Données locales par défaut; pas de comptes ni de réseau
- Permissions: accès fichiers (import/export) seulement à la demande
- Aucune collecte de données analytics par défaut
- Politique de confidentialité:
  - Fichier inclus: `docs/privacy_policy.html`
  - Lien dans l'application (À propos)
  - Stockage local uniquement (SwiftData)

## 11. Performance

- Recherches en mémoire (modèle local) ; pour gros volumes: predicate/SQL côté persistance
- Export/Import en streaming pour fichiers volumineux (optionnel sur autres plateformes)

## 12. Accessibilité

- Labels et traits pour VoiceOver/TalkBack
- Contrastes des couleurs (pastilles) ; tailles dynamiques

## 13. Internationale/Localisation

- Chaînes en français actuellement; prévoir fichiers de ressources pour i18n

## 14. Packaging et distribution

- iOS: App Store / TestFlight
- macOS: App Store / Notarisation (Build natif arm64)
- Android: APK/AAB (Play Store) - *Prévu*
- Desktop Windows: MSIX - *Prévu*

## 15. Annexes

### 15.1 Exemple Markdown (multi‑projets)

```markdown
# Projet Alpha
> Detail: Description courte

## Prévol [type=checklist][color=yellow]
- [x] Batterie ::: 12.6V
- [ ] Essence

---

# Projet Bravo
## Tâches [type=todo][color=blue]
- [ ] Appeler tour
```csv

### 15.2 Exemple CSV (multi‑projets)

```
ProjectTitle,ChecklistTitle,Type,Color,ItemOrder,Checked,Text,Note
Alpha,Prévol,checklist,yellow,0,1,Batterie,12.6V
Alpha,Prévol,checklist,yellow,1,0,Essence,
Bravo,Tâches,todo,blue,0,0,Appeler tour,
```

---

## Export en PDF/DOCX

- PDF avec macOS: Ouvrir le fichier Markdown dans TextEdit → Fichier > Exporter en PDF
- DOCX/PDF multi‑plateforme: utiliser Pandoc

```bash
pandoc docs/SkyNotes-Technical-Spec-v2.0.md -o SkyNotes-Spec-v2.0.docx
pandoc docs/SkyNotes-Technical-Spec-v2.0.md -o SkyNotes-Spec-v2.0.pdf
```
