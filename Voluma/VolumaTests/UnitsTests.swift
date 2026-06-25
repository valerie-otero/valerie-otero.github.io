//
//  UnitsTests.swift
//  VolumaTests
//
//  Garantit que les conversions d'unités sont exactes et sans perte (aller-retour),
//  de sorte que le moteur (en L/kg) reste la seule source de vérité des calculs.
//

import Testing
import Foundation
@testable import Voluma

struct UnitsTests {

    @Test("Volume : facteurs exacts")
    func volumeFactors() {
        #expect(abs(VolumeUnit.gallonUS.toLiters(1) - 3.785411784) < 1e-12)
        #expect(abs(VolumeUnit.gallonImp.toLiters(1) - 4.54609) < 1e-12)
        #expect(VolumeUnit.liter.toLiters(42) == 42)
        // 350 L → gallons US
        #expect(abs(VolumeUnit.gallonUS.fromLiters(350) - 350 / 3.785411784) < 1e-12)
    }

    @Test("Volume : aller-retour sans perte")
    func volumeRoundTrip() {
        for unit in VolumeUnit.allCases {
            for liters in [0.0, 1, 56.9, 175, 349.98, 1000] {
                #expect(abs(unit.toLiters(unit.fromLiters(liters)) - liters) < 1e-9)
            }
        }
    }

    @Test("Masse : facteur exact + aller-retour")
    func massConversions() {
        #expect(abs(MassUnit.pound.toKg(1) - 0.45359237) < 1e-12)
        #expect(MassUnit.kilogram.fromKg(131.25) == 131.25)
        for unit in MassUnit.allCases {
            for kg in [0.0, 22.5, 131.25, 1000] {
                #expect(abs(unit.toKg(unit.fromKg(kg)) - kg) < 1e-9)
            }
        }
    }
}
