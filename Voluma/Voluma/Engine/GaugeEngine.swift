//
//  GaugeEngine.swift
//  Voluma
//
//  Moteur de calcul pur (sans état, sans dépendance UI).
//  Unités internes : longueurs en mm, volumes en litres (L), masses en kg.
//
//  Vérifications de référence :
//   - cylindre horizontal D=712 / L=879  → 350,0 L
//   - 300 L → 56,9 cm
//   - boîte 500×400×300 → 60,0 L
//   - interpolation forme libre correcte
//
//  Modèle de calcul réalisé par Valérie Otero.
//

import Foundation

enum ContainerShape: String, Codable, CaseIterable {
    case box, vcyl, hcyl, custom
}

struct GaugePoint: Codable, Hashable, Identifiable {
    var id = UUID()
    var h_mm: Double   // hauteur mesurée (mm)
    var v_L: Double    // volume connu (L)
}

enum GaugeEngine {

    static func clamp(_ x: Double, _ lo: Double, _ hi: Double) -> Double { min(max(x, lo), hi) }

    /// Aire d'un segment circulaire de hauteur h dans un cercle de rayon r (mm²)
    static func segmentArea(_ h: Double, _ r: Double) -> Double {
        if h <= 0 { return 0 }
        if h >= 2 * r { return .pi * r * r }
        return r * r * acos((r - h) / r) - (r - h) * sqrt(2 * r * h - h * h)
    }

    /// Volume brut (L) sans calibrage, selon la forme et la hauteur h (mm)
    static func rawVolume(shape: ContainerShape, dims: [String: Double],
                          points: [GaugePoint], h: Double) -> Double {
        switch shape {
        case .box:
            let H = dims["H"] ?? 0
            return (dims["L"] ?? 0) * (dims["W"] ?? 0) * clamp(h, 0, H) / 1e6
        case .vcyl:
            let H = dims["H"] ?? 0, D = dims["D"] ?? 0
            return .pi * D * D / 4 * clamp(h, 0, H) / 1e6
        case .hcyl:
            let D = dims["D"] ?? 0, L = dims["L"] ?? 0
            return segmentArea(clamp(h, 0, D), D / 2) * L / 1e6
        case .custom:
            var pts = [GaugePoint(h_mm: 0, v_L: 0)] + points.filter { $0.h_mm > 0 && $0.v_L >= 0 }
            pts.sort { $0.h_mm < $1.h_mm }
            guard pts.count >= 2 else { return 0 }
            let hc = clamp(h, 0, pts.last!.h_mm)
            for i in 1..<pts.count where hc <= pts[i].h_mm {
                let span = pts[i].h_mm - pts[i - 1].h_mm
                let t = span == 0 ? 0 : (hc - pts[i - 1].h_mm) / span
                return pts[i - 1].v_L + t * (pts[i].v_L - pts[i - 1].v_L)
            }
            return pts.last!.v_L
        }
    }

    static func fullHeight(shape: ContainerShape, dims: [String: Double],
                           points: [GaugePoint]) -> Double {
        switch shape {
        case .box, .vcyl: return dims["H"] ?? 0
        case .hcyl:       return dims["D"] ?? 0
        case .custom:     return points.filter { $0.h_mm > 0 }.map { $0.h_mm }.max() ?? 0
        }
    }

    // --- API calibrée : un récipient porte un facteur d'échelle k (1 = non calibré) ---

    static func volume(shape: ContainerShape, dims: [String: Double],
                       points: [GaugePoint], k: Double, h: Double) -> Double {
        k * rawVolume(shape: shape, dims: dims, points: points, h: h)
    }

    static func fullVolume(shape: ContainerShape, dims: [String: Double],
                           points: [GaugePoint], k: Double) -> Double {
        volume(shape: shape, dims: dims, points: points, k: k,
               h: fullHeight(shape: shape, dims: dims, points: points))
    }

    static func mass(volumeL: Double, density: Double) -> Double { volumeL * density }

    /// Inversion volume → hauteur (mm) par dichotomie (monotone croissant)
    static func heightForVolume(shape: ContainerShape, dims: [String: Double],
                                points: [GaugePoint], k: Double, V: Double) -> Double {
        let hMax = fullHeight(shape: shape, dims: dims, points: points)
        guard hMax > 0 else { return 0 }
        var lo = 0.0, hi = hMax
        for _ in 0..<60 {
            let mid = (lo + hi) / 2
            if volume(shape: shape, dims: dims, points: points, k: k, h: mid) < V { lo = mid }
            else { hi = mid }
        }
        return (lo + hi) / 2
    }

    /// Sensibilité locale dV/dh (L par mm) — utile pour l'incertitude de lecture
    static func sensitivity(shape: ContainerShape, dims: [String: Double],
                            points: [GaugePoint], k: Double, h: Double) -> Double {
        let e = 0.5
        let vp = volume(shape: shape, dims: dims, points: points, k: k, h: h + e)
        let vm = volume(shape: shape, dims: dims, points: points, k: k, h: h - e)
        return max(0, (vp - vm) / (2 * e))
    }

    /// Calibrage : facteur k tel que la hauteur lue corresponde au volume connu
    static func calibrationFactor(shape: ContainerShape, dims: [String: Double],
                                  hMeasured: Double, vKnown: Double) -> Double? {
        let raw = rawVolume(shape: shape, dims: dims, points: [], h: hMeasured)
        guard raw > 0 else { return nil }
        let k = vKnown / raw
        return (k > 0.7 && k < 1.3) ? k : nil   // rejette les écarts invraisemblables
    }
}
