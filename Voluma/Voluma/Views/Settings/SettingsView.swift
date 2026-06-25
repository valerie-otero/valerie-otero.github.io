//
//  SettingsView.swift
//  Voluma
//
//  Réglages : langue, unités d'affichage, défauts au lancement,
//  synchronisation iCloud + export JSON, mentions et liens.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguage: AppLanguage = .deviceDefault
    @AppStorage("heightUnitMM") private var heightInMM = false
    @AppStorage("volumeUnit") private var volumeUnit: VolumeUnit = .liter
    @AppStorage("massUnit") private var massUnit: MassUnit = .kilogram
    @AppStorage("defaultContainerName") private var defaultContainerName = ""
    @AppStorage("defaultLiquidName") private var defaultLiquidName = ""

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Container.createdAt) private var containers: [Container]
    @Query(sort: \Liquid.createdAt) private var liquids: [Liquid]

    @State private var exportDocument: JSONExportDocument?
    @State private var showExporter = false
    @State private var exportError: String?
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                languageSection
                displaySection
                defaultsSection
                dataSection
                aboutSection
            }
            .navigationTitle("Réglages".localized(in: appLanguage.resolvedLocale))
            .fileExporter(isPresented: $showExporter,
                          document: exportDocument,
                          contentType: .json,
                          defaultFilename: "voluma-bibliotheque") { result in
                if case .failure(let error) = result { exportError = error.localizedDescription }
            }
        }
    }

    private var languageSection: some View {
        Section {
            Picker("Langue", selection: $appLanguage) {
                ForEach(AppLanguage.allCases) { lang in
                    Text(lang.displayName).tag(lang)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Langue")
        } footer: {
            Text("Choix de la langue de l'application, indépendamment du réglage du système.")
        }
    }

    private var displaySection: some View {
        Section {
            Picker("Hauteur à la pige", selection: $heightInMM) {
                Text("Centimètres").tag(false)
                Text("Millimètres").tag(true)
            }
            Picker("Volume", selection: $volumeUnit) {
                ForEach(VolumeUnit.allCases) { Text($0.displayName).tag($0) }
            }
            Picker("Masse", selection: $massUnit) {
                ForEach(MassUnit.allCases) { Text($0.displayName).tag($0) }
            }
        } header: {
            Text("Affichage")
        } footer: {
            Text("Choix purement visuel : les calculs restent effectués en interne (litres, kilogrammes).")
        }
    }

    private var defaultsSection: some View {
        Section("Au lancement") {
            Picker("Récipient par défaut", selection: $defaultContainerName) {
                Text("Premier de la liste").tag("")
                ForEach(containers) { c in
                    Text(c.name.isEmpty ? "Sans nom" : c.name).tag(c.name)
                }
            }
            Picker("Liquide par défaut", selection: $defaultLiquidName) {
                Text("Premier de la liste").tag("")
                ForEach(liquids) { l in
                    Text(l.name.isEmpty ? "Sans nom" : l.name).tag(l.name)
                }
            }
        }
    }

    private var dataSection: some View {
        Section {
            Button("Tout exporter (JSON)", systemImage: "square.and.arrow.up", action: prepareExport)
            if let exportError {
                Label(exportError, systemImage: "exclamationmark.triangle")
                    .font(.footnote).foregroundStyle(.red)
            }
            Button("Réinitialiser l'app", systemImage: "arrow.counterclockwise", role: .destructive) {
                showResetConfirm = true
            }
            .confirmationDialog("Réinitialiser l'app ?", isPresented: $showResetConfirm, titleVisibility: .visible) {
                Button("Tout effacer et restaurer les exemples", role: .destructive) {
                    SampleData.reset(modelContext)
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Efface tous vos récipients et liquides (y compris sur vos appareils synchronisés iCloud) et restaure les exemples de départ.")
            }
        } header: {
            Text("Données")
        } footer: {
            Text("Vos récipients, liquides et plans sont stockés sur l'appareil et synchronisés via votre iCloud privé. L'export produit un fichier JSON ré-importable.")
        }
    }

    private var aboutSection: some View {
        Section {
            NavigationLink {
                FAQView()
            } label: {
                Label("Foire aux questions", systemImage: "questionmark.circle")
            }
            NavigationLink {
                PrivacyView()
            } label: {
                Label("Politique de confidentialité", systemImage: "lock.shield")
            }
            Link(destination: URL(string: "mailto:valerie.otero@free.fr")!) {
                Label("Nous contacter par e-mail", systemImage: "envelope")
            }
        } header: {
            Text("À propos")
        } footer: {
            Text("Voluma est un outil d'aide à la lecture, sans valeur réglementaire ni métrologique. La fiabilité du résultat dépend entièrement de la mesure : une hauteur mal relevée donne un volume faux. Mesurez avec soin et vérifiez vos relevés ; l'utilisateur est seul responsable de l'exactitude des mesures et des décisions qui en découlent.")
        }
    }

    private func prepareExport() {
        exportError = nil
        do {
            let data = try LibraryImporter.exportJSON(containers: containers, liquids: liquids)
            exportDocument = JSONExportDocument(data: data)
            showExporter = true
        } catch {
            exportError = error.localizedDescription
        }
    }
}

/// Document JSON pour `.fileExporter`. `nonisolated` (module MainActor par défaut).
nonisolated struct JSONExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var data: Data
    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Container.self, Liquid.self, PlanDocument.self, GaugePointModel.self],
                        inMemory: true)
}
