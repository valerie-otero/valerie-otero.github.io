//
//  CompositeShape.swift
//  Voluma
//
//  Formes COMPOSÉES, calculées (sans mesure). Le moteur GaugeEngine n'est pas modifié :
//  une forme composée est un récipient `.custom` dont la table hauteur → volume est
//  GÉNÉRÉE analytiquement à partir de quelques cotes. Le moteur l'interpole ensuite
//  comme n'importe quelle table de jauge (inversion, sensibilité, table, PDF inclus).
//
//  • Boîte + puisard  : linéaire par morceaux → EXACTE (3 points suffisent).
//  • Boîte à fond incliné : volume quadratique dans le coin → échantillonné finement
//    (l'écart d'interpolation est très inférieur à l'incertitude de mesure).
//

import SwiftUI

enum CompositeKind: String, CaseIterable, Identifiable {
    case sumpBox      // boîte rectangulaire avec un puisard (fond plus profond)
    case slopedBox    // boîte rectangulaire à fond incliné (profondeurs différentes)

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .sumpBox:   "Boîte + puisard"
        case .slopedBox: "Boîte à fond incliné"
        }
    }

    var hint: LocalizedStringKey {
        switch self {
        case .sumpBox:   "Cuve rectangulaire avec un puisard (fond plus profond) — volume calculé exactement."
        case .slopedBox: "Cuve rectangulaire à fond incliné, profondeurs différentes d'un bout à l'autre."
        }
    }

    var symbol: String {
        switch self {
        case .sumpBox:   "rectangle.split.1x2"
        case .slopedBox: "triangle"
        }
    }
}

enum CompositeShape {

    /// Table hauteur (mm) → volume (L) générée à partir des cotes (longueurs en mm).
    /// Renvoie les points avec h > 0 ; le moteur ajoute lui-même l'origine (0, 0).
    nonisolated static func gaugePoints(kind: CompositeKind,
                                        dL: Double, dW: Double, dH: Double,
                                        sumpL: Double, sumpW: Double, sumpH: Double,
                                        shallowH: Double) -> [GaugePoint] {
        switch kind {
        case .sumpBox:
            // Puisard (sl×sw×sh) au fond, surmonté de la cuve principale (L×W×H).
            let sumpV = sumpL * sumpW * sumpH / 1e6
            let mainV = dL * dW * dH / 1e6
            var pts: [GaugePoint] = []
            if sumpH > 0 { pts.append(GaugePoint(h_mm: sumpH, v_L: sumpV)) }
            if dH > 0 { pts.append(GaugePoint(h_mm: sumpH + dH, v_L: sumpV + mainV)) }
            return pts

        case .slopedBox:
            // Fond incliné : l'ordre des deux côtés n'a pas d'importance — le plus grand est
            // le côté profond, le plus petit le côté faible. h mesuré depuis le point le plus bas.
            let deep = max(dH, shallowH)
            let shallow = min(dH, shallowH)
            let drop = deep - shallow           // dénivelé du fond
            var pts: [GaugePoint] = []
            if drop > 0 {
                // Coin triangulaire : V(h) = W · ½ · L · h² / drop  (quadratique).
                let samples = 24
                for i in 1...samples {
                    let h = drop * Double(i) / Double(samples)
                    let v = dW * 0.5 * dL * h * h / drop / 1e6
                    pts.append(GaugePoint(h_mm: h, v_L: v))
                }
            }
            if deep > drop {
                // Au-dessus du coin : section rectangulaire pleine (linéaire).
                let wedgeV = dW * 0.5 * dL * drop / 1e6
                pts.append(GaugePoint(h_mm: deep, v_L: wedgeV + dL * dW * (deep - drop) / 1e6))
            }
            return pts
        }
    }

    /// Hauteur totale du récipient (mm) pour la forme composée.
    nonisolated static func fullHeight(kind: CompositeKind, dH: Double, sumpH: Double, shallowH: Double = 0) -> Double {
        switch kind {
        case .sumpBox:   return sumpH + dH
        case .slopedBox: return max(dH, shallowH)
        }
    }
}
