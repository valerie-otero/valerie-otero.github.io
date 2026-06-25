//
//  ModelsTests.swift
//  VolumaTests
//
//  Valide la construction du schéma SwiftData et le pont des modèles vers le moteur.
//  (Stockage en mémoire, CloudKit désactivé — incompatible avec les stores in-memory.)
//

import Testing
import SwiftData
import Foundation
@testable import Voluma

@MainActor
struct ModelsTests {

    private func makeContext() throws -> ModelContext {
        let schema = Schema([Container.self, Liquid.self, PlanDocument.self, GaugePointModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    @Test("Le schéma SwiftData se construit (modèles valides)")
    func schemaBuilds() throws {
        _ = try makeContext()
    }

    @Test("Schéma compatible CloudKit : se charge en miroir .automatic (synchro)")
    func cloudKitSchemaLoads() throws {
        // Charge le store réel en mode miroir CloudKit : valide que le modèle est
        // compatible (défauts partout, relations optionnelles + inverses, pas d'unicité).
        let schema = Schema([Container.self, Liquid.self, PlanDocument.self, GaugePointModel.self])
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("ck-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        // `.private(...)` force le miroir CloudKit → valide réellement la compatibilité
        // du schéma (toutes relations optionnelles, défauts, pas d'unicité). `.automatic`
        // retomberait en local dans le contexte de test (faux positif).
        let config = ModelConfiguration(schema: schema,
                                        url: dir.appendingPathComponent("store.sqlite"),
                                        cloudKitDatabase: .private("iCloud.Valerie-Otero.Voluma"))
        let container = try ModelContainer(for: schema, configurations: [config])
        #expect(container.schema.entities.count == 4)
    }

    @Test("Pont dims : cylindre horizontal → 350 L")
    func dimsBridgeHcyl() throws {
        let ctx = try makeContext()
        let c = Container(name: "Cuve atelier")
        c.shape = .hcyl
        c.dD = 712
        c.dLen = 879
        ctx.insert(c)
        #expect(c.shape == .hcyl)
        #expect(c.dims["D"] == 712)
        #expect(c.dims["L"] == 879)
        let v = GaugeEngine.fullVolume(shape: c.shape, dims: c.dims, points: c.gaugePoints, k: c.k)
        #expect(abs(v - 350.0) < 0.2)
    }

    @Test("Pont dims : boîte → 60 L")
    func dimsBridgeBox() throws {
        let ctx = try makeContext()
        let c = Container(name: "Bac")
        c.shape = .box
        c.dL = 500; c.dW = 400; c.dH = 300
        ctx.insert(c)
        let v = GaugeEngine.fullVolume(shape: c.shape, dims: c.dims, points: [], k: c.k)
        #expect(abs(v - 60.0) < 1e-6)
    }

    @Test("Points de jauge : relation + conversion triée vers le moteur")
    func gaugePointsRelationship() throws {
        let ctx = try makeContext()
        let c = Container(name: "Forme libre")
        c.shape = .custom
        c.points = [GaugePointModel(h_mm: 200, v_L: 30),
                    GaugePointModel(h_mm: 100, v_L: 10)]
        ctx.insert(c)
        try ctx.save()
        #expect(c.gaugePoints.map(\.h_mm) == [100, 200])   // tri par hauteur
        let v = GaugeEngine.volume(shape: .custom, dims: [:], points: c.gaugePoints, k: 1, h: 150)
        #expect(abs(v - 20) < 1e-9)
    }

    @Test("Plan attaché : relation inverse câblée")
    func planRelationship() throws {
        let ctx = try makeContext()
        let c = Container(name: "Cuve")
        c.plan = PlanDocument(fileName: "coupe.pdf", data: Data([0x25, 0x50]), utiIdentifier: "com.adobe.pdf")
        ctx.insert(c)
        try ctx.save()
        #expect(c.plan?.fileName == "coupe.pdf")
        #expect(c.plan?.container === c)
    }

    @Test("Dé-duplication : retire les doublons exacts, garde les distincts")
    func deduplicateRemovesExactDuplicates() throws {
        let ctx = try makeContext()
        for _ in 0..<3 {                 // 3 copies exactes
            let c = Container(name: "Cuve"); c.shape = .hcyl; c.dD = 712; c.dLen = 879
            ctx.insert(c)
        }
        let distinct = Container(name: "Cuve")   // même nom mais dimensions différentes
        distinct.shape = .hcyl; distinct.dD = 500; distinct.dLen = 800
        ctx.insert(distinct)
        ctx.insert(Liquid(name: "SP98", density: 0.75))
        ctx.insert(Liquid(name: "SP98", density: 0.75))   // doublon
        try ctx.save()

        let removed = SampleData.deduplicate(ctx)
        #expect(removed == 3)            // 2 cuves identiques + 1 SP98
        #expect(try ctx.fetchCount(FetchDescriptor<Container>()) == 2)   // 1 exacte + 1 distincte
        #expect(try ctx.fetchCount(FetchDescriptor<Liquid>()) == 1)
    }

    @Test("ModelGuard : sanitizeInPlace borne les valeurs aberrantes")
    func sanitizeClampsBadValues() {
        let c = Container()
        c.dL = .infinity; c.dH = -5; c.k = 99; c.gaugeStepL = -3
        c.sanitizeInPlace()
        #expect(c.dL == 0 && c.dH == 0)
        #expect(c.k == 2)
        #expect(c.gaugeStepL == 0)

        let l = Liquid()
        l.density = 0; l.viscosity = -1
        l.sanitizeInPlace()
        #expect(l.density == 0.75 && l.viscosity == 0)

        // Densité positive mais absurde (typo 50) : bornée à la plage plausible.
        let l2 = Liquid(); l2.density = 50
        l2.sanitizeInPlace()
        #expect(l2.density == 2.0)

        // Point de jauge trop haut (15 m) : borné à 10 m (cohérent avec l'import).
        let c2 = Container()
        let p = GaugePointModel(h_mm: 15_000, v_L: .infinity)
        c2.points = [p]
        c2.sanitizeInPlace()
        #expect(p.h_mm == ModelGuard.maxPointHeight_mm)
        #expect(p.v_L == 0)
    }

    @Test("Dé-duplication : NE fusionne PAS deux récipients qui ne diffèrent que par le calibrage")
    func deduplicateKeepsDifferentCalibration() throws {
        let ctx = try makeContext()
        // Même géométrie, calibrage différent : ne doivent PAS être fusionnés (sinon le
        // récipient calibré pourrait être supprimé au profit d'un doublon non calibré).
        let a = Container(name: "Cuve"); a.shape = .hcyl; a.dD = 712; a.dLen = 879; a.k = 1
        let b = Container(name: "Cuve"); b.shape = .hcyl; b.dD = 712; b.dLen = 879; b.k = 1.08
        ctx.insert(a); ctx.insert(b)
        // Idem pour le pas de jauge enregistré.
        let c = Container(name: "Cuve"); c.shape = .hcyl; c.dD = 712; c.dLen = 879; c.k = 1; c.gaugeStepL = 25
        ctx.insert(c)
        try ctx.save()

        let removed = SampleData.deduplicate(ctx)
        #expect(removed == 0)
        #expect(try ctx.fetchCount(FetchDescriptor<Container>()) == 3)
    }

    @Test("Réinitialisation : efface tout et restaure les exemples")
    func resetRestoresExamples() throws {
        let ctx = try makeContext()
        ctx.insert(Container(name: "Perso"))
        ctx.insert(Liquid(name: "Perso"))
        try ctx.save()

        SampleData.reset(ctx)

        let containers = try ctx.fetch(FetchDescriptor<Container>())
        #expect(containers.count == SampleData.containerSpecs.count)
        #expect(!containers.contains { $0.name == "Perso" })
        #expect(try ctx.fetchCount(FetchDescriptor<Liquid>()) == SampleData.liquidSpecs.count)
    }

    @Test("Récipients d'exemple : ajout des manquants sans doublon")
    func addMissingContainers() throws {
        let ctx = try makeContext()
        let cuve = Container(name: "Cuve atelier / Workshop tank"); ctx.insert(cuve)   // déjà présent
        let added = SampleData.addMissingContainers(ctx)
        #expect(added == SampleData.containerSpecs.count - 1)
        #expect(try ctx.fetchCount(FetchDescriptor<Container>()) == SampleData.containerSpecs.count)
        #expect(SampleData.addMissingContainers(ctx) == 0)   // idempotent
    }

    @Test("Liquides d'exemple : ajout des manquants sans doublon")
    func addMissingLiquids() throws {
        let ctx = try makeContext()
        ctx.insert(Liquid(name: "SP98"))   // déjà présent
        let added = SampleData.addMissingLiquids(ctx)
        #expect(added == SampleData.liquidSpecs.count - 1)
        #expect(try ctx.fetchCount(FetchDescriptor<Liquid>()) == SampleData.liquidSpecs.count)
        #expect(SampleData.addMissingLiquids(ctx) == 0)   // idempotent
    }

    @Test("Liquide : valeurs par défaut et masse")
    func liquidDefaultsAndMass() throws {
        let ctx = try makeContext()
        let l = Liquid(name: "SP98", density: 0.750, viscosity: 0.6, note: "15 °C")
        ctx.insert(l)
        #expect(l.density == 0.750)
        #expect(GaugeEngine.mass(volumeL: 100, density: l.density) == 75)

        let defaultLiquid = Liquid()
        #expect(defaultLiquid.density == 0.75)   // défaut
        #expect(defaultLiquid.viscosity == 0)
    }
}
