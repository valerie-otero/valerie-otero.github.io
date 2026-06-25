//
//  LibraryImporterTests.swift
//  VolumaTests
//
//  Import JSON (format prototype) : décodage, mapping des dimensions, points
//  de jauge (clés h_mm/v_L ou h/v), et fusion par nom.
//

import Testing
import SwiftData
import Foundation
@testable import Voluma

@MainActor
struct LibraryImporterTests {

    private func makeContext() throws -> ModelContext {
        let schema = Schema([Container.self, Liquid.self, PlanDocument.self, GaugePointModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        return ModelContext(try ModelContainer(for: schema, configurations: [config]))
    }

    private func tempJSON(_ string: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("lib-\(UUID().uuidString).json")
        try Data(string.utf8).write(to: url)
        return url
    }

    private let sample = """
    {
      "containers": [
        { "name": "Cuve atelier", "type": "hcyl", "dims": { "D": 712, "L": 879 }, "k": 1, "points": [] },
        { "name": "Forme libre", "type": "custom",
          "points": [ {"h_mm": 100, "v_L": 10}, {"h": 200, "v": 30} ] }
      ],
      "liquids": [ { "name": "SP98", "rho": 0.750, "visc": 0.6, "note": "15 °C" } ]
    }
    """

    @Test("Import : récipients et liquides créés avec les bonnes valeurs")
    func importsContainersAndLiquids() throws {
        let ctx = try makeContext()
        let counts = try LibraryImporter.importJSON(from: tempJSON(sample), into: ctx)
        #expect(counts.containers == 2)
        #expect(counts.liquids == 1)

        let cuve = try ctx.fetch(FetchDescriptor<Container>(
            predicate: #Predicate { $0.name == "Cuve atelier" })).first
        #expect(cuve?.shape == .hcyl)
        #expect(cuve?.dD == 712)
        #expect(cuve?.dLen == 879)
        let v = GaugeEngine.fullVolume(shape: cuve!.shape, dims: cuve!.dims,
                                       points: cuve!.gaugePoints, k: cuve!.k)
        #expect(abs(v - 350.0) < 0.2)

        let liquid = try ctx.fetch(FetchDescriptor<Liquid>()).first
        #expect(liquid?.density == 0.750)
        #expect(liquid?.viscosity == 0.6)
        #expect(liquid?.note == "15 °C")
    }

    @Test("Import : points de jauge (clés h_mm/v_L et h/v) interpolés")
    func importsGaugePoints() throws {
        let ctx = try makeContext()
        _ = try LibraryImporter.importJSON(from: tempJSON(sample), into: ctx)

        let libre = try ctx.fetch(FetchDescriptor<Container>(
            predicate: #Predicate { $0.name == "Forme libre" })).first
        #expect(libre?.shape == .custom)
        #expect(libre?.points?.count == 2)
        #expect(libre?.gaugePoints.map(\.h_mm) == [100, 200])
        let v = GaugeEngine.volume(shape: .custom, dims: [:],
                                   points: libre!.gaugePoints, k: 1, h: 150)
        #expect(abs(v - 20) < 1e-9)
    }

    @Test("Fusion par nom : ré-import met à jour sans dupliquer")
    func mergesByName() throws {
        let ctx = try makeContext()
        _ = try LibraryImporter.importJSON(from: tempJSON(sample), into: ctx)

        let updated = """
        { "containers": [
            { "name": "Cuve atelier", "type": "hcyl", "dims": { "D": 712, "L": 879 }, "k": 1.05, "points": [] }
        ] }
        """
        _ = try LibraryImporter.importJSON(from: tempJSON(updated), into: ctx)

        // Toujours 2 récipients (pas de doublon)
        #expect(try ctx.fetchCount(FetchDescriptor<Container>()) == 2)
        let cuve = try ctx.fetch(FetchDescriptor<Container>(
            predicate: #Predicate { $0.name == "Cuve atelier" })).first
        #expect(cuve?.k == 1.05)   // mis à jour
    }

    @Test("Import vide / sections absentes : aucun plantage")
    func handlesEmptySections() throws {
        let ctx = try makeContext()
        let counts = try LibraryImporter.importJSON(from: tempJSON("{}"), into: ctx)
        #expect(counts.containers == 0)
        #expect(counts.liquids == 0)
    }

    @Test("Export puis ré-import : aller-retour fidèle")
    func exportRoundTrip() throws {
        let ctx = try makeContext()
        let cuve = Container(name: "Cuve")
        cuve.shape = .hcyl; cuve.dD = 712; cuve.dLen = 879; cuve.k = 1.05
        ctx.insert(cuve)
        let libre = Container(name: "Libre")
        libre.shape = .custom
        let p1 = GaugePointModel(h_mm: 100, v_L: 10)
        let p2 = GaugePointModel(h_mm: 200, v_L: 30)
        ctx.insert(p1); ctx.insert(p2)
        libre.points = [p1, p2]
        ctx.insert(libre)
        ctx.insert(Liquid(name: "SP98", density: 0.75, viscosity: 0.6, note: "15 °C"))
        try ctx.save()

        let data = try LibraryImporter.exportJSON(
            containers: try ctx.fetch(FetchDescriptor<Container>()),
            liquids: try ctx.fetch(FetchDescriptor<Liquid>()))

        // Ré-import dans un contexte neuf
        let ctx2 = try makeContext()
        let url = try tempJSON(String(decoding: data, as: UTF8.self))
        let counts = try LibraryImporter.importJSON(from: url, into: ctx2)
        #expect(counts.containers == 2)
        #expect(counts.liquids == 1)

        let cuve2 = try ctx2.fetch(FetchDescriptor<Container>(
            predicate: #Predicate { $0.name == "Cuve" })).first
        #expect(cuve2?.shape == .hcyl)
        #expect(cuve2?.dD == 712)
        #expect(cuve2?.dLen == 879)
        #expect(cuve2?.k == 1.05)

        let libre2 = try ctx2.fetch(FetchDescriptor<Container>(
            predicate: #Predicate { $0.name == "Libre" })).first
        #expect(libre2?.shape == .custom)
        #expect(libre2?.gaugePoints.map(\.h_mm) == [100, 200])
        #expect(libre2?.gaugePoints.map(\.v_L) == [10, 30])
    }

    @Test("Aller-retour : forme composée (puisard) + pas de jauge conservés")
    func compositeAndStepRoundTrip() throws {
        let ctx = try makeContext()
        let cuve = Container(name: "Puisard")
        cuve.shape = .custom
        cuve.compositeKind = CompositeKind.sumpBox.rawValue
        cuve.dL = 1200; cuve.dW = 800; cuve.dH = 500
        cuve.sumpL = 300; cuve.sumpW = 300; cuve.sumpH = 150
        cuve.gaugeStepL = 25
        ctx.insert(cuve)
        try ctx.save()

        let data = try LibraryImporter.exportJSON(
            containers: try ctx.fetch(FetchDescriptor<Container>()), liquids: [])
        let ctx2 = try makeContext()
        _ = try LibraryImporter.importJSON(
            from: tempJSON(String(decoding: data, as: UTF8.self)), into: ctx2)

        let c2 = try ctx2.fetch(FetchDescriptor<Container>()).first
        #expect(c2?.compositeKind == CompositeKind.sumpBox.rawValue)
        #expect(c2?.dL == 1200 && c2?.dH == 500)
        #expect(c2?.sumpH == 150)
        #expect(c2?.gaugeStepL == 25)
        #expect((c2?.points ?? []).isEmpty)   // points composés régénérés, pas stockés
        // Volume identique de part et d'autre (493,5 L).
        let v = GaugeEngine.fullVolume(shape: c2!.shape, dims: c2!.dims, points: c2!.gaugePoints, k: c2!.k)
        #expect(abs(v - 493.5) < 1e-6)
    }

    @Test("Import non destructif : aperçu détecte les conflits, résolutions skip/keepBoth/replace")
    func conflictResolution() throws {
        let ctx = try makeContext()
        let cuve = Container(name: "Cuve"); cuve.shape = .hcyl; cuve.dD = 712; cuve.dLen = 879; cuve.k = 1
        ctx.insert(cuve); try ctx.save()

        let json = """
        { "containers": [ {"name":"Cuve","type":"hcyl","dims":{"D":712,"L":879},"k":1.05,"points":[]} ] }
        """
        // Aperçu : conflit détecté, rien n'est encore écrit.
        let plan = try LibraryImporter.plan(from: tempJSON(json), into: ctx)
        #expect(plan.hasConflicts)
        #expect(plan.conflictContainers == ["Cuve"])
        #expect(try ctx.fetchCount(FetchDescriptor<Container>()) == 1)

        // Ignorer : rien ne change.
        let rSkip = try LibraryImporter.apply(plan.dto, resolution: .skip, into: ctx)
        #expect(rSkip.skipped == 1)
        #expect(try ctx.fetchCount(FetchDescriptor<Container>()) == 1)
        #expect(cuve.k == 1)

        // Garder les deux : une copie renommée est créée.
        let rKeep = try LibraryImporter.apply(plan.dto, resolution: .keepBoth, into: ctx)
        #expect(rKeep.added == 1)
        #expect(try ctx.fetchCount(FetchDescriptor<Container>()) == 2)
        #expect(cuve.k == 1)   // l'original reste intact

        // Remplacer : l'existant d'origine est mis à jour.
        let rReplace = try LibraryImporter.apply(plan.dto, resolution: .replace, into: ctx)
        #expect(rReplace.updated >= 1)
        #expect(cuve.k == 1.05)
    }

    @Test("Import : valeurs aberrantes filtrées (points NaN/hors borne, densité absurde, k borné)")
    func validatesMaliciousInput() throws {
        let ctx = try makeContext()
        let bad = """
        { "containers": [
            { "name": "Mauvais", "type": "custom", "k": 99,
              "points": [ {"h_mm": 100, "v_L": 10}, {"h_mm": 1e308, "v_L": 5}, {"h_mm": -3, "v_L": 9} ] }
          ],
          "liquids": [ { "name": "Faux", "rho": -1, "visc": -5 } ]
        }
        """
        _ = try LibraryImporter.importJSON(from: tempJSON(bad), into: ctx)

        let c = try ctx.fetch(FetchDescriptor<Container>()).first
        #expect(c?.points?.count == 1)        // seul (100,10) survit
        #expect(c?.k == 2)                    // k=99 borné à 2
        let l = try ctx.fetch(FetchDescriptor<Liquid>()).first
        #expect(l?.density != -1)             // densité absurde rejetée (garde le défaut)
        #expect((l?.density ?? 0) >= 0)
    }
}
