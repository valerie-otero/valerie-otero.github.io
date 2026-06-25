//
//  LiquidEditor.swift
//  Voluma
//
//  Fiche d'un liquide. Lecture seule par défaut : un liquide enregistré ne peut
//  être modifié (densité, viscosité…) sans passer en édition via « Modifier ».
//  Un nouveau liquide (créé via +) s'ouvre directement en édition.
//

import SwiftUI
import SwiftData

struct LiquidEditor: View {
    @Bindable var liquid: Liquid
    @Environment(\.locale) private var locale
    @State private var isEditing: Bool

    init(liquid: Liquid) {
        _liquid = Bindable(liquid)
        let isNew = liquid.name.isEmpty && liquid.density == 0.75
            && liquid.viscosity == 0 && liquid.note.isEmpty
        _isEditing = State(initialValue: isNew)
    }

    var body: some View {
        Form {
            if !isEditing { lockBanner }

            Section("Nom") {
                if isEditing {
                    TextField("Nom du liquide", text: $liquid.name)
                } else {
                    Text(liquid.name.isEmpty ? "Sans nom" : liquid.name).foregroundStyle(.secondary)
                }
            }

            Section {
                propertyRow("Densité", value: $liquid.density, unit: "kg/L",
                            fractionLength: 3, placeholder: "0,75")
                propertyRow("Viscosité", value: $liquid.viscosity, unit: "mPa·s",
                            fractionLength: 1, placeholder: "0")
                if isEditing {
                    ColorPicker("Couleur", selection: colorBinding, supportsOpacity: false)
                } else {
                    LabeledContent("Couleur") {
                        Circle()
                            .fill(liquid.displayColor)
                            .frame(width: 22, height: 22)
                            .overlay(Circle().stroke(.secondary.opacity(0.3)))
                    }
                }
            } header: {
                Text("Propriétés")
            } footer: {
                Text("La couleur sert à identifier le liquide (essences, gazole…) dans la coupe et les listes.")
            }

            Section {
                if isEditing {
                    TextField("Note", text: $liquid.note, axis: .vertical)
                        .lineLimit(1...4)
                } else {
                    Text(liquid.note.isEmpty ? "—" : liquid.note).foregroundStyle(.secondary)
                }
            } header: {
                Text("Note")
            } footer: {
                Text("La viscosité est indicative : elle n'entre pas dans le calcul du volume ou du poids. Seule la densité détermine le poids.")
            }
        }
        .navigationTitle(liquid.name.isEmpty ? "Nouveau liquide".localized(in: locale) : liquid.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Terminé" : "Modifier") {
                    if isEditing { liquid.sanitizeInPlace() }   // borne densité/viscosité avant verrouillage
                    withAnimation { isEditing.toggle() }
                }
                .fontWeight(isEditing ? .semibold : .regular)
            }
        }
    }

    private var colorBinding: Binding<Color> {
        Binding(get: { liquid.displayColor }, set: { liquid.colorHex = $0.hexString })
    }

    private var lockBanner: some View {
        Section {
            Label("Liquide verrouillé. Touchez « Modifier » pour changer ses propriétés.",
                  systemImage: "lock.fill")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func propertyRow(_ title: LocalizedStringKey, value: Binding<Double>,
                             unit: String, fractionLength: Int, placeholder: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            if isEditing {
                TextField(placeholder, value: value, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 90)
            } else {
                Text(value.wrappedValue.formatted(.number.precision(.fractionLength(0...fractionLength)).locale(locale)))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Text(unit).foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack { LiquidEditor(liquid: Liquid(name: "SP98", density: 0.75)) }
        .modelContainer(for: [Container.self, Liquid.self, PlanDocument.self, GaugePointModel.self],
                        inMemory: true)
}
