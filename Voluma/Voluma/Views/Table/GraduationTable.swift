//
//  GraduationTable.swift
//  Voluma
//
//  Barème de jaugeage : pour des repères de volume, la hauteur exacte (mm),
//  le repère pratique arrondi au cm et l'écart de volume induit. Le poids
//  dépend du liquide ; le reste est purement géométrique.
//

import SwiftUI

struct GraduationTableView: View {
    let container: Container
    let liquid: Liquid?

    @AppStorage("appLanguage") private var appLanguage: AppLanguage = .deviceDefault
    @AppStorage("volumeUnit") private var volumeUnit: VolumeUnit = .liter
    @AppStorage("massUnit") private var massUnit: MassUnit = .kilogram
    @State private var vm: GaugeViewModel
    @State private var shareItem: ShareItem?
    @State private var isExporting = false

    /// Locale de la langue choisie dans l'app (séparateur décimal cohérent FR/EN).
    private var loc: Locale { appLanguage.resolvedLocale }

    struct ShareItem: Identifiable { let id = UUID(); let url: URL }

    init(container: Container, liquid: Liquid?) {
        self.container = container
        self.liquid = liquid
        _vm = State(initialValue: GaugeViewModel(container: container, liquid: liquid))
    }

    /// Pas effectif en litres (pour le moteur) : enregistré sur le récipient, sinon défaut.
    private var effectiveStepL: Double {
        container.gaugeStepL > 0 ? container.gaugeStepL : volumeUnit.toLiters(stepChoices[1])
    }
    /// Pas effectif dans l'unité d'affichage (pour le sélecteur).
    private var effectiveStepUnit: Double {
        container.gaugeStepL > 0 ? volumeUnit.fromLiters(container.gaugeStepL) : stepChoices[1]
    }
    private var rows: [GraduationRow] { vm.graduationTable(stepL: effectiveStepL) }

    /// Pas proposés dans l'unité d'affichage, adaptés à la capacité.
    private var stepChoices: [Double] {
        switch volumeUnit.fromLiters(vm.fullVolumeL) {
        case ..<30:  return [1, 2, 5]
        case ..<120: return [5, 10, 25]
        case ..<600: return [10, 25, 50]
        default:     return [25, 50, 100]
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                infoCard
                stepPicker
                tableCard
                exportCard
                disclaimer
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Table de graduation".localized(in: appLanguage.resolvedLocale))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $shareItem) { item in ShareSheet(items: [item.url]) }
        .overlay {
            if isExporting {
                ProgressView("Génération du PDF…")
                    .padding(24)
                    .background(.regularMaterial, in: .rect(cornerRadius: 14))
                    .shadow(radius: 8)
            }
        }
    }

    // MARK: - En-tête

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(container.name.isEmpty ? "Récipient" : container.name,
                      systemImage: container.shape.symbol)
                    .font(.headline)
                Spacer()
                Text(volumeUnit.string(vm.fullVolumeL, locale: loc))
                    .font(.headline)
                    .foregroundStyle(.tint)
            }
            if let liquid {
                let liquidName = liquid.name.isEmpty ? String(localized: "ce liquide") : liquid.name
                Text("Poids calculé pour \(liquidName) · \(liquid.density.formatted(.number.precision(.fractionLength(3)).locale(loc))) kg/L")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Aucun liquide sélectionné — le poids n'est pas calculé.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
    }

    private var stepPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Repères tous les").font(.caption).foregroundStyle(.secondary)
            Picker("Repères tous les",
                   selection: Binding(get: { effectiveStepUnit },
                                      set: { container.gaugeStepL = volumeUnit.toLiters($0) })) {
                ForEach(stepChoices, id: \.self) { step in
                    Text(verbatim: "\(Int(step)) \(volumeUnit.symbol)").tag(step)
                }
            }
            .pickerStyle(.segmented)
            Label("Pas enregistré avec le récipient.", systemImage: "checkmark.circle")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Export (génération de pige)

    private var exportCard: some View {
        HStack(spacing: 12) {
            Button(action: exportCSV) {
                Label("CSV", systemImage: "tablecells").frame(maxWidth: .infinity)
            }
            Button(action: exportPDF) {
                Label("PDF", systemImage: "doc.richtext").frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isExporting)
    }

    private func exportCSV() {
        let csv = PigeExport.csv(rows: rows, containerName: container.name, liquid: liquid,
                                 volumeUnit: volumeUnit, massUnit: massUnit)
        if let url = PigeExport.writeText(csv, fileName: fileBaseName + ".csv") {
            shareItem = ShareItem(url: url)
        }
    }

    private func exportPDF() {
        guard !isExporting else { return }   // pas de rendu concurrent
        isExporting = true
        Task { @MainActor in
            await Task.yield()                 // laisse le spinner s'afficher avant le rendu synchrone
            let url = buildPagedPDF()
            isExporting = false
            if let url { shareItem = ShareItem(url: url) }
        }
    }

    /// Découpe le barème en pages A4 (≈ 24 lignes/page, marge de sécurité pour le titre,
    /// l'en-tête, la note et le numéro de page) rendues séparément : mémoire bornée.
    private func buildPagedPDF() -> URL? {
        let perPage = 24
        let allRows = rows
        let pages: [[GraduationRow]] = stride(from: 0, to: allRows.count, by: perPage).map {
            Array(allRows[$0..<min($0 + perPage, allRows.count)])
        }
        let pageCount = max(1, pages.count)
        let shapeTitle = container.compositeKindValue?.title ?? container.shape.title
        return PigeExport.pdfA4Paged(pageCount: pageCount, fileName: fileBaseName + ".pdf") { index in
            PigePrintView(rows: index < pages.count ? pages[index] : [],
                          containerName: container.name,
                          shapeTitle: shapeTitle,
                          liquid: liquid,
                          fullVolumeL: vm.fullVolumeL,
                          fullHeight_mm: vm.fullHeight_mm,
                          volumeUnit: volumeUnit,
                          massUnit: massUnit,
                          locale: loc,
                          pageLabel: pageCount > 1 ? String(localized: "Page \(index + 1)/\(pageCount)") : "")
                .environment(\.locale, loc)
        }
    }

    private var fileBaseName: String {
        let raw = container.name.isEmpty ? "pige" : container.name
        let safe = raw.replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: " ", with: "_")
        return "Voluma-\(safe)"
    }

    // MARK: - Tableau

    private var tableCard: some View {
        Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 0) {
            GridRow {
                headerCell(LocalizedStringKey(volumeUnit.symbol))
                headerCell(LocalizedStringKey(massUnit.symbol))
                headerCell("H. exacte")
                headerCell("Repère")
                headerCell("Écart")
            }
            .padding(.bottom, 6)
            Divider().gridCellColumns(5)
            ForEach(rows) { row in
                GridRow {
                    Text(volumeUnit.fromLiters(row.volumeL)
                        .formatted(.number.precision(.fractionLength(volumeUnit.fractionDigits)).locale(loc)))
                        .fontWeight(row.isRoundMark ? .bold : .regular)
                        .foregroundStyle(row.isRoundMark ? Color.accentColor : Color.primary)
                    Text(liquid == nil ? "—" : massUnit.fromKg(row.massKg)
                        .formatted(.number.precision(.fractionLength(1)).locale(loc)))
                    Text("\(Int(row.exactHeight_mm.rounded())) mm")
                    Text("\(Int(row.roundedHeight_cm)) cm")
                    Text(volumeUnit.fromLiters(row.deltaL)
                        .formatted(.number.precision(.fractionLength(volumeUnit.fractionDigits))
                            .sign(strategy: .always(includingZero: false)).locale(loc)))
                        .foregroundStyle(abs(row.deltaL) < 0.05 ? Color.secondary : Color.orange)
                }
                .font(.footnote.monospacedDigit())
                .padding(.vertical, 6)
                .foregroundStyle(row.isRoundMark ? Color.primary : Color.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
    }

    private func headerCell(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.caption2)
            .foregroundStyle(.secondary)
    }

    private var disclaimer: some View {
        Text("« H. exacte » : hauteur théorique pour le volume indiqué. « Repère » : hauteur arrondie au cm pour une lecture à la pige ; « Écart » : volume induit par cet arrondi. Les repères majeurs sont en gras et en couleur.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let c = Container(name: "Cuve atelier")
    c.shape = .hcyl; c.dD = 712; c.dLen = 879
    return NavigationStack {
        GraduationTableView(container: c, liquid: Liquid(name: "SP98", density: 0.75))
    }
}
