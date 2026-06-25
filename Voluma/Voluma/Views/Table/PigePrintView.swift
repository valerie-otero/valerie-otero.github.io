//
//  PigePrintView.swift
//  Voluma
//
//  Mise en page imprimable (PDF) de la table de pige : noir sur blanc, largeur fixe.
//

import SwiftUI

struct PigePrintView: View {
    let rows: [GraduationRow]
    let containerName: String
    let shapeTitle: LocalizedStringKey
    let liquid: Liquid?
    let fullVolumeL: Double
    let fullHeight_mm: Double
    var volumeUnit: VolumeUnit = .liter
    var massUnit: MassUnit = .kilogram
    var locale: Locale = .autoupdatingCurrent
    var pageLabel: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Table de pige").font(.system(size: 22, weight: .bold))

            VStack(alignment: .leading, spacing: 2) {
                Text(containerName.isEmpty ? "Récipient" : containerName)
                    .font(.system(size: 15, weight: .semibold))
                Text(shapeTitle).font(.system(size: 12))
                Group {
                    let cap = "\(number(volumeUnit.fromLiters(fullVolumeL), volumeUnit.fractionDigits)) \(volumeUnit.symbol)"
                    let h = "\(number(fullHeight_mm / 10, 1)) cm"
                    if let liquid {
                        Text("Capacité \(cap) · hauteur pleine \(h) · \(liquid.name) \(number(liquid.density, 3)) kg/L")
                    } else {
                        Text("Capacité \(cap) · hauteur pleine \(h)")
                    }
                }
                .font(.system(size: 11))
            }

            Divider()

            Grid(alignment: .trailing, horizontalSpacing: 22, verticalSpacing: 6) {
                GridRow {
                    head(LocalizedStringKey(volumeUnit.symbol)); head(LocalizedStringKey(massUnit.symbol))
                    head("H. exacte"); head("Repère"); head("Écart")
                }
                Divider().gridCellColumns(5)
                ForEach(rows) { r in
                    GridRow {
                        Text(number(volumeUnit.fromLiters(r.volumeL), volumeUnit.fractionDigits))
                            .fontWeight(r.isRoundMark ? .bold : .regular)
                        Text(liquid == nil ? "—" : number(massUnit.fromKg(r.massKg), 1))
                        Text("\(Int(r.exactHeight_mm.rounded())) mm")
                        Text("\(Int(r.roundedHeight_cm)) cm")
                        Text(number(volumeUnit.fromLiters(r.deltaL), volumeUnit.fractionDigits, signed: true))
                    }
                    .font(.system(size: 12).monospacedDigit())
                }
            }

            Divider()

            Text("« H. exacte » : hauteur théorique pour graver la pige. « Repère » : hauteur arrondie au cm ; « Écart » : volume induit par l'arrondi. Outil d'aide à la lecture, sans valeur métrologique : une mesure imprécise fausse le résultat ; l'utilisateur est responsable de l'exactitude des mesures.")
                .font(.system(size: 9))

            if !pageLabel.isEmpty {
                Text(pageLabel).font(.system(size: 9)).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .foregroundStyle(.black)
        .padding(40)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .environment(\.colorScheme, .light)
    }

    private func head(_ key: LocalizedStringKey) -> some View {
        Text(key).font(.system(size: 10, weight: .semibold)).foregroundStyle(.secondary)
    }

    private func number(_ value: Double, _ digits: Int, signed: Bool = false) -> String {
        let s = value.formatted(.number.precision(.fractionLength(digits)).locale(locale))
        return signed && value >= 0 ? "+\(s)" : s
    }
}
