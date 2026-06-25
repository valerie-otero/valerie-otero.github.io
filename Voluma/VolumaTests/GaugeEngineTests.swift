//
//  GaugeEngineTests.swift
//  VolumaTests
//
//  Vérifications numériques de référence du moteur de calcul.
//  Valeurs attendues fournies avec le moteur :
//   - cylindre horizontal D=712 / L=879 → 350,0 L
//   - 300 L → 56,9 cm
//   - boîte 500×400×300 → 60,0 L
//   - interpolation forme libre correcte
//

import Testing
import Foundation
@testable import Voluma

@MainActor
struct GaugeEngineTests {

    // MARK: - Boîte

    @Test("Boîte 500×400×300 → 60,0 L")
    func boxFullVolume() {
        let dims = ["L": 500.0, "W": 400.0, "H": 300.0]
        let v = GaugeEngine.fullVolume(shape: .box, dims: dims, points: [], k: 1)
        #expect(abs(v - 60.0) < 1e-6)
    }

    @Test("Boîte à mi-hauteur → 30,0 L")
    func boxPartialVolume() {
        let dims = ["L": 500.0, "W": 400.0, "H": 300.0]
        let v = GaugeEngine.volume(shape: .box, dims: dims, points: [], k: 1, h: 150)
        #expect(abs(v - 30.0) < 1e-6)
    }

    @Test("Boîte : hauteur écrêtée au plein")
    func boxClampsAtFull() {
        let dims = ["L": 500.0, "W": 400.0, "H": 300.0]
        let v = GaugeEngine.volume(shape: .box, dims: dims, points: [], k: 1, h: 999)
        #expect(abs(v - 60.0) < 1e-6)
    }

    // MARK: - Cylindre vertical

    @Test("Cylindre vertical D=1000 / H=1000")
    func vcylVolume() {
        let dims = ["D": 1000.0, "H": 1000.0]
        let full = GaugeEngine.fullVolume(shape: .vcyl, dims: dims, points: [], k: 1)
        #expect(abs(full - .pi * 250) < 1e-3)   // π·D²/4·H = π·250 L
        let half = GaugeEngine.volume(shape: .vcyl, dims: dims, points: [], k: 1, h: 500)
        #expect(abs(half - .pi * 125) < 1e-3)
    }

    // MARK: - Cylindre horizontal (cuve atelier)

    @Test("Cylindre horizontal D=712 / L=879 → 350,0 L")
    func hcylFullVolume() {
        let dims = ["D": 712.0, "L": 879.0]
        let full = GaugeEngine.fullVolume(shape: .hcyl, dims: dims, points: [], k: 1)
        #expect(abs(full - 350.0) < 0.2)
    }

    @Test("Cylindre horizontal : 300 L → 56,9 cm")
    func hcylHeightForVolume() {
        let dims = ["D": 712.0, "L": 879.0]
        let h = GaugeEngine.heightForVolume(shape: .hcyl, dims: dims, points: [], k: 1, V: 300)
        #expect(abs(h - 569) < 1.0)              // 569 mm = 56,9 cm
    }

    @Test("Cylindre horizontal : aller-retour volume↔hauteur")
    func hcylRoundTrip() {
        let dims = ["D": 712.0, "L": 879.0]
        let h = GaugeEngine.heightForVolume(shape: .hcyl, dims: dims, points: [], k: 1, V: 300)
        let v = GaugeEngine.volume(shape: .hcyl, dims: dims, points: [], k: 1, h: h)
        #expect(abs(v - 300) < 0.05)
    }

    @Test("Cylindre horizontal : demi-hauteur = demi-volume")
    func hcylHalfHeightIsHalfVolume() {
        let dims = ["D": 712.0, "L": 879.0]
        let full = GaugeEngine.fullVolume(shape: .hcyl, dims: dims, points: [], k: 1)
        let half = GaugeEngine.volume(shape: .hcyl, dims: dims, points: [], k: 1, h: 356) // D/2
        #expect(abs(half - full / 2) < 0.05)
    }

    // MARK: - Forme libre (interpolation linéaire)

    @Test("Forme libre : interpolation linéaire entre points")
    func customInterpolation() {
        let pts = [GaugePoint(h_mm: 100, v_L: 10),
                   GaugePoint(h_mm: 200, v_L: 30)]
        // segment implicite [0,100] : moitié → 5 L
        #expect(abs(GaugeEngine.volume(shape: .custom, dims: [:], points: pts, k: 1, h: 50) - 5) < 1e-9)
        // segment [100,200] : milieu → 20 L
        #expect(abs(GaugeEngine.volume(shape: .custom, dims: [:], points: pts, k: 1, h: 150) - 20) < 1e-9)
        // au sommet → 30 L
        #expect(abs(GaugeEngine.volume(shape: .custom, dims: [:], points: pts, k: 1, h: 200) - 30) < 1e-9)
        // au-delà du dernier point : écrêté → 30 L
        #expect(abs(GaugeEngine.volume(shape: .custom, dims: [:], points: pts, k: 1, h: 250) - 30) < 1e-9)
    }

    @Test("Forme libre : points non triés gérés")
    func customUnsortedPoints() {
        let pts = [GaugePoint(h_mm: 200, v_L: 30),
                   GaugePoint(h_mm: 100, v_L: 10)]
        #expect(abs(GaugeEngine.volume(shape: .custom, dims: [:], points: pts, k: 1, h: 150) - 20) < 1e-9)
    }

    @Test("Forme libre : hauteur pleine = dernier point")
    func customFullHeight() {
        let pts = [GaugePoint(h_mm: 100, v_L: 10), GaugePoint(h_mm: 200, v_L: 30)]
        #expect(GaugeEngine.fullHeight(shape: .custom, dims: [:], points: pts) == 200)
    }

    // MARK: - Masse

    @Test("Masse = volume × densité")
    func massFromDensity() {
        #expect(GaugeEngine.mass(volumeL: 100, density: 0.75) == 75)
    }

    // MARK: - Calibrage

    @Test("Calibrage dans la plage admise (k=1,1)")
    func calibrationWithinRange() {
        let dims = ["L": 500.0, "W": 400.0, "H": 300.0]   // brut @150 mm = 30 L
        let k = GaugeEngine.calibrationFactor(shape: .box, dims: dims, hMeasured: 150, vKnown: 33)
        #expect(k != nil)
        #expect(abs((k ?? 0) - 1.1) < 1e-9)
    }

    @Test("Calibrage rejeté hors plage [0,7 ; 1,3]")
    func calibrationRejectsImplausible() {
        let dims = ["L": 500.0, "W": 400.0, "H": 300.0]
        // k = 60/30 = 2,0 → invraisemblable → nil
        #expect(GaugeEngine.calibrationFactor(shape: .box, dims: dims, hMeasured: 150, vKnown: 60) == nil)
    }

    @Test("Calibrage appliqué : le volume est mis à l'échelle")
    func calibratedVolumeScales() {
        let dims = ["L": 500.0, "W": 400.0, "H": 300.0]
        let v = GaugeEngine.volume(shape: .box, dims: dims, points: [], k: 1.1, h: 150)
        #expect(abs(v - 33.0) < 1e-9)
    }

    // MARK: - Sensibilité dV/dh

    @Test("Sensibilité d'une boîte = L·W/1e6 (constante)")
    func sensitivityBox() {
        let dims = ["L": 500.0, "W": 400.0, "H": 300.0]   // 500·400/1e6 = 0,2 L/mm
        let s = GaugeEngine.sensitivity(shape: .box, dims: dims, points: [], k: 1, h: 150)
        #expect(abs(s - 0.2) < 1e-6)
    }

    @Test("Sensibilité jamais négative")
    func sensitivityNonNegative() {
        let dims = ["D": 712.0, "L": 879.0]
        for h in stride(from: 0.0, through: 712.0, by: 50.0) {
            let s = GaugeEngine.sensitivity(shape: .hcyl, dims: dims, points: [], k: 1, h: h)
            #expect(s >= 0)
        }
    }
}
