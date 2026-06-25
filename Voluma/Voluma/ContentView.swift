//
//  ContentView.swift
//  Voluma
//
//  Shell de navigation (provisoire) : Lecture / Récipients / Liquides.
//  Sera enrichi à l'étape de finition (NavigationSplitView iPad, table, réglages,
//  Liquid Glass). Amorce les données d'exemple au premier lancement.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            Tab("Lecture", systemImage: "gauge.with.dots.needle.bottom.50percent") {
                NavigationStack { ReadingView() }
            }
            Tab("Récipients", systemImage: "cylinder.split.1x2") {
                ContainerListView()
            }
            Tab("Liquides", systemImage: "drop.fill") {
                LiquidListView()
            }
            Tab("Réglages", systemImage: "gearshape") {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)   // barre d'onglets sur iPhone, barre latérale sur iPad
        .task {
            // Auto-seed seulement sans compte iCloud (sinon doublons via synchro) ;
            // avec iCloud, les exemples se chargent à la demande ou arrivent par synchro.
            SampleData.seedIfSafe(modelContext)
            // Auto-cicatrisation : retire les doublons EXACTS, une seule fois par lancement
            // (et non à chaque vue) pour ne pas courir avec l'import CloudKit.
            SampleData.deduplicateOncePerLaunch(modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Container.self, Liquid.self, PlanDocument.self, GaugePointModel.self],
                        inMemory: true)
}
