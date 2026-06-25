//
//  FillView2D.swift
//  Voluma
//
//  Coupe 2D du récipient remplie au niveau réel (fraction de hauteur).
//  Cercle pour le cylindre horizontal (vue en bout), rectangle arrondi sinon.
//

import SwiftUI

struct FillView2D: View {
    let shape: ContainerShape
    /// Forme composée (puisard, fond incliné) à dessiner, le cas échéant.
    var compositeKind: CompositeKind? = nil
    /// Fraction de hauteur remplie [0, 1] (niveau physique, pas le volume).
    let heightFraction: Double
    var liquidColor: Color = .blue

    var body: some View {
        Canvas { ctx, size in
            let inset: CGFloat = 10
            let rect = CGRect(x: inset, y: inset,
                              width: size.width - 2 * inset,
                              height: size.height - 2 * inset)
            let f = CGFloat(max(0, min(1, heightFraction)))

            let containerPath: Path
            let levelY: CGFloat

            if let kind = compositeKind {
                containerPath = Self.compositePath(kind, in: rect)
                let b = containerPath.boundingRect
                levelY = b.maxY - f * b.height
            } else {
                switch shape {
                case .hcyl:
                    let d = min(rect.width, rect.height)
                    let box = CGRect(x: rect.midX - d / 2, y: rect.midY - d / 2, width: d, height: d)
                    containerPath = Path(ellipseIn: box)
                    levelY = box.maxY - f * d
                default:
                    containerPath = Path(roundedRect: rect, cornerRadius: 18)
                    levelY = rect.maxY - f * rect.height
                }
            }

            let bounds = containerPath.boundingRect
            let waterRect = CGRect(x: bounds.minX, y: levelY,
                                   width: bounds.width, height: bounds.maxY - levelY)

            // Liquide (dégradé) découpé par la silhouette du récipient
            ctx.drawLayer { layer in
                layer.clip(to: containerPath)
                layer.fill(
                    Path(waterRect),
                    with: .linearGradient(
                        Gradient(colors: [liquidColor.opacity(0.55), liquidColor.opacity(0.9)]),
                        startPoint: CGPoint(x: bounds.midX, y: levelY),
                        endPoint: CGPoint(x: bounds.midX, y: bounds.maxY)
                    )
                )
                // Ligne de surface
                if f > 0 && f < 1 {
                    var surface = Path()
                    surface.move(to: CGPoint(x: bounds.minX, y: levelY))
                    surface.addLine(to: CGPoint(x: bounds.maxX, y: levelY))
                    layer.stroke(surface, with: .color(.white.opacity(0.7)), lineWidth: 2)
                }
            }

            // Contour du récipient
            ctx.stroke(containerPath, with: .color(.secondary.opacity(0.7)), lineWidth: 2.5)
        }
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
        .accessibilityElement()
        .accessibilityLabel("Coupe du récipient")
        .accessibilityValue(Text("\(Int((heightFraction * 100).rounded())) % de la hauteur"))
    }

    /// Silhouette schématique d'une forme composée (proportions indicatives).
    private static func compositePath(_ kind: CompositeKind, in rect: CGRect) -> Path {
        var p = Path()
        switch kind {
        case .sumpBox:
            // Boîte avec un puisard en creux au fond, centré.
            let mainH = rect.height * 0.70
            let bodyBottom = rect.minY + mainH
            let sumpW = rect.width * 0.40
            let sumpL = rect.midX - sumpW / 2, sumpR = rect.midX + sumpW / 2
            p.move(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: bodyBottom))
            p.addLine(to: CGPoint(x: sumpR, y: bodyBottom))
            p.addLine(to: CGPoint(x: sumpR, y: rect.maxY))
            p.addLine(to: CGPoint(x: sumpL, y: rect.maxY))
            p.addLine(to: CGPoint(x: sumpL, y: bodyBottom))
            p.addLine(to: CGPoint(x: rect.minX, y: bodyBottom))
            p.closeSubpath()
        case .slopedBox:
            // Fond incliné : côté gauche profond, côté droit faible.
            p.move(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - rect.height * 0.40))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
        }
        return p
    }
}

#Preview {
    HStack {
        FillView2D(shape: .hcyl, heightFraction: 0.4)
        FillView2D(shape: .box, heightFraction: 0.65, liquidColor: .green)
    }
    .frame(height: 180)
    .padding()
}
