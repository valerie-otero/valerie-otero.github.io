//
//  SliderFieldRow.swift
//  Voluma
//
//  Composant réutilisable : un curseur et un champ texte synchronisés sur une
//  même valeur, avec libellé et unité. Utilisé pour la pige et les dimensions.
//

import SwiftUI

struct SliderFieldRow: View {
    let title: LocalizedStringKey
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 0.1
    var unit: String = ""
    var fractionLength: Int = 1

    @FocusState private var focused: Bool

    private var format: FloatingPointFormatStyle<Double> {
        .number.precision(.fractionLength(0...fractionLength))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                TextField(title, value: $value, format: format)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                    .focused($focused)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 28, alignment: .leading)
                }
            }
            Slider(value: $value, in: range, step: step)
        }
        .toolbar {
            if focused {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("OK") { focused = false }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var v = 35.6
    return Form {
        SliderFieldRow(title: "Hauteur", value: $v, range: 0...71.2, unit: "cm")
    }
}
