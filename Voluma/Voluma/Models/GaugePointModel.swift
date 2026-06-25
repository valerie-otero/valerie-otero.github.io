//
//  GaugePointModel.swift
//  Voluma
//
//  Point de jauge persistant (forme libre) : couple (hauteur mesurée, volume connu).
//  Distinct de la struct `GaugePoint` du moteur, qui reste un type valeur pur.
//

import Foundation
import SwiftData

@Model final class GaugePointModel {
    var h_mm: Double = 0   // hauteur mesurée (mm)
    var v_L: Double = 0    // volume connu (L)

    /// Inverse de `Container.points` (requis par CloudKit).
    var container: Container?

    init(h_mm: Double = 0, v_L: Double = 0) {
        self.h_mm = h_mm
        self.v_L = v_L
    }
}
