//
//  MeasurementUnits.swift
//  Voluma
//
//  Unités d'affichage/saisie pour le volume et la masse. PUREMENT présentation :
//  le moteur et les données restent en litres (L) et kilogrammes (kg). Facteurs exacts.
//

import SwiftUI

nonisolated enum VolumeUnit: String, CaseIterable, Identifiable {
    case liter, gallonUS, gallonImp
    var id: String { rawValue }

    /// Litres par unité (définitions exactes).
    private var litersPerUnit: Double {
        switch self {
        case .liter:     1
        case .gallonUS:  3.785411784
        case .gallonImp: 4.54609
        }
    }

    var symbol: String {
        switch self {
        case .liter:     "L"
        case .gallonUS:  "gal US"
        case .gallonImp: "gal imp"
        }
    }

    var displayName: LocalizedStringKey {
        switch self {
        case .liter:     "Litres (L)"
        case .gallonUS:  "Gallons US"
        case .gallonImp: "Gallons impériaux"
        }
    }

    /// Décimales d'affichage adaptées (un gallon « vaut » plus qu'un litre).
    var fractionDigits: Int { self == .liter ? 1 : 2 }

    func fromLiters(_ liters: Double) -> Double { liters / litersPerUnit }
    func toLiters(_ value: Double) -> Double { value * litersPerUnit }

    /// Valeur formatée avec symbole, ex. « 175,0 L » ou « 46,23 gal US ».
    /// `locale` = langue choisie dans l'app (séparateur décimal cohérent FR/EN).
    func string(_ liters: Double, fraction: Int? = nil, locale: Locale = .autoupdatingCurrent) -> String {
        fromLiters(liters)
            .formatted(.number.precision(.fractionLength(0...(fraction ?? fractionDigits))).locale(locale))
            + " " + symbol
    }
}

nonisolated enum MassUnit: String, CaseIterable, Identifiable {
    case kilogram, pound
    var id: String { rawValue }

    /// Kilogrammes par unité (définition exacte de la livre).
    private var kgPerUnit: Double {
        switch self {
        case .kilogram: 1
        case .pound:    0.45359237
        }
    }

    var symbol: String {
        switch self {
        case .kilogram: "kg"
        case .pound:    "lb"
        }
    }

    var displayName: LocalizedStringKey {
        switch self {
        case .kilogram: "Kilogrammes (kg)"
        case .pound:    "Livres (lb)"
        }
    }

    func fromKg(_ kg: Double) -> Double { kg / kgPerUnit }
    func toKg(_ value: Double) -> Double { value * kgPerUnit }

    func string(_ kg: Double, fraction: Int = 1, locale: Locale = .autoupdatingCurrent) -> String {
        fromKg(kg).formatted(.number.precision(.fractionLength(0...fraction)).locale(locale)) + " " + symbol
    }
}
