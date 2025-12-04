# SkyNotes — Notes projet & checklists / Project Notes & Checklists

Version: 1.1 (iOS & macOS)  
Auteur/Author: Valérie Otero  
Date: 27/11/2025

[Français](#français) | [English](#english)

---

<a name="français"></a>

## Français

SkyNotes est une application de création de checklists et de listes de tâches pour organiser vos projets. Elle est conçue pour être simple, rapide et fiable en vol comme au sol.

Ce document sert de **présentation fonctionnelle** pour les utilisateurs, avec en fin de page une **annexe technique** utile aux développeurs.

### 1. Principales fonctionnalités

- **Projets**: créez un projet par sujet (brief, mission, préparation vol, formation…).
- **Checklists colorées**: attachez plusieurs checklists à un projet, avec une couleur par liste (post‑it).
- **Modèles (Templates)**: créez des modèles réutilisables pour vos checklists fréquentes.
- **Items réordonnables**: déplacez les items par glisser‑déposer pour adapter l’ordre à votre usage.
- **Deux types de listes**:
  - **Checklist**: pour vérifier un ensemble d’actions à cocher (prévol, briefing…).
  - **To‑Do**: pour suivre des tâches à réaliser dans le temps (suivi dossier, TODO généraux).
- **Recherche rapide**: retrouvez un projet, une checklist ou un item en tapant quelques lettres.
- **Tri local**: triez les projets et listes par titre, date ou nombre d’items.
- **Duplication**: dupliquez un projet ou une checklist pour créer rapidement un nouveau modèle.
- **Corbeille**: récupérez un élément supprimé par erreur ou videz la corbeille définitivement.
- **Import / Export**: en Markdown (.md) ou CSV (.csv), pour archiver ou partager vos listes.
- **Contenu de démarrage**: un projet de découverte et un tutoriel interactif sont inclus à l'installation.
- **Soutien au développement**: une "Tip Jar" (Boîte à pourboires) pour soutenir le développeur.
- **Écran À propos**: version de l’app, FAQ, crédits et lien vers la politique de confidentialité.

### 2. Utiliser SkyNotes au quotidien

#### 2.1 Créer et organiser vos projets

- Ouvrez l’onglet `Projets`.
- Touchez le bouton `+` pour créer un **nouveau projet** (titre + description optionnelle).
- Les projets sont affichés dans une liste que vous pouvez **rechercher** et **trier**.
- Depuis un projet, vous pouvez:
  - le **renommer**,
  - le **dupliquer** comme modèle pour une nouvelle situation,
  - l’**exporter** (Markdown/CSV),
  - le **supprimer** (il ira dans la Corbeille).

#### 2.2 Créer et personnaliser vos checklists

- Dans un projet, utilisez `+` pour créer une **nouvelle checklist**.
- Choisissez:
  - un **titre** (ex: « Prévol DR400 », « Briefing élève »),
  - un **type**: `Checklist` ou `To‑Do`,
  - une **couleur** (via la palette de couleurs `PostItColor`).
- Ajoutez ensuite vos **items** un par un.
- Vous pouvez:
  - **réordonner** les items en les faisant glisser,
  - marquer un item comme **coché** / **non coché**,
  - ajouter une **note** détaillée (ex: valeurs, mémos, rappels).

#### 2.3 Modèles (Templates)

- Créez des checklists marquées comme **Modèles** pour les réutiliser souvent.
- Idéal pour les procédures standardisées (Checklist avion, Liste de voyage, etc.).
- Les modèles apparaissent distinctement et peuvent être instanciés dans n'importe quel projet.

#### 2.4 Vue globale des checklists

- L’onglet `Accueil` affiche une **grille globale** de toutes les checklists.
- Vous pouvez:
  - **rechercher** dans toutes les listes,
  - **trier** par différents critères,
  - **filtrer** par type (Checklist ou To‑Do).

#### 2.5 Corbeille et restauration

- L’onglet `Corbeille` liste les éléments marqués comme supprimés.
- Depuis cette vue, pour chaque élément vous pouvez:
  - le **restaurer** dans son projet d’origine,
  - le **supprimer définitivement**.

#### 2.6 Import / Export

Les échanges se font via l’application Fichiers (iOS) ou Finder (macOS).

- **Exporter**:
  - depuis un **projet**: export en Markdown ou CSV d’un seul projet,
  - depuis la vue **Projets**: export de **plusieurs projets** en un seul fichier.
- **Importer**:
  - sélectionnez un fichier `.md` ou `.csv`,
  - SkyNotes recrée les projets, checklists et items à partir du contenu.

Les formats sont **ouverts** (Markdown/CSV) afin que vous puissiez:

- les relire facilement dans n’importe quel éditeur de texte ou tableur,
- les archiver ou les partager avec d’autres outils.

### 3. Spécificités iOS & macOS

- **Interface SwiftUI adaptative**: l’app s’adapte à l’écran de l’iPhone, de l’iPad et du Mac.
- **macOS**:
  - boutons sans ombre ni contour système superflus,
  - fonds blancs pour les vues principales pour un rendu plus « document »,
  - intégration aux fenêtres et menus natifs.
- **iOS / iPadOS**:
  - navigation par piles (`NavigationStack`),
  - gestion des documents via l’app Fichiers.

### 4. Confidentialité et données

- Toutes les données sont **stockées localement** sur votre appareil via SwiftData.
- SkyNotes **ne crée aucun compte** et **n’envoie pas vos données sur un serveur**.
- L’accès aux fichiers pour import/export se fait **uniquement à la demande** (sandbox Apple).
- Aucune mesure d’audience ni collecte de statistiques par défaut.
- La politique de confidentialité détaillée est disponible dans `docs/SkyNotes/privacy_policy.html` et via l’écran `À propos` dans l’app.

### 5. Foire aux questions (FAQ)

**Q. Puis‑je réutiliser mes checklists dans un autre projet ?**  
Oui. Dupliquez soit la **checklist** directement, soit le **projet** complet et adaptez‑le.

**Q. Comment sauvegarder mes données ?**  
Vous pouvez régulièrement **exporter** vos projets (Markdown ou CSV) et les stocker dans iCloud Drive, un NAS, etc.

**Q. Que se passe‑t‑il si je supprime un élément par erreur ?**  
Consultez l’onglet `Corbeille` pour le **restaurer** tant qu’il n’a pas été supprimé définitivement.

**Q. Puis‑je éditer mes fichiers exportés ailleurs ?**  
Oui, ils sont au format Markdown/CSV lisible par la plupart des éditeurs de texte et tableurs.

---

<a name="english"></a>

## English

SkyNotes is a checklist and to-do list creation application for organizing your projects. It is designed to be simple, fast, and reliable, both in flight and on the ground.

This document serves as a **functional presentation** for users, with a **technical appendix** for developers at the end.

### 1. Key Features

- **Projects**: Create one project per subject (briefing, mission, flight prep, training...).
- **Colored Checklists**: Attach multiple checklists to a project, with one color per list (post-it style).
- **Templates**: Create reusable templates for your frequent checklists.
- **Reorderable Items**: Move items via drag-and-drop to adapt the order to your usage.
- **Two List Types**:
  - **Checklist**: To verify a set of actions to check off (pre-flight, briefing...).
  - **To-Do**: To track tasks to be done over time (file follow-up, general TODOs).
- **Quick Search**: Find a project, checklist, or item by typing a few letters.
- **Local Sort**: Sort projects and lists by title, date, or item count.
- **Duplication**: Duplicate a project or checklist to quickly create a new template.
- **Trash**: Recover an item deleted by mistake or empty the trash permanently.
- **Import / Export**: In Markdown (.md) or CSV (.csv), to archive or share your lists.
- **Starter Content**: A discovery project and interactive tutorial are included upon installation.
- **Development Support**: A "Tip Jar" to support the developer.
- **About Screen**: App version, FAQ, credits, and link to privacy policy.

### 2. Using SkyNotes Daily

#### 2.1 Creating and Organizing Your Projects

- Open the `Projects` tab.
- Tap the `+` button to create a **new project** (title + optional description).
- Projects are displayed in a list that you can **search** and **sort**.
- From a project, you can:
  - **Rename** it,
  - **Duplicate** it as a template for a new situation,
  - **Export** it (Markdown/CSV),
  - **Delete** it (it will go to the Trash).

#### 2.2 Creating and Customizing Your Checklists

- Inside a project, use `+` to create a **new checklist**.
- Choose:
  - A **title** (e.g., "DR400 Pre-flight", "Student Briefing"),
  - A **type**: `Checklist` or `To-Do`,
  - A **color** (via the `PostItColor` palette).
- Then add your **items** one by one.
- You can:
  - **Reorder** items by dragging them,
  - Mark an item as **checked** / **unchecked**,
  - Add a detailed **note** (e.g., values, memos, reminders).

#### 2.3 Templates

- Create checklists marked as **Templates** to reuse them often.
- Ideal for standardized procedures (Aircraft Checklist, Travel List, etc.).
- Templates appear distinctly and can be instantiated in any project.

#### 2.4 Global Checklist View

- The `Home` tab displays a **global grid** of all checklists.
- You can:
  - **Search** across all lists,
  - **Sort** by different criteria,
  - **Filter** by type (Checklist or To-Do).

#### 2.5 Trash and Restoration

- The `Trash` tab lists items marked as deleted.
- From this view, for each item you can:
  - **Restore** it to its original project,
  - **Delete** it permanently.

#### 2.6 Import / Export

Exchanges are done via the Files app (iOS) or Finder (macOS).

- **Export**:
  - From a **project**: Export a single project in Markdown or CSV.
  - From the **Projects** view: Export **multiple projects** into a single file.
- **Import**:
  - Select a `.md` or `.csv` file.
  - SkyNotes recreates the projects, checklists, and items from the content.

The formats are **open** (Markdown/CSV) so that you can:

- Read them easily in any text editor or spreadsheet software.
- Archive or share them with other tools.

### 3. iOS & macOS Specifics

- **Adaptive SwiftUI Interface**: The app adapts to iPhone, iPad, and Mac screens.
- **macOS**:
  - Buttons without superfluous system shadows or outlines.
  - White backgrounds for main views for a more "document" look.
  - Integration with native windows and menus.
- **iOS / iPadOS**:
  - Stack navigation (`NavigationStack`).
  - Document management via the Files app.

### 4. Privacy and Data

- All data is **stored locally** on your device via SwiftData.
- SkyNotes **creates no account** and **sends no data to a server**.
- File access for import/export is done **only on demand** (Apple sandbox).
- No audience measurement or statistics collection by default.
- The detailed privacy policy is available in `docs/SkyNotes/privacy_policy.html` and via the `About` screen in the app.

### 5. Frequently Asked Questions (FAQ)

**Q. Can I reuse my checklists in another project?**  
Yes. Duplicate either the **checklist** directly, or the entire **project** and adapt it.

**Q. How do I back up my data?**  
You can regularly **export** your projects (Markdown or CSV) and store them in iCloud Drive, a NAS, etc.

**Q. What happens if I delete an item by mistake?**  
Check the `Trash` tab to **restore** it as long as it hasn't been permanently deleted.

**Q. Can I edit my exported files elsewhere?**  
Yes, they are in Markdown/CSV format, readable by most text editors and spreadsheet software.

---

## 6. Annexe technique / Technical Appendix

### 6.1 Architecture and Technologies

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

#### Architecture (iOS & macOS)

- UI: SwiftUI (adaptatif iOS/macOS)
- Persistance: SwiftData (`@Model`, `@Query`, `ModelContext`)
- Navigation: `NavigationStack` + navigation par `UUID` (refetch sécurisé)
- Fichiers: `FileDocument` / `UTType`; sandbox avec accès *security‑scoped*.
- Design system: couleurs via enum `PostItColor`, icônes SF Symbols.
- macOS spécifique:
  - suppression des ombres et contours système sur les boutons,
  - fonds blancs pour les vues principales,
  - gestion des fenêtres et menus natifs.

### 6.2 Modèle de données (conceptuel et iOS)

#### Entités

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

#### Règles et contraintes

- Cascade delete: suppression d’un Project supprime ses Checklists
- position: compacte et réindexée lors des réordonnancements
- typeRaw: expose `type: ChecklistType` (checklist|todo)
- Sécurité: pas de navigation avec références invalides (refetch par id)

### 6.3 Formats d’échange

#### Markdown (.md)

- Projet (single):
  - Titre: `# <Project Title>`
  - Détail (optionnel): `> Detail: <one-line>`
  - Checklist: `## <Checklist Title> [type=<checklist|todo>][color=<postitcolor>]`
  - Item: `- [x] Text ::: Note` (or `[ ]`)
- Multi-projets:
  - Concaténation de blocs single séparés par `---` (lignes seules)
  - À l’import: split par `---` ou par titres `#` multiples

#### CSV (.csv)

- Projet (single):
  - En‑tête: `ChecklistTitle,Type,Color,ItemOrder,Checked,Text,Note`
- Multi-projets:
  - En‑tête: `ProjectTitle,ChecklistTitle,Type,Color,ItemOrder,Checked,Text,Note`
  - Groupement à l’import par `ProjectTitle` puis `ChecklistTitle`

#### Règles communes

- Échappement CSV: guillemets doublés, champs entre quotes si nécessaire
- Markdown: `:::` dans les notes est échappé en `::‧` à l’export
- Import diacritique‑robuste pour `type` et `color` (fallback par défaut)
- Titre projet unique: suffixe `(n)` en cas de collision

### 6.4 Flux UI (référence iOS)

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

### 6.5 Recherche et tri

- Recherche par tokens (split espaces), pliage diacritique + case‑insensitive
- AND logique: tous les tokens doivent correspondre dans (titres, items, notes, titre projet)
- Tri: titre (A→Z/Z→A), dates (créé/MAJ), position, nombre d’items

### 6.6 Portage multi‑plateformes (résumé)

#### Couches à isoler

- Domaine (entités, services import/export, règles métier)
- Persistance (ORM/DB) : adapter selon plateforme
- UI (composants, navigation)

#### Mapping par plateforme

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

#### Modèle de données (agnostique)

- Project { id: UUID, title: string, detail: string, createdAt: date, updatedAt: date }
- Checklist { id: UUID, projectId: UUID, title: string, color: string, createdAt: date, updatedAt: date, isDeleted: bool, position: int?, type: string }
- ChecklistItem { id: UUID, checklistId: UUID, text: string, note?: string, isChecked: bool, order: int }
- Contraintes: FK (on delete cascade), index: (projectId, position), (checklistId, order)

#### Services d’import/export (agnostiques)

- MarkdownService: `toMarkdown(project)`, `toMarkdownMany(projects)`; `fromMarkdown(string)` → [Project]
- CsvService: `toCsv(project)`, `toCsvMany(projects)`; `fromCsv(string)` → [Project]
- Invariants: id internes non exportés; titres servent de clé humaine

#### Migrations de données

- Ajout de `type` et `position`: valeurs par défaut si absentes
- Conversion de couleurs: énumération stable en chaîne
- Corbeille: transformer soft‑delete (booléen) en table/flag équivalent

### 6.7 Qualité, tests et outillage

- Unitaires: parse/serialize Markdown & CSV (happy path + champs manquants, couleurs/Type inconnus)
- Intégration: export→import (round‑trip) multi‑projets
- UI tests: création, recherche, tri, duplication, corbeille, export/import
- Outils recommandés:
  - iOS: XCTest, XCUITest
  - Kotlin/Android: JUnit, Espresso
  - .NET: xUnit/NUnit, Playwright pour desktop/web

### 6.8 Performance

- Recherches en mémoire (modèle local) ; pour gros volumes: predicate/SQL côté persistance
- Export/Import en streaming pour fichiers volumineux (optionnel sur autres plateformes)

### 6.9 Accessibilité

- Labels et traits pour VoiceOver/TalkBack
- Contrastes des couleurs (pastilles) ; tailles dynamiques

### 6.10 Internationale/Localisation

- Chaînes en français actuellement; prévoir fichiers de ressources pour i18n

### 6.11 Packaging et distribution

- iOS: App Store / TestFlight
- macOS: App Store / Notarisation (Build natif arm64)
- Android: APK/AAB (Play Store) - *Prévu*
- Desktop Windows: MSIX - *Prévu*

### 6.12 Exemples de formats

#### Exemple Markdown (multi‑projets)

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
```

#### Exemple CSV (multi‑projets)

```csv
ProjectTitle,ChecklistTitle,Type,Color,ItemOrder,Checked,Text,Note
Alpha,Prévol,checklist,yellow,0,1,Batterie,12.6V
Alpha,Prévol,checklist,yellow,1,0,Essence,
Bravo,Tâches,todo,blue,0,0,Appeler tour,
```

---

## 7. Export en PDF/DOCX (optionnel)

- PDF avec macOS: Ouvrir le fichier Markdown dans TextEdit → Fichier > Exporter en PDF
- DOCX/PDF multi‑plateforme: utiliser Pandoc

```bash
pandoc README.md -o SkyNotes-Spec-v1.0.docx
pandoc README.md -o SkyNotes-Spec-v1.0.pdf
```
