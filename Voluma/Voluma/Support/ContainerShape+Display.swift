//
//  ContainerShape+Display.swift
//  Voluma
//
//  Libellés et icônes des formes pour l'UI (le moteur reste sans dépendance UI).
//

import SwiftUI

extension ContainerShape {
    var title: LocalizedStringKey {
        switch self {
        case .box:    "Boîte"
        case .vcyl:   "Cylindre vertical"
        case .hcyl:   "Cylindre horizontal"
        case .custom: "Forme libre"
        }
    }

    var shortTitle: LocalizedStringKey {
        switch self {
        case .box:    "Boîte"
        case .vcyl:   "Vertical"
        case .hcyl:   "Horizontal"
        case .custom: "Libre"
        }
    }

    var symbol: String {
        switch self {
        case .box:    "shippingbox"
        case .vcyl:   "cylinder"
        case .hcyl:   "cylinder.split.1x2"
        case .custom: "scribble.variable"
        }
    }

    /// Description courte : ce que c'est + les dimensions demandées.
    var hint: LocalizedStringKey {
        switch self {
        case .box:    "Bac ou cuve rectangulaire — longueur × largeur × hauteur."
        case .vcyl:   "Fût ou bidon debout — diamètre × hauteur."
        case .hcyl:   "Cuve/citerne couchée — diamètre × longueur."
        case .custom: "Forme quelconque, sans dimensions : on la définit par des mesures hauteur → volume."
        }
    }
}
