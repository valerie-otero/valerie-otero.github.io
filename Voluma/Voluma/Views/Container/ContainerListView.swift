//
//  ContainerListView.swift
//  Voluma
//
//  Bibliothèque des récipients : créer, modifier, supprimer.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContainerListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.locale) private var locale
    @Query(sort: \Container.createdAt) private var containers: [Container]
    @State private var path: [Container] = []
    @State private var showJSONImporter = false
    @State private var pendingPlan: LibraryImporter.Plan?
    @State private var importReport: LibraryImporter.Report?
    @State private var importError: String?
    @State private var lastAddedCount: Int?
    @AppStorage("volumeUnit") private var volumeUnit: VolumeUnit = .liter

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(containers) { container in
                    NavigationLink(value: container) {
                        row(container)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Récipients".localized(in: locale))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Récipients d'exemple", systemImage: "shippingbox") {
                        lastAddedCount = SampleData.addMissingContainers(modelContext)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Importer (JSON)", systemImage: "square.and.arrow.down") {
                        showJSONImporter = true
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Ajouter", systemImage: "plus", action: add)
                }
            }
            .navigationDestination(for: Container.self) { container in
                ContainerEditor(container: container)
            }
            .overlay {
                if containers.isEmpty {
                    ContentUnavailableView("Aucun récipient",
                                           systemImage: "cylinder.split.1x2",
                                           description: Text("Touchez + pour créer un récipient, chargez les récipients d'exemple ou importez une bibliothèque JSON."))
                }
            }
            .fileImporter(isPresented: $showJSONImporter, allowedContentTypes: [.json]) { result in
                handleJSONImport(result)
            }
            .alert("Récipients d'exemple",
                   isPresented: Binding(get: { lastAddedCount != nil }, set: { if !$0 { lastAddedCount = nil } })) {
                Button("OK", role: .cancel) { lastAddedCount = nil }
            } message: {
                if let n = lastAddedCount, n > 0 {
                    Text("Récipients d'exemple ajoutés : \(n).")
                } else {
                    Text("Tous les récipients d'exemple sont déjà présents.")
                }
            }
            .confirmationDialog(
                "Noms déjà présents",
                isPresented: Binding(get: { pendingPlan != nil }, set: { if !$0 { pendingPlan = nil } }),
                titleVisibility: .visible
            ) {
                Button("Remplacer les existants") { applyImport(.replace) }
                Button("Garder les deux (importer en copie)") { applyImport(.keepBoth) }
                Button("Ignorer les doublons") { applyImport(.skip) }
                Button("Annuler", role: .cancel) { pendingPlan = nil }
            } message: {
                if let p = pendingPlan {
                    Text("\(p.conflictCount) élément(s) du fichier portent un nom déjà présent dans votre bibliothèque. Que faire ?")
                }
            }
            .alert("Import JSON",
                   isPresented: Binding(get: { importReport != nil || importError != nil },
                                        set: { if !$0 { importReport = nil; importError = nil } })) {
                Button("OK", role: .cancel) { importReport = nil; importError = nil }
            } message: {
                if let r = importReport {
                    Text("Importé : \(r.added) ajouté(s), \(r.updated) mis à jour, \(r.skipped) ignoré(s).")
                } else if let e = importError {
                    Text("Fichier illisible : \(e)")
                }
            }
        }
    }

    private func handleJSONImport(_ result: Result<URL, Error>) {
        switch result {
        case .failure(let error):
            importError = error.localizedDescription
        case .success(let url):
            do {
                let plan = try LibraryImporter.plan(from: url, into: modelContext)
                if plan.hasConflicts {
                    pendingPlan = plan          // demande la résolution avant d'écrire quoi que ce soit
                } else {
                    importReport = try LibraryImporter.apply(plan.dto, resolution: .replace, into: modelContext)
                }
            } catch {
                importError = error.localizedDescription
            }
        }
    }

    private func applyImport(_ resolution: LibraryImporter.Resolution) {
        guard let plan = pendingPlan else { return }
        pendingPlan = nil
        do {
            importReport = try LibraryImporter.apply(plan.dto, resolution: resolution, into: modelContext)
        } catch {
            importError = error.localizedDescription
        }
    }

    private func row(_ container: Container) -> some View {
        let full = GaugeEngine.fullVolume(shape: container.shape, dims: container.dims,
                                          points: container.gaugePoints, k: container.k)
        return HStack(spacing: 12) {
            Image(systemName: container.shape.symbol)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(container.name.isEmpty ? "Sans nom" : container.name)
                    .font(.body)
                HStack(spacing: 6) {
                    Text(container.compositeKindValue?.title ?? container.shape.title)
                    Text("·")
                    Text(volumeUnit.string(full, locale: locale))
                    if container.k != 1 {
                        Text("· calibré").foregroundStyle(.orange)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    private func add() {
        let container = Container(name: "")
        modelContext.insert(container)
        path.append(container)
    }

    private func delete(_ offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(containers[index])
        }
    }
}

#Preview {
    ContainerListView()
        .modelContainer(for: [Container.self, Liquid.self, PlanDocument.self, GaugePointModel.self],
                        inMemory: true)
}
