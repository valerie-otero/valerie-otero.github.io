//
//  PigeExport.swift
//  Voluma
//
//  Export de la table de graduation / pige : CSV (tableur) et PDF (impression),
//  partagés via la feuille système (Enregistrer dans Fichiers, Imprimer, AirDrop…).
//

import SwiftUI
import UIKit

enum PigeExport {

    /// CSV (séparateur « ; », décimales « . » pour rester sans ambiguïté).
    static func csv(rows: [GraduationRow], containerName: String, liquid: Liquid?,
                    volumeUnit: VolumeUnit, massUnit: MassUnit) -> String {
        let f: (Double, Int) -> String = { value, digits in String(format: "%.\(digits)f", value) }
        let vdig = volumeUnit.fractionDigits
        var lines: [String] = []
        lines.append("# Voluma — table de pige")
        lines.append("# Récipient: \(containerName)")
        if let liquid { lines.append("# Liquide: \(liquid.name) (\(f(liquid.density, 3)) kg/L)") }
        lines.append("Volume (\(volumeUnit.symbol));Poids (\(massUnit.symbol));Hauteur exacte (mm);Repère (cm);Écart (\(volumeUnit.symbol))")
        for r in rows {
            let poids = liquid == nil ? "" : f(massUnit.fromKg(r.massKg), 1)
            lines.append([f(volumeUnit.fromLiters(r.volumeL), vdig), poids, f(r.exactHeight_mm, 0),
                          f(r.roundedHeight_cm, 0), f(volumeUnit.fromLiters(r.deltaL), vdig)].joined(separator: ";"))
        }
        return lines.joined(separator: "\n")
    }

    static func writeText(_ text: String, fileName: String) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do { try Data(text.utf8).write(to: url, options: .atomic); return url } catch { return nil }
    }

    static let a4 = CGSize(width: 595.2, height: 841.8)   // A4 @ 72 dpi

    /// PDF **A4** rendu PAGE PAR PAGE : chaque page est une vue distincte (typiquement une
    /// tranche de lignes), rendue séparément → la mémoire de pointe reste bornée à une page,
    /// même pour une cuve à barème très long. `pageView(i)` doit tenir sur une page A4.
    @MainActor
    static func pdfA4Paged<Content: View>(pageCount: Int, fileName: String,
                                          @ViewBuilder pageView: (Int) -> Content) -> URL? {
        guard pageCount > 0 else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: a4))
        do {
            try pdfRenderer.writePDF(to: url) { context in
                for index in 0..<pageCount {
                    let renderer = ImageRenderer(content:
                        pageView(index).frame(width: a4.width, alignment: .topLeading).background(Color.white))
                    renderer.scale = 3
                    context.beginPage()
                    UIColor.white.setFill()
                    UIRectFill(CGRect(origin: .zero, size: a4))
                    if let image = renderer.uiImage {
                        // Filet de sécurité : si une page dépasse la hauteur A4, on la réduit
                        // uniformément plutôt que de la rogner.
                        let h = image.size.height
                        let scale = h > a4.height ? a4.height / h : 1
                        image.draw(in: CGRect(x: 0, y: 0, width: a4.width * scale, height: h * scale))
                    }
                }
            }
            return url
        } catch {
            return nil
        }
    }

    /// Rend une vue SwiftUI en PDF **A4** (210 × 297 mm), avec pagination verticale
    /// automatique si le contenu dépasse une page.
    @MainActor
    static func pdfA4(from view: some View, fileName: String) -> URL? {
        let page = CGSize(width: 595.2, height: 841.8)   // A4 @ 72 dpi

        let renderer = ImageRenderer(content:
            view.frame(width: page.width, alignment: .topLeading).background(Color.white))
        renderer.scale = 3   // net à l'impression
        guard let image = renderer.uiImage else { return nil }

        let imageHeight = image.size.height
        let pageCount = max(1, Int(ceil(imageHeight / page.height)))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: page))
        do {
            try pdfRenderer.writePDF(to: url) { context in
                for pageIndex in 0..<pageCount {
                    context.beginPage()
                    UIColor.white.setFill()
                    UIRectFill(CGRect(origin: .zero, size: page))
                    image.draw(in: CGRect(x: 0, y: -CGFloat(pageIndex) * page.height,
                                          width: page.width, height: imageHeight))
                }
            }
            return url
        } catch {
            return nil
        }
    }
}

/// Feuille de partage système.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
