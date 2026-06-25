//
//  Liquid.swift
//  Voluma
//
//  Liquide (@Model) — synchronisé iCloud.
//  La viscosité est indicative : elle n'entre pas dans le calcul de volume/poids.
//

import Foundation
import SwiftData

@Model final class Liquid {
    var name: String = ""
    var density: Double = 0.75   // kg/L
    var viscosity: Double = 0     // mPa·s (indicatif, hors calcul)
    var note: String = ""
    var colorHex: String = ""     // couleur d'identification (ex. "#43A047"); vide = défaut
    var createdAt: Date = Date()

    init(name: String = "", density: Double = 0.75, viscosity: Double = 0, note: String = "") {
        self.name = name
        self.density = density
        self.viscosity = viscosity
        self.note = note
    }

    /// Borne les valeurs avant enregistrement (appelé à la fin de l'édition) : une densité
    /// non finie ou <= 0 retomberait en masse nulle/absurde.
    func sanitizeInPlace() {
        density = ModelGuard.clampedDensity(density)   // borne dans la plage plausible (0,3–2,0)
        if !viscosity.isFinite || viscosity < 0 { viscosity = 0 }
    }
}
