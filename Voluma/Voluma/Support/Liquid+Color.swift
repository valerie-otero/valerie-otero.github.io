//
//  Liquid+Color.swift
//  Voluma
//
//  Couleur d'identification d'un liquide (stockée en hexadécimal sur le modèle),
//  reprise dans la coupe 2D/3D et la liste pour repérer les essences d'un coup d'œil.
//

import SwiftUI

extension Liquid {
    /// Couleur d'affichage du liquide (bleu par défaut si non définie).
    nonisolated var displayColor: Color {
        Color(hex: colorHex) ?? .blue
    }
}

extension Color {
    /// Construit une couleur depuis « #RRGGBB » (ou « RRGGBB »). `nil` si invalide.
    nonisolated init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let value = UInt32(s, radix: 16) else { return nil }
        self = Color(
            red:   Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue:  Double(value & 0xFF) / 255
        )
    }

    /// Représentation « #RRGGBB » de la couleur.
    var hexString: String {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        let clamp: (CGFloat) -> Int = { Int((max(0, min(1, $0)) * 255).rounded()) }
        return String(format: "#%02X%02X%02X", clamp(r), clamp(g), clamp(b))
    }
}
