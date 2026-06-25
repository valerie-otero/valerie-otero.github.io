//
//  Container.swift
//  Voluma
//
//  Récipient (@Model) — synchronisé iCloud.
//  Compatibilité CloudKit : tous les attributs ont une valeur par défaut,
//  toutes les relations sont optionnelles/à valeur par défaut et possèdent un inverse.
//

import Foundation
import SwiftData

@Model final class Container {
    var name: String = ""
    var shapeRaw: String = ContainerShape.box.rawValue

    // Boîte
    var dL: Double = 0
    var dW: Double = 0
    var dH: Double = 0

    // Cylindres
    var dD: Double = 0
    var dLen: Double = 0

    /// Forme composée (calculée) : "" = forme géométrique simple ou table de jauge manuelle ;
    /// sinon `CompositeKind` (puisard, fond incliné). La forme moteur reste `.custom`.
    var compositeKind: String = ""

    // Cotes du puisard (boîte + puisard) ; cote du côté faible (fond incliné).
    var sumpL: Double = 0
    var sumpW: Double = 0
    var sumpH: Double = 0
    var shallowH: Double = 0

    /// Facteur de calibrage (1 = non calibré)
    var k: Double = 1

    /// Pas de la jauge enregistré pour ce récipient (litres ; 0 = automatique).
    var gaugeStepL: Double = 0

    /// Optionnelle : CloudKit exige que toutes les relations soient optionnelles.
    @Relationship(deleteRule: .cascade, inverse: \GaugePointModel.container)
    var points: [GaugePointModel]? = []

    @Relationship(deleteRule: .cascade, inverse: \PlanDocument.container)
    var plan: PlanDocument?

    var createdAt: Date = Date()

    init(name: String = "") { self.name = name }

    // MARK: - Pont vers le moteur de calcul

    var shape: ContainerShape {
        get { ContainerShape(rawValue: shapeRaw) ?? .box }
        set { shapeRaw = newValue.rawValue }
    }

    /// Dimensions au format attendu par `GaugeEngine` (longueurs en mm).
    var dims: [String: Double] {
        switch shape {
        case .box:    return ["L": dL, "W": dW, "H": dH]
        case .vcyl:   return ["D": dD, "H": dH]
        case .hcyl:   return ["D": dD, "L": dLen]
        case .custom: return [:]
        }
    }

    /// Forme composée courante, le cas échéant.
    var compositeKindValue: CompositeKind? {
        compositeKind.isEmpty ? nil : CompositeKind(rawValue: compositeKind)
    }

    /// Points de jauge fournis au moteur. Pour une forme composée, ils sont GÉNÉRÉS
    /// à partir des cotes ; sinon ce sont les points saisis (table de jauge manuelle).
    var gaugePoints: [GaugePoint] {
        if let kind = compositeKindValue {
            return CompositeShape.gaugePoints(kind: kind, dL: dL, dW: dW, dH: dH,
                                              sumpL: sumpL, sumpW: sumpW, sumpH: sumpH,
                                              shallowH: shallowH)
        }
        return (points ?? [])
            .sorted { $0.h_mm < $1.h_mm }
            .map { GaugePoint(h_mm: $0.h_mm, v_L: $0.v_L) }
    }

    /// Accès non-optionnel en lecture aux points saisis (pour l'UI ; vide pour une composée).
    var pointsList: [GaugePointModel] { points ?? [] }

    /// Borne toutes les cotes/points avant enregistrement (appelé à la fin de l'édition),
    /// via `ModelGuard` — défense partagée avec l'import.
    func sanitizeInPlace() {
        dL = ModelGuard.dim(dL); dW = ModelGuard.dim(dW); dH = ModelGuard.dim(dH)
        dD = ModelGuard.dim(dD); dLen = ModelGuard.dim(dLen)
        sumpL = ModelGuard.dim(sumpL); sumpW = ModelGuard.dim(sumpW)
        sumpH = ModelGuard.dim(sumpH); shallowH = ModelGuard.dim(shallowH)
        k = ModelGuard.k(k)
        gaugeStepL = ModelGuard.step(gaugeStepL)
        for p in (points ?? []) {
            p.h_mm = ModelGuard.pointHeight(p.h_mm)   // mêmes bornes que l'acceptation à l'import
            p.v_L = ModelGuard.pointVolume(p.v_L)
        }
    }

    /// Boîte englobante (mm) pour la visualisation des formes composées (le moteur ignore
    /// `dims` en `.custom` et utilise les points générés).
    var envelopeDims: [String: Double] {
        switch compositeKindValue {
        case .sumpBox:   return ["L": max(dL, sumpL), "W": max(dW, sumpW), "H": dH + sumpH]
        case .slopedBox: return ["L": dL, "W": dW, "H": max(dH, shallowH)]
        case .none:      return dims
        }
    }
}
