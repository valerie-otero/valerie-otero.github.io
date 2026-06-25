//
//  CompositeShapeTests.swift
//  VolumaTests
//
//  Les formes composées (calculées) génèrent une table hauteur → volume que le moteur
//  interpole. Le puisard est linéaire par morceaux → EXACT ; le fond incliné est
//  quadratique → vérifié à faible tolérance.
//

import Testing
@testable import Voluma

@MainActor
struct CompositeShapeTests {

    // Cuve principale 1000×500×400 mm + puisard 200×200×100 mm.
    // Volume puisard = 4 L ; volume cuve = 200 L.
    private func sumpVolume(at h: Double) -> Double {
        let pts = CompositeShape.gaugePoints(kind: .sumpBox, dL: 1000, dW: 500, dH: 400,
                                             sumpL: 200, sumpW: 200, sumpH: 100, shallowH: 0)
        return GaugeEngine.volume(shape: .custom, dims: [:], points: pts, k: 1, h: h)
    }

    @Test func sumpExactBreakpoints() {
        #expect(abs(sumpVolume(at: 0) - 0) < 1e-9)
        #expect(abs(sumpVolume(at: 50) - 2) < 1e-9)     // moitié du puisard
        #expect(abs(sumpVolume(at: 100) - 4) < 1e-9)    // haut du puisard
        #expect(abs(sumpVolume(at: 300) - 104) < 1e-9)  // 4 + 200 mm dans la cuve (100 L)
        #expect(abs(sumpVolume(at: 500) - 204) < 1e-9)  // plein
    }

    @Test func sumpFullHeightAndVolume() {
        let pts = CompositeShape.gaugePoints(kind: .sumpBox, dL: 1000, dW: 500, dH: 400,
                                             sumpL: 200, sumpW: 200, sumpH: 100, shallowH: 0)
        #expect(GaugeEngine.fullHeight(shape: .custom, dims: [:], points: pts) == 500)
        #expect(abs(GaugeEngine.fullVolume(shape: .custom, dims: [:], points: pts, k: 1) - 204) < 1e-9)
        #expect(CompositeShape.fullHeight(kind: .sumpBox, dH: 400, sumpH: 100) == 500)
    }

    // Fond incliné 1000×500, profond 300 mm, faible 100 mm → dénivelé 200 mm.
    private func slopedVolume(at h: Double) -> Double {
        let pts = CompositeShape.gaugePoints(kind: .slopedBox, dL: 1000, dW: 500, dH: 300,
                                             sumpL: 0, sumpW: 0, sumpH: 0, shallowH: 100)
        return GaugeEngine.volume(shape: .custom, dims: [:], points: pts, k: 1, h: h)
    }

    @Test func slopedWedgeAndTop() {
        // h=100 est un point échantillonné (200·12/24) → exact : W·½·L·h²/drop = 12,5 L
        #expect(abs(slopedVolume(at: 100) - 12.5) < 1e-6)
        // h=200 (haut du coin) : coin plein = W·½·L·drop = 50 L
        #expect(abs(slopedVolume(at: 200) - 50) < 1e-6)
        // plein h=300 : 50 (coin) + 1000·500·100/1e6 (dalle) = 100 L
        #expect(abs(slopedVolume(at: 300) - 100) < 1e-6)
    }

    @Test func slopedMonotonicAndInvertible() {
        let pts = CompositeShape.gaugePoints(kind: .slopedBox, dL: 1000, dW: 500, dH: 300,
                                             sumpL: 0, sumpW: 0, sumpH: 0, shallowH: 100)
        // Strictement croissant
        var prev = -1.0
        for h in stride(from: 0.0, through: 300.0, by: 10.0) {
            let v = GaugeEngine.volume(shape: .custom, dims: [:], points: pts, k: 1, h: h)
            #expect(v >= prev - 1e-9)
            prev = v
        }
        // Inversion volume → hauteur cohérente
        let h = GaugeEngine.heightForVolume(shape: .custom, dims: [:], points: pts, k: 1, V: 50)
        #expect(abs(h - 200) < 1.0)
    }

    @Test func slopedSideOrderIndependent() {
        // Inverser côté profond / côté faible donne EXACTEMENT le même volume.
        let a = CompositeShape.gaugePoints(kind: .slopedBox, dL: 1000, dW: 500, dH: 300,
                                           sumpL: 0, sumpW: 0, sumpH: 0, shallowH: 100)
        let b = CompositeShape.gaugePoints(kind: .slopedBox, dL: 1000, dW: 500, dH: 100,
                                           sumpL: 0, sumpW: 0, sumpH: 0, shallowH: 300)
        let va = GaugeEngine.fullVolume(shape: .custom, dims: [:], points: a, k: 1)
        let vb = GaugeEngine.fullVolume(shape: .custom, dims: [:], points: b, k: 1)
        #expect(abs(va - vb) < 1e-6)
        #expect(abs(va - 100) < 1e-6)
    }

    @Test func degenerateCases() {
        // Fond plat (côté faible = côté profond) → boîte simple 1000×500×300 = 150 L
        let flat = CompositeShape.gaugePoints(kind: .slopedBox, dL: 1000, dW: 500, dH: 300,
                                              sumpL: 0, sumpW: 0, sumpH: 0, shallowH: 300)
        #expect(abs(GaugeEngine.fullVolume(shape: .custom, dims: [:], points: flat, k: 1) - 150) < 1e-9)
        // Puisard nul → cuve seule 200 L
        let noSump = CompositeShape.gaugePoints(kind: .sumpBox, dL: 1000, dW: 500, dH: 400,
                                                sumpL: 0, sumpW: 0, sumpH: 0, shallowH: 0)
        #expect(abs(GaugeEngine.fullVolume(shape: .custom, dims: [:], points: noSump, k: 1) - 200) < 1e-9)
    }
}
