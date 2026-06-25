//
//  VolumaApp.swift
//  Voluma
//
//  Created by Valérie Otero on 16/06/2026.
//

import SwiftUI
import SwiftData

@main
struct VolumaApp: App {

    @AppStorage("appLanguage") private var appLanguage: AppLanguage = .deviceDefault

    /// Conteneur partagé SwiftData + CloudKit (synchro multi-appareils).
    /// Repli local automatique si CloudKit est indisponible
    /// (ex. simulateur sans compte iCloud, conteneur non encore provisionné).
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Container.self,
            Liquid.self,
            PlanDocument.self,
            GaugePointModel.self,
        ])

        let cloudConfig = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do {
            let container = try ModelContainer(for: schema, configurations: [cloudConfig])
            UserDefaults.standard.set(true, forKey: "cloudKitConfigured")
            UserDefaults.standard.removeObject(forKey: "cloudKitError")
            return container
        } catch {
            // Repli local : on conserve la raison pour le diagnostic.
            NSLog("[Voluma] CloudKit container init failed: \(error)")
            UserDefaults.standard.set(false, forKey: "cloudKitConfigured")
            UserDefaults.standard.set(String(describing: error), forKey: "cloudKitError")
        }

        let localConfig = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [localConfig])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, appLanguage.resolvedLocale)
        }
        .modelContainer(sharedModelContainer)
    }
}
