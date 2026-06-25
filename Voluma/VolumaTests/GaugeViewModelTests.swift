//
//  GaugeViewModelTests.swift
//  VolumaTests
//
//  Vérifie l'orchestration : lecture dérivée, calibrage, statut, table de graduation.
//

import Testing
import SwiftData
import Foundation
@testable import Voluma

@MainActor
struct GaugeViewModelTests {

    private func makeContext() throws -> ModelContext {
        let schema = Schema([Container.self, Liquid.self, PlanDocument.self, GaugePointModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        return ModelContext(try ModelContainer(for: schema, configurations: [config]))
    }

    private func hcyl(_ ctx: ModelContext) -> Container {
        let c = Container(name: "Cuve atelier")
        c.shape = .hcyl; c.dD = 712; c.dLen = 879
        ctx.insert(c)
        return c
    }

    private func box(_ ctx: ModelContext) -> Container {
        let c = Container(name: "Bac")
        c.shape = .box; c.dL = 500; c.dW = 400; c.dH = 300
        ctx.insert(c)
        return c
    }

    private func sp98(_ ctx: ModelContext) -> Liquid {
        let l = Liquid(name: "SP98", density: 0.75)
        ctx.insert(l)
        return l
    }

    // MARK: - Lecture

    @Test("Lecture boîte à mi-hauteur : volume, poids, %, reste, sensibilité")
    func boxReading() throws {
        let ctx = try makeContext()
        let vm = GaugeViewModel(container: box(ctx), liquid: sp98(ctx))
        vm.height_cm = 15            // 150 mm

        #expect(abs(vm.volumeL - 30) < 1e-6)
        #expect(abs(vm.massKg - 22.5) < 1e-6)        // 30 × 0,75
        #expect(abs(vm.fillPercent - 50) < 1e-6)
        #expect(abs(vm.remainingL - 30) < 1e-6)
        #expect(abs(vm.sensitivityLPerMm - 0.2) < 1e-6)
        #expect(abs(vm.fullVolumeL - 60) < 1e-6)
    }

    @Test("Conversion cm ↔ mm")
    func heightConversion() throws {
        let ctx = try makeContext()
        let vm = GaugeViewModel(container: box(ctx))
        vm.height_cm = 12.3
        #expect(abs(vm.height_mm - 123) < 1e-9)
        vm.height_mm = 250
        #expect(abs(vm.height_cm - 25) < 1e-9)
    }

    @Test("Cuve horizontale : 300 L → 56,9 cm via setHeight")
    func hcylSetHeightForVolume() throws {
        let ctx = try makeContext()
        let vm = GaugeViewModel(container: hcyl(ctx), liquid: sp98(ctx))
        vm.setHeight(forVolumeL: 300)
        #expect(abs(vm.height_cm - 56.9) < 0.1)
        #expect(abs(vm.volumeL - 300) < 0.05)
    }

    @Test("Sans liquide : poids = 0")
    func massWithoutLiquid() throws {
        let ctx = try makeContext()
        let vm = GaugeViewModel(container: box(ctx))
        vm.height_cm = 15
        #expect(vm.massKg == 0)
        #expect(abs(vm.volumeL - 30) < 1e-6)   // volume reste calculé
    }

    // MARK: - Statut de remplissage

    @Test("Statut de remplissage selon le pourcentage")
    func fillStatusThresholds() throws {
        let ctx = try makeContext()
        let vm = GaugeViewModel(container: box(ctx))     // plein = 60 L à 300 mm
        vm.height_mm = 0;   #expect(vm.fillStatus == .empty)
        vm.height_mm = 15;  #expect(vm.fillStatus == .low)        // 5 %
        vm.height_mm = 150; #expect(vm.fillStatus == .normal)     // 50 %
        vm.height_mm = 285; #expect(vm.fillStatus == .almostFull) // 95 %
        vm.height_mm = 300; #expect(vm.fillStatus == .full)
    }

    // MARK: - Calibrage

    @Test("Calibrage plausible appliqué au récipient")
    func calibrationApplied() throws {
        let ctx = try makeContext()
        let c = box(ctx)
        let vm = GaugeViewModel(container: c)
        let factor = vm.calibrate(knownVolumeL: 33, atHeight_mm: 150)  // brut = 30 L
        #expect(factor != nil)
        #expect(abs((factor ?? 0) - 1.1) < 1e-9)
        #expect(abs(c.k - 1.1) < 1e-9)
        vm.height_mm = 150
        #expect(abs(vm.volumeL - 33) < 1e-9)   // calibrage répercuté
    }

    @Test("Calibrage invraisemblable rejeté, k inchangé")
    func calibrationRejected() throws {
        let ctx = try makeContext()
        let c = box(ctx)
        let vm = GaugeViewModel(container: c)
        let factor = vm.calibrate(knownVolumeL: 60, atHeight_mm: 150)  // k = 2 → rejeté
        #expect(factor == nil)
        #expect(c.k == 1)
    }

    @Test("Réinitialisation du calibrage")
    func calibrationReset() throws {
        let ctx = try makeContext()
        let c = box(ctx); c.k = 1.2
        let vm = GaugeViewModel(container: c)
        vm.resetCalibration()
        #expect(c.k == 1)
    }

    // MARK: - Table de graduation

    @Test("Table de graduation : structure et monotonie")
    func graduationTableStructure() throws {
        let ctx = try makeContext()
        let vm = GaugeViewModel(container: hcyl(ctx), liquid: sp98(ctx))
        let rows = vm.graduationTable()

        #expect(rows.count >= 2)
        #expect(rows.first?.volumeL == 0)
        #expect(abs((rows.last?.volumeL ?? -1) - vm.fullVolumeL) < 1e-6)
        #expect(rows.last?.isRoundMark == true)

        // Hauteurs exactes strictement croissantes avec le volume
        for i in 1..<rows.count {
            #expect(rows[i].exactHeight_mm >= rows[i - 1].exactHeight_mm)
        }
        // Poids cohérent avec la densité
        if let r = rows.last {
            #expect(abs(r.massKg - r.volumeL * 0.75) < 1e-6)
        }
    }

    @Test("Table de graduation : écart d'arrondi borné par la sensibilité")
    func graduationDeltaBounded() throws {
        let ctx = try makeContext()
        let vm = GaugeViewModel(container: box(ctx), liquid: sp98(ctx))
        let rows = vm.graduationTable()
        // Boîte : 0,2 L/mm ; arrondi au cm ≤ 5 mm d'écart → ≤ 1 L environ
        for r in rows {
            #expect(abs(r.deltaL) < 1.01)
        }
    }

    @Test("Table à pas en litres : repères tous les 50 L")
    func graduationTableByStep() throws {
        let ctx = try makeContext()
        let vm = GaugeViewModel(container: hcyl(ctx), liquid: sp98(ctx))
        let rows = vm.graduationTable(stepL: 50)
        // 0, 50, 100, 150, 200, 250, 300, puis le plein (~350) → 8 lignes
        #expect(rows.count == 8)
        #expect(rows.first?.volumeL == 0)
        #expect(abs(rows[1].volumeL - 50) < 1e-9)
        #expect(abs(rows[6].volumeL - 300) < 1e-9)
        #expect(abs((rows.last?.volumeL ?? -1) - vm.fullVolumeL) < 1e-6)
        #expect(rows.last?.isRoundMark == true)
    }

    @Test("niceStep arrondit aux paliers 1/2/5 ×10ⁿ")
    func niceStepValues() {
        #expect(GaugeViewModel.niceStep(0.8) == 1)
        #expect(GaugeViewModel.niceStep(1.7) == 2)
        #expect(GaugeViewModel.niceStep(4) == 5)
        #expect(GaugeViewModel.niceStep(8) == 10)
        #expect(GaugeViewModel.niceStep(35) == 50)
        #expect(GaugeViewModel.niceStep(170) == 200)
    }
}
