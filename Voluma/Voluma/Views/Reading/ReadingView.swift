//
//  ReadingView.swift
//  Voluma
//
//  Cœur fonctionnel : on choisit un récipient et un liquide, on saisit la hauteur
//  mesurée à la pige, et on lit volume / poids / pourcentage / reste / sensibilité,
//  avec une coupe 2D et un bandeau d'alerte selon le niveau.
//

import SwiftUI
import SwiftData

struct ReadingView: View {
    @Query(sort: \Container.createdAt) private var containers: [Container]
    @Query(sort: \Liquid.createdAt) private var liquids: [Liquid]

    @AppStorage("heightUnitMM") private var heightInMM = false
    @AppStorage("volumeUnit") private var volumeUnit: VolumeUnit = .liter
    @AppStorage("massUnit") private var massUnit: MassUnit = .kilogram
    @AppStorage("defaultContainerName") private var defaultContainerName = ""
    @AppStorage("defaultLiquidName") private var defaultLiquidName = ""
    @AppStorage("prefer3D") private var prefer3D = false
    @Environment(\.locale) private var locale

    @State private var vm = GaugeViewModel()

    var body: some View {
        Form {
            selectionSection

            if let container = vm.container {
                readoutSection
                crossSectionSection
                pigeSection
                Section {
                    NavigationLink {
                        GraduationTableView(container: container, liquid: vm.liquid)
                    } label: {
                        Label("Table de graduation", systemImage: "tablecells")
                    }
                }
            } else {
                ContentUnavailableView(
                    "Aucun récipient sélectionné",
                    systemImage: "drop",
                    description: Text("Choisissez un récipient pour commencer la lecture.")
                )
            }
        }
        .navigationTitle("Lecture".localized(in: locale))
        .scrollDismissesKeyboard(.interactively)
        .onAppear(perform: selectDefaults)
        .onChange(of: containers) { selectDefaults() }
        .onChange(of: liquids) { selectDefaults() }
    }

    // MARK: - Sélection récipient / liquide

    private var selectionSection: some View {
        Section {
            Picker("Récipient", selection: $vm.container) {
                Text("—").tag(Container?.none)
                ForEach(containers) { c in
                    Text(c.name.isEmpty ? "Sans nom" : c.name).tag(c as Container?)
                }
            }
            Picker("Liquide", selection: $vm.liquid) {
                Text("—").tag(Liquid?.none)
                ForEach(liquids) { l in
                    Text(l.name.isEmpty ? "Sans nom" : l.name).tag(l as Liquid?)
                }
            }
        }
    }

    // MARK: - Affichage principal

    private var readoutSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    // Volume (nombre + unité) : sur une seule ligne, réduit plutôt que coupé.
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(volumeUnit.fromLiters(vm.volumeL),
                             format: .number.precision(.fractionLength(volumeUnit.fractionDigits)))
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .contentTransition(.numericText(value: vm.volumeL))
                        Text(verbatim: volumeUnit.symbol)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    // Liquide (avec sa pastille de couleur), séparé du nombre.
                    if let liquid = vm.liquid, !liquid.name.isEmpty {
                        HStack(spacing: 6) {
                            Circle().fill(liquid.displayColor).frame(width: 9, height: 9)
                            Text(liquid.name)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                    }
                }

                fillBar

                HStack(alignment: .top, spacing: 14) {
                    metric("Poids", massString, "scalemass")
                    metric("Remplissage", percentString, "gauge.with.dots.needle.bottom.50percent")
                    metric("Reste", remainingString, "arrow.up.to.line")
                }

                Text("Précision : ± 1 mm = ± \(sensitivityVolumeString) à ce niveau")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                alertBanner
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular, in: .rect(cornerRadius: 20))
            .animation(.snappy(duration: 0.35), value: vm.volumeL)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(readoutAccessibilityLabel)
            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
            .listRowBackground(Color.clear)
        }
    }

    /// Barre de remplissage fine, teintée à la couleur du liquide : niveau lisible d'un coup d'œil.
    private var fillBar: some View {
        let fraction = max(0, min(1, vm.fillPercent / 100))
        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(.quaternary)
                Capsule()
                    .fill(liquidColor.gradient)
                    .frame(width: geo.size.width * fraction)
            }
        }
        .frame(height: 8)
        .accessibilityHidden(true)
    }

    private var readoutAccessibilityLabel: String {
        String(localized: "Volume \(volumeString), poids \(massString), remplissage \(percentString), reste \(remainingString)")
    }

    private func metric(_ title: LocalizedStringKey, _ value: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(.tint)
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Text(value)
                .font(.callout.weight(.semibold))
                .monospacedDigit()
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder private var alertBanner: some View {
        switch vm.fillStatus {
        case .low:
            banner("Niveau bas", "exclamationmark.triangle.fill", .orange)
        case .almostFull:
            banner("Niveau quasi plein", "exclamationmark.triangle.fill", .orange)
        case .full:
            banner("Récipient plein", "checkmark.seal.fill", .green)
        case .empty, .normal:
            EmptyView()
        }
    }

    private func banner(_ text: LocalizedStringKey, _ icon: String, _ color: Color) -> some View {
        Label(text, systemImage: icon)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(color)
            .padding(.horizontal, 12).padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color.opacity(0.12), in: .rect(cornerRadius: 10))
    }

    // MARK: - Coupe 2D / 3D

    private var crossSectionSection: some View {
        Section("Coupe") {
            Picker("Vue", selection: $prefer3D) {
                Text("2D").tag(false)
                Text("3D").tag(true)
            }
            .pickerStyle(.segmented)

            Group {
                if prefer3D {
                    // Géométrie 3D fidèle à la forme réelle (fond incliné, puisard, forme libre).
                    FillView3D(kind: vm.container?.solid3D() ?? .box(l: 1, w: 1, h: 1),
                               heightFraction: vm.heightFraction, liquidColor: UIColor(liquidColor))
                } else {
                    FillView2D(shape: vm.shape, compositeKind: vm.container?.compositeKindValue,
                               heightFraction: vm.heightFraction, liquidColor: liquidColor)
                }
            }
            .frame(height: 220)
            .frame(maxWidth: .infinity)
            .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        }
    }

    // MARK: - Pige

    private var pigeSection: some View {
        Section {
            // Version cm : hauteur mesurée à la pige (curseur + champ).
            if heightInMM {
                SliderFieldRow(title: "Hauteur (pige)", value: $vm.height_mm,
                               range: heightRangeMM, step: 1, unit: "mm", fractionLength: 0)
            } else {
                SliderFieldRow(title: "Hauteur (pige)", value: $vm.height_cm,
                               range: heightRangeCm, step: 0.1, unit: "cm")
            }
            // Version litres : volume connu (ticket) → la hauteur se calcule.
            HStack {
                Text("Volume connu")
                Spacer()
                TextField(volumeUnit.symbol, value: volumeBinding,
                          format: .number.precision(.fractionLength(0...volumeUnit.fractionDigits)))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                Text(volumeUnit.symbol).foregroundStyle(.secondary)
            }
            LabeledContent("Hauteur pleine") {
                Text(fullHeightString)
            }
        } header: {
            Text("Mesure")
        } footer: {
            Text("Renseignez la hauteur mesurée à la pige (version cm) ou un volume connu — par exemple un ticket de plein (version litres) : l'autre se calcule. ⚠️ Mesurez avec soin : un relevé imprécis fausse le résultat ; vous êtes responsable de l'exactitude des mesures.")
        }
    }

    /// Lien bidirectionnel hauteur ↔ volume : éditer les litres repositionne la hauteur.
    private var volumeBinding: Binding<Double> {
        Binding(
            get: { volumeUnit.fromLiters(vm.volumeL) },
            set: { vm.setHeight(forVolumeL: min(max(volumeUnit.toLiters($0), 0), vm.fullVolumeL)) }
        )
    }

    private var heightRangeMM: ClosedRange<Double> {
        let maxMM = vm.fullHeight_mm
        return 0...(maxMM > 0 ? maxMM : 1)
    }

    /// Couleur d'identification du liquide courant (bleu par défaut).
    private var liquidColor: Color { vm.liquid?.displayColor ?? .blue }

    // MARK: - Logique

    private var heightRangeCm: ClosedRange<Double> {
        let maxCm = vm.fullHeight_mm / 10
        return 0...(maxCm > 0 ? maxCm : 1)
    }

    private func selectDefaults() {
        if vm.container == nil {
            vm.container = containers.first { $0.name == defaultContainerName } ?? containers.first
            vm.height_mm = vm.fullHeight_mm / 2   // lecture initiale parlante
        }
        if vm.liquid == nil {
            vm.liquid = liquids.first { $0.name == defaultLiquidName } ?? liquids.first
        }
    }

    // MARK: - Formatage

    /// « — » si la valeur n'est pas finie/positive (donnée corrompue), sinon la valeur formatée.
    private func guarded(_ v: Double, _ make: (Double) -> String) -> String {
        (v.isFinite && v >= 0) ? make(v) : "—"
    }

    private var volumeString: String { guarded(vm.volumeL) { volumeUnit.string($0, locale: locale) } }
    private var massString: String { guarded(vm.massKg) { massUnit.string($0, locale: locale) } }
    private var percentString: String {
        guarded(vm.fillPercent) { $0.formatted(.number.precision(.fractionLength(0)).locale(locale)) + " %" }
    }
    private var remainingString: String { guarded(vm.remainingL) { volumeUnit.string($0, locale: locale) } }
    private var sensitivityVolumeString: String {
        volumeUnit.string(vm.sensitivityLPerMm, fraction: volumeUnit == .liter ? 2 : 4, locale: locale)
    }

    private var fullHeightString: String {
        if heightInMM {
            return vm.fullHeight_mm.formatted(.number.precision(.fractionLength(0)).locale(locale)) + " mm"
        }
        return (vm.fullHeight_mm / 10).formatted(.number.precision(.fractionLength(1)).locale(locale)) + " cm"
    }
}

#Preview {
    NavigationStack {
        ReadingView()
    }
    .modelContainer(for: [Container.self, Liquid.self, PlanDocument.self, GaugePointModel.self],
                    inMemory: true)
}
