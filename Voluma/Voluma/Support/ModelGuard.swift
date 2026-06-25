//
//  ModelGuard.swift
//  Voluma
//
//  Frontière de validation UNIQUE et partagée. Toute donnée numérique (saisie éditeur,
//  import JSON, enregistrement) passe par ces bornes, pour qu'aucune valeur aberrante
//  (NaN/Inf, négative, absurde) ne soit persistée ni affichée comme une donnée d'autorité.
//  Le moteur GaugeEngine reste inchangé : on défend ses ENTRÉES.
//

import Foundation

nonisolated enum ModelGuard {

    // Bornes physiques plausibles.
    static let maxDim_mm = 100_000.0          // 100 m
    static let densityRange = 0.3...2.0       // kg/L
    static let kRange = 0.5...2.0             // facteur de calibrage (marge autour de 0,7–1,3)
    static let maxPointHeight_mm = 10_000.0
    static let maxPointVolume_L = 10_000_000.0
    static let maxPoints = 2_000

    /// Cote (mm) finie et bornée ; défaut 0.
    static func dim(_ v: Double?) -> Double {
        guard let v, v.isFinite else { return 0 }
        return min(max(v, 0), maxDim_mm)
    }

    /// Facteur de calibrage borné ; défaut 1.
    static func k(_ v: Double?) -> Double {
        guard let v, v.isFinite, v > 0 else { return 1 }
        return min(max(v, kRange.lowerBound), kRange.upperBound)
    }

    /// Pas de jauge (L) : fini, >= 0 ; défaut 0 (automatique).
    static func step(_ v: Double?) -> Double {
        guard let v, v.isFinite, v >= 0 else { return 0 }
        return min(v, maxPointVolume_L)
    }

    /// Densité valide (kg/L) si fournie et plausible, sinon nil (import : on garde l'existant).
    static func density(_ v: Double?) -> Double? {
        guard let v, v.isFinite, densityRange.contains(v) else { return nil }
        return v
    }

    /// Densité bornée dans la plage plausible (édition : on corrige la valeur saisie).
    static func clampedDensity(_ v: Double) -> Double {
        guard v.isFinite, v > 0 else { return 0.75 }
        return min(max(v, densityRange.lowerBound), densityRange.upperBound)
    }

    /// Hauteur d'un point de jauge bornée (mêmes bornes que l'acceptation à l'import).
    static func pointHeight(_ v: Double) -> Double {
        guard v.isFinite, v >= 0 else { return 0 }
        return min(v, maxPointHeight_mm)
    }

    /// Volume d'un point de jauge borné.
    static func pointVolume(_ v: Double) -> Double {
        guard v.isFinite, v >= 0 else { return 0 }
        return min(v, maxPointVolume_L)
    }

    /// Viscosité valide (>= 0) si fournie, sinon nil.
    static func viscosity(_ v: Double?) -> Double? {
        guard let v, v.isFinite, v >= 0 else { return nil }
        return v
    }

    /// Un couple (hauteur, volume) est-il exploitable ?
    static func isValidPoint(h_mm: Double, v_L: Double) -> Bool {
        h_mm.isFinite && v_L.isFinite
            && (0...maxPointHeight_mm).contains(h_mm)
            && (0...maxPointVolume_L).contains(v_L)
    }
}
