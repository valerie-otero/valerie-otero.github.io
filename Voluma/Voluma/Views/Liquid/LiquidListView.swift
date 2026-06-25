//
//  LiquidListView.swift
//  Voluma
//
//  Bibliothèque des liquides : créer, modifier, supprimer.
//

import SwiftUI
import SwiftData

struct LiquidListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.locale) private var locale
    @Query(sort: \Liquid.createdAt) private var liquids: [Liquid]
    @State private var path: [Liquid] = []
    @State private var lastAddedCount: Int?

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(liquids) { liquid in
                    NavigationLink(value: liquid) {
                        row(liquid)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Liquides".localized(in: locale))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Liquides d'exemple", systemImage: "tray.and.arrow.down") {
                        lastAddedCount = SampleData.addMissingLiquids(modelContext)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Ajouter", systemImage: "plus", action: add)
                }
            }
            .navigationDestination(for: Liquid.self) { liquid in
                LiquidEditor(liquid: liquid)
            }
            .overlay {
                if liquids.isEmpty {
                    ContentUnavailableView("Aucun liquide",
                                           systemImage: "drop",
                                           description: Text("Touchez + pour ajouter un liquide, ou chargez les liquides d'exemple."))
                }
            }
            .alert("Liquides d'exemple",
                   isPresented: Binding(get: { lastAddedCount != nil }, set: { if !$0 { lastAddedCount = nil } })) {
                Button("OK", role: .cancel) { lastAddedCount = nil }
            } message: {
                if let n = lastAddedCount, n > 0 {
                    Text("Liquides d'exemple ajoutés : \(n).")
                } else {
                    Text("Tous les liquides d'exemple sont déjà présents.")
                }
            }
        }
    }

    private func row(_ liquid: Liquid) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "drop.fill")
                .font(.title3)
                .foregroundStyle(liquid.displayColor)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(liquid.name.isEmpty ? "Sans nom" : liquid.name)
                Text(liquid.density.formatted(.number.precision(.fractionLength(3)).locale(locale)) + " kg/L")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func add() {
        let liquid = Liquid(name: "")
        modelContext.insert(liquid)
        path.append(liquid)
    }

    private func delete(_ offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(liquids[index])
        }
    }
}

#Preview {
    LiquidListView()
        .modelContainer(for: [Container.self, Liquid.self, PlanDocument.self, GaugePointModel.self],
                        inMemory: true)
}
