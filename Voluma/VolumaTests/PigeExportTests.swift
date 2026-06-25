//
//  PigeExportTests.swift
//  VolumaTests
//
//  Vérifie que l'export PDF de la table de pige est bien au format A4.
//

import Testing
import SwiftUI
import CoreGraphics
@testable import Voluma

@MainActor
struct PigeExportTests {

    @Test("Export PDF au format A4 (595 × 842 pt)")
    func pdfIsA4() throws {
        let container = Container(name: "Cuve atelier")
        container.shape = .hcyl; container.dD = 712; container.dLen = 879
        let liquid = Liquid(name: "SP98", density: 0.75)
        let vm = GaugeViewModel(container: container, liquid: liquid)
        let rows = vm.graduationTable(stepL: 25)

        let view = PigePrintView(rows: rows,
                                 containerName: "Cuve atelier",
                                 shapeTitle: container.shape.title,
                                 liquid: liquid,
                                 fullVolumeL: vm.fullVolumeL,
                                 fullHeight_mm: vm.fullHeight_mm)

        let url = try #require(PigeExport.pdfA4(from: view, fileName: "voluma-test-\(UUID().uuidString).pdf"))
        let doc = try #require(CGPDFDocument(url as CFURL))
        #expect(doc.numberOfPages >= 1)

        let box = try #require(doc.page(at: 1)).getBoxRect(.mediaBox)
        #expect(abs(box.width - 595.2) < 1.0)
        #expect(abs(box.height - 841.8) < 1.0)
    }
}
