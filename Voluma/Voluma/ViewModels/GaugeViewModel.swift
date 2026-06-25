//
//  GaugeViewModel.swift
//  Voluma
//
//  Orchestrateur de lecture : à partir d'un récipient, d'un liquide et d'une hauteur
//  mesurée à la pige, expose volume / poids / pourcentage / reste / sensibilité,
//  gère le calibrage et produit la table de graduation. S'appuie sur GaugeEngine.
//
//  Source de vérité interne : hauteur en mm.
//

import Foundation
import Observation

/// État de remplissage, pour le bandeau d'alerte de la lecture.
enum FillStatus {
    case empty, low, normal, almostFull, full
}

/// Une ligne de table de graduation (barème de jaugeage).
struct GraduationRow: Identifiable, Hashable {
    let id = UUID()
    let volumeL: Double          // repère de volume
    let massKg: Double           // poids correspondant (dépend du liquide)
    let exactHeight_mm: Double   // hauteur exacte pour atteindre ce volume
    let roundedHeight_cm: Double // hauteur arrondie au cm (lecture pratique)
    let volumeAtRounded_L: Double// volume réel à la hauteur arrondie
    let isRoundMark: Bool        // repère majeur (mis en évidence)

    /// Écart de volume induit par l'arrondi de la hauteur au cm.
    var deltaL: Double { volumeAtRounded_L - volumeL }
}

@MainActor
@Observable
final class GaugeViewModel {

    var container: Container?
    var liquid: Liquid?

    /// Hauteur mesurée à la pige, en mm.
    var height_mm: Double = 0

    init(container: Container? = nil, liquid: Liquid? = nil) {
        self.container = container
        self.liquid = liquid
    }

    // MARK: - Géométrie / liquide courants

    var shape: ContainerShape { container?.shape ?? .box }
    var dims: [String: Double] { container?.dims ?? [:] }
    var points: [GaugePoint] { container?.gaugePoints ?? [] }
    var k: Double { container?.k ?? 1 }
    var density: Double { liquid?.density ?? 0 }

    var fullHeight_mm: Double {
        GaugeEngine.fullHeight(shape: shape, dims: dims, points: points)
    }

    // MARK: - Lecture (dérivée de height_mm)

    var volumeL: Double {
        GaugeEngine.volume(shape: shape, dims: dims, points: points, k: k, h: height_mm)
    }

    var fullVolumeL: Double {
        GaugeEngine.fullVolume(shape: shape, dims: dims, points: points, k: k)
    }

    var massKg: Double {
        GaugeEngine.mass(volumeL: volumeL, density: density)
    }

    /// Pourcentage de remplissage [0, 100] — purement géométrique (indépendant du liquide).
    var fillPercent: Double {
        guard fullVolumeL > 0 else { return 0 }
        return GaugeEngine.clamp(volumeL / fullVolumeL * 100, 0, 100)
    }

    /// Volume restant avant le plein (L).
    var remainingL: Double { max(0, fullVolumeL - volumeL) }

    /// Fraction de **hauteur** remplie [0, 1] — pour la visualisation (niveau physique),
    /// distincte de `fillPercent` qui est une fraction de volume.
    var heightFraction: Double {
        let full = fullHeight_mm
        guard full > 0 else { return 0 }
        return GaugeEngine.clamp(height_mm, 0, full) / full
    }

    /// Sensibilité locale dV/dh (L/mm) — incertitude de lecture.
    var sensitivityLPerMm: Double {
        GaugeEngine.sensitivity(shape: shape, dims: dims, points: points, k: k, h: height_mm)
    }

    var fillStatus: FillStatus {
        let p = fillPercent
        if p <= 0 { return .empty }
        if p >= 100 { return .full }
        if p < 10 { return .low }
        if p > 90 { return .almostFull }
        return .normal
    }

    // MARK: - Hauteur en cm (pour l'UI)

    var height_cm: Double {
        get { height_mm / 10 }
        set { height_mm = newValue * 10 }
    }

    /// Positionne la hauteur à partir d'un volume cible (inversion par dichotomie).
    func setHeight(forVolumeL V: Double) {
        height_mm = GaugeEngine.heightForVolume(shape: shape, dims: dims, points: points, k: k, V: V)
    }

    // MARK: - Calibrage

    /// Calcule et applique un facteur de calibrage à partir d'un volume connu
    /// mesuré à une hauteur donnée. Met à jour `container.k` et renvoie le facteur
    /// s'il est plausible (sinon `nil`, sans modifier le récipient).
    @discardableResult
    func calibrate(knownVolumeL: Double, atHeight_mm h: Double) -> Double? {
        guard let container else { return nil }
        guard let factor = GaugeEngine.calibrationFactor(
            shape: container.shape, dims: container.dims, hMeasured: h, vKnown: knownVolumeL
        ) else { return nil }
        container.k = factor
        return factor
    }

    /// Réinitialise le calibrage (k = 1).
    func resetCalibration() { container?.k = 1 }

    // MARK: - Table de graduation

    /// Construit le barème : repères de volume « ronds », hauteur exacte,
    /// repère pratique arrondi au cm et écart de volume induit.
    func graduationTable(targetRowCount: Int = 11) -> [GraduationRow] {
        let full = fullVolumeL
        guard full > 0 else { return [] }
        return graduationRows(step: Self.niceStep(full / Double(max(1, targetRowCount - 1))))
    }

    /// Génération de pige : repères tous les `stepL` litres (50, 100, 150 …),
    /// avec la hauteur exacte à marquer.
    func graduationTable(stepL: Double) -> [GraduationRow] {
        graduationRows(step: stepL)
    }

    private func graduationRows(step: Double) -> [GraduationRow] {
        let full = fullVolumeL
        guard full.isFinite, full > 0, step.isFinite, step > 0 else { return [] }
        let majorStep = step * 5   // repères majeurs tous les 5 pas

        var rows: [GraduationRow] = []
        var v = 0.0
        // Plafond de sûreté : une pige de 5000 repères est déjà absurde — protège contre
        // un pas minuscule / un volume géant arrivé par un import non fiable.
        while v < full - 1e-9 && rows.count < 5_000 {
            rows.append(makeRow(volumeL: v, isRound: v.truncatingRemainder(dividingBy: majorStep) < 1e-6))
            v += step
        }
        rows.append(makeRow(volumeL: full, isRound: true))   // plein toujours présent et majeur
        return rows
    }

    private func makeRow(volumeL v: Double, isRound: Bool) -> GraduationRow {
        let exactH = GaugeEngine.heightForVolume(shape: shape, dims: dims, points: points, k: k, V: v)
        let roundedCm = (exactH / 10).rounded()
        let vAtRounded = GaugeEngine.volume(shape: shape, dims: dims, points: points, k: k, h: roundedCm * 10)
        return GraduationRow(
            volumeL: v,
            massKg: GaugeEngine.mass(volumeL: v, density: density),
            exactHeight_mm: exactH,
            roundedHeight_cm: roundedCm,
            volumeAtRounded_L: vAtRounded,
            isRoundMark: isRound
        )
    }

    /// Arrondit un pas brut à un « beau » pas : 1, 2, 5 × 10ⁿ.
    static func niceStep(_ raw: Double) -> Double {
        guard raw > 0 else { return 1 }
        let exponent = floor(log10(raw))
        let base = pow(10, exponent)
        let f = raw / base
        let nice: Double
        switch f {
        case ..<1.5: nice = 1
        case ..<3:   nice = 2
        case ..<7:   nice = 5
        default:     nice = 10
        }
        return nice * base
    }
}
