//
//  ContainerEditor.swift
//  Voluma
//
//  Fiche d'un récipient. Lecture seule par défaut : un récipient enregistré ne peut
//  être modifié (dimensions, forme, points, calibrage, plan) ni remis à zéro sans
//  passer explicitement en mode édition via « Modifier ». Un nouveau récipient (créé
//  via +) s'ouvre directement en édition.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContainerEditor: View {
    @Bindable var container: Container
    @Environment(\.modelContext) private var modelContext
    @Environment(\.locale) private var locale
    @AppStorage("volumeUnit") private var volumeUnit: VolumeUnit = .liter

    @State private var isEditing: Bool

    @State private var calHeight_mm: Double = 0
    @State private var calKnownVolume_L: Double = 0
    @State private var calMessage: CalibrationMessage?

    @State private var showPlanImporter = false
    @State private var showPlanPreview = false
    @State private var planError: String?

    init(container: Container) {
        _container = Bindable(container)
        // Un récipient vierge (créé via +) s'ouvre en édition ; un enregistré, verrouillé.
        let isNew = container.name.isEmpty
            && container.dL == 0 && container.dW == 0 && container.dH == 0
            && container.dD == 0 && container.dLen == 0 && container.pointsList.isEmpty
        _isEditing = State(initialValue: isNew)
    }

    var body: some View {
        Form {
            if !isEditing { lockBanner }

            nameSection
            shapeSection
            dimensionsSection

            if container.shape == .custom && container.compositeKind.isEmpty {
                gaugePointsSection
            }
            if container.shape != .custom {
                if isEditing { calibrationSection } else { calibrationReadOnly }
            }

            previewSection
            planSection
        }
        .navigationTitle(container.name.isEmpty ? "Nouveau récipient".localized(in: locale) : container.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Terminé" : "Modifier") {
                    if isEditing { container.sanitizeInPlace() }   // borne les cotes avant verrouillage
                    withAnimation { isEditing.toggle() }
                }
                .fontWeight(isEditing ? .semibold : .regular)
            }
        }
    }

    private var lockBanner: some View {
        Section {
            Label("Récipient verrouillé. Touchez « Modifier » pour changer ses dimensions, sa forme ou son calibrage.",
                  systemImage: "lock.fill")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Nom & forme

    private var nameSection: some View {
        Section("Nom") {
            if isEditing {
                TextField("Nom du récipient", text: $container.name)
            } else {
                Text(container.name.isEmpty ? "Sans nom" : container.name)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var shapeSection: some View {
        Section {
            if isEditing {
                ForEach(ShapeChoice.allCases, id: \.self) { choice in
                    Button {
                        withAnimation { choice.apply(to: container) }
                    } label: {
                        shapeRow(choice, selected: ShapeChoice.from(container) == choice)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                shapeRow(ShapeChoice.from(container), selected: false)
            }
        } header: {
            Text("Forme")
        } footer: {
            if isEditing {
                Text("Formes régulières = calculées d'après les cotes. Formes composées (puisard, fond incliné) = calculées aussi. Forme libre = définie par vos mesures.")
            }
        }
    }

    private func shapeRow(_ choice: ShapeChoice, selected: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: choice.symbol)
                .font(.title3)
                .foregroundStyle(selected ? Color.accentColor : Color.secondary)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(choice.title).foregroundStyle(.primary)
                Text(choice.hint).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if selected {
                Image(systemName: "checkmark")
                    .fontWeight(.semibold)
                    .foregroundStyle(.tint)
            }
        }
        .contentShape(Rectangle())
    }

    // MARK: - Dimensions

    @ViewBuilder private var dimensionsSection: some View {
        switch ShapeChoice.from(container) {
        case .box:
            Section("Dimensions (mm)") {
                modelDim("Longueur (L)", $container.dL)
                modelDim("Largeur (W)", $container.dW)
                modelDim("Hauteur (H)", $container.dH)
            }
        case .vcyl:
            Section("Dimensions (mm)") {
                modelDim("Diamètre (D)", $container.dD)
                modelDim("Hauteur (H)", $container.dH)
            }
        case .hcyl:
            Section("Dimensions (mm)") {
                modelDim("Diamètre (D)", $container.dD)
                modelDim("Longueur (L)", $container.dLen)
            }
        case .sumpBox:
            Section("Cuve principale (mm)") {
                modelDim("Longueur (L)", $container.dL)
                modelDim("Largeur (W)", $container.dW)
                modelDim("Hauteur (H)", $container.dH)
            }
            Section {
                modelDim("Longueur (L)", $container.sumpL)
                modelDim("Largeur (W)", $container.sumpW)
                modelDim("Profondeur", $container.sumpH)
            } header: {
                Text("Puisard (mm)")
            } footer: {
                Text("Le puisard est le creux du fond, plus profond, sous la cuve. Voluma calcule la table hauteur → volume à partir de ces cotes.")
            }
        case .slopedBox:
            Section("Dimensions (mm)") {
                modelDim("Longueur (L)", $container.dL)
                modelDim("Largeur (W)", $container.dW)
            }
            Section {
                modelDim("Côté profond (H)", $container.dH)
                modelDim("Côté faible", $container.shallowH)
            } header: {
                Text("Profondeurs (mm)")
            } footer: {
                Text("Le fond descend du côté faible vers le côté profond. Voluma calcule la table hauteur → volume à partir de ces cotes.")
            }
        case .custom:
            Section("Dimensions") {
                Text("La forme libre est définie par les points de jauge ci-dessous.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func modelDim(_ title: LocalizedStringKey, _ value: Binding<Double>) -> some View {
        HStack {
            Text(title)
            Spacer()
            if isEditing {
                TextField(title, value: value, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
            } else {
                Text(value.wrappedValue.formatted(.number.locale(locale)))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Text("mm").foregroundStyle(.secondary)
        }
    }

    // MARK: - Points de jauge (forme libre)

    private var gaugePointsSection: some View {
        Section {
            Label {
                Text("Versez un volume connu, mesurez la hauteur, et ajoutez le couple. Répétez pour 2 ou 3 paliers : Voluma interpole entre les points.")
            } icon: {
                Image(systemName: "info.circle")
            }
            .font(.footnote).foregroundStyle(.secondary)

            if isEditing {
                HStack {
                    Text("Hauteur mesurée").font(.caption2).foregroundStyle(.secondary)
                    Spacer()
                    Text("Volume connu").font(.caption2).foregroundStyle(.secondary)
                }
                ForEach(container.pointsList) { point in
                    GaugePointRow(point: point)
                }
                .onDelete(perform: deletePoints)

                Button("Ajouter un point", systemImage: "plus.circle.fill") {
                    if container.points == nil { container.points = [] }
                    container.points?.append(GaugePointModel(h_mm: 0, v_L: 0))
                }
            } else if container.pointsList.isEmpty {
                Text("Aucun point défini.").font(.footnote).foregroundStyle(.secondary)
            } else {
                ForEach(container.gaugePoints) { point in
                    HStack(spacing: 8) {
                        Text("\(Int(point.h_mm)) mm")
                        Image(systemName: "arrow.right").font(.caption2).foregroundStyle(.tertiary)
                        Spacer()
                        Text(point.v_L.formatted(.number.locale(locale)) + " L")
                    }
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Points de jauge")
        } footer: {
            Text("Exemple : 50 mm → 5 L, puis 150 mm → 18 L. Au moins 2 points ; touchez « + » pour en ajouter, balayez une ligne pour la supprimer.")
        }
    }

    private func deletePoints(_ offsets: IndexSet) {
        let points = container.pointsList
        for index in offsets {
            modelContext.delete(points[index])
        }
    }

    // MARK: - Calibrage

    private var calibrationReadOnly: some View {
        Section("Calibrage") {
            if container.k != 1 {
                LabeledContent("Facteur actuel") {
                    Text(container.k.formatted(.number.precision(.fractionLength(3)).locale(locale))).monospacedDigit()
                }
            } else {
                Text("Non calibré").font(.footnote).foregroundStyle(.secondary)
            }
        }
    }

    private var calibrationSection: some View {
        Section {
            if container.k != 1 {
                LabeledContent("Facteur actuel") {
                    Text(container.k.formatted(.number.precision(.fractionLength(3)).locale(locale)))
                        .monospacedDigit()
                }
                Button("Réinitialiser le calibrage", role: .destructive) {
                    container.k = 1
                    calMessage = nil
                }
            }
            HStack {
                Text("Hauteur mesurée")
                Spacer()
                TextField("Hauteur mesurée", value: $calHeight_mm, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                Text("mm").foregroundStyle(.secondary)
            }
            HStack {
                Text("Volume connu")
                Spacer()
                TextField("Volume connu", value: Binding(
                    get: { volumeUnit.fromLiters(calKnownVolume_L) },
                    set: { calKnownVolume_L = volumeUnit.toLiters($0) }
                ), format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                Text(volumeUnit.symbol).foregroundStyle(.secondary)
            }
            Button("Calculer le calibrage", action: applyCalibration)
                .disabled(calHeight_mm <= 0 || calKnownVolume_L <= 0)

            if let calMessage {
                Label(calMessage.text, systemImage: calMessage.ok ? "checkmark.circle.fill" : "xmark.octagon.fill")
                    .font(.footnote)
                    .foregroundStyle(calMessage.ok ? .green : .red)
            }
        } header: {
            Text("Calibrage")
        } footer: {
            Text("Ajuste un facteur k (entre 0,7 et 1,3) pour qu'une hauteur mesurée corresponde à un volume connu — par exemple un ticket de plein.")
        }
    }

    private func applyCalibration() {
        if let k = GaugeEngine.calibrationFactor(
            shape: container.shape, dims: container.dims,
            hMeasured: calHeight_mm, vKnown: calKnownVolume_L
        ) {
            container.k = k
            let kStr = k.formatted(.number.precision(.fractionLength(3)).locale(locale))
            calMessage = .init(ok: true, text: String(localized: "Calibrage appliqué : k = \(kStr)"))
        } else {
            calMessage = .init(ok: false,
                               text: String(localized: "Écart invraisemblable (hors 0,7–1,3) : calibrage refusé."))
        }
    }

    struct CalibrationMessage { let ok: Bool; let text: String }

    // MARK: - Aperçu

    private var previewSection: some View {
        Section("Aperçu") {
            HStack {
                FillView2D(shape: container.shape, compositeKind: container.compositeKindValue,
                           heightFraction: 0.6)
                    .frame(width: 80, height: 80)
                VStack(alignment: .leading, spacing: 4) {
                    LabeledContent("Volume plein") { Text(fullVolumeString).monospacedDigit() }
                    LabeledContent("Hauteur pleine") { Text(fullHeightString).monospacedDigit() }
                }
            }
        }
    }

    private var fullVolumeString: String {
        let v = GaugeEngine.fullVolume(shape: container.shape, dims: container.dims,
                                       points: container.gaugePoints, k: container.k)
        return volumeUnit.string(v, locale: locale)
    }

    private var fullHeightString: String {
        let h = GaugeEngine.fullHeight(shape: container.shape, dims: container.dims,
                                       points: container.gaugePoints)
        return (h / 10).formatted(.number.precision(.fractionLength(1)).locale(locale)) + " cm"
    }

    // MARK: - Plan attaché (PDF / DOCX / image)

    private var planTypes: [UTType] {
        var types: [UTType] = [.pdf, .image]
        if let docx = UTType("org.openxmlformats.wordprocessingml.document") { types.append(docx) }
        return types
    }

    private var planSection: some View {
        Section {
            if let plan = container.plan, !plan.data.isEmpty {
                Button {
                    showPlanPreview = true
                } label: {
                    Label(plan.fileName.isEmpty ? "Voir le plan" : plan.fileName, systemImage: "doc.richtext")
                }
                if isEditing {
                    Button("Remplacer le plan", systemImage: "arrow.triangle.2.circlepath") {
                        showPlanImporter = true
                    }
                    Button("Supprimer le plan", systemImage: "trash", role: .destructive) {
                        if let old = container.plan { modelContext.delete(old) }
                        container.plan = nil
                    }
                }
            } else if isEditing {
                Button("Importer un plan (PDF, image, DOCX)", systemImage: "square.and.arrow.down") {
                    showPlanImporter = true
                }
            } else {
                Text("Aucun plan attaché.").font(.footnote).foregroundStyle(.secondary)
            }
            if let planError {
                Label(planError, systemImage: "exclamationmark.triangle")
                    .font(.footnote).foregroundStyle(.red)
            }
        } header: {
            Text("Plan")
        } footer: {
            Text("Plan de coupe ou plan industriel attaché au récipient, embarqué et synchronisé via iCloud.")
        }
        .fileImporter(isPresented: $showPlanImporter, allowedContentTypes: planTypes) { result in
            handlePlanImport(result)
        }
        .fullScreenCover(isPresented: $showPlanPreview) {
            if let plan = container.plan {
                PlanPreviewSheet(plan: plan)
            }
        }
    }

    private func handlePlanImport(_ result: Result<URL, Error>) {
        planError = nil
        switch result {
        case .failure(let error):
            planError = error.localizedDescription
        case .success(let url):
            let needsAccess = url.startAccessingSecurityScopedResource()
            defer { if needsAccess { url.stopAccessingSecurityScopedResource() } }
            do {
                // Garde-fou : un plan trop lourd ferait gonfler l'enregistrement (et son CKAsset
                // iCloud) et saturerait la mémoire. On refuse au-delà de 30 Mo.
                let maxBytes = 30 * 1024 * 1024
                if let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize, size > maxBytes {
                    planError = String(localized: "Fichier trop volumineux (max 30 Mo).")
                    return
                }
                let data = try Data(contentsOf: url)
                guard !data.isEmpty, data.count <= maxBytes else {
                    planError = String(localized: "Fichier trop volumineux (max 30 Mo).")
                    return
                }
                let uti = (try? url.resourceValues(forKeys: [.contentTypeKey]))?.contentType?.identifier ?? ""
                if let old = container.plan { modelContext.delete(old) }
                container.plan = PlanDocument(fileName: url.lastPathComponent, data: data, utiIdentifier: uti)
            } catch {
                planError = error.localizedDescription
            }
        }
    }
}

// MARK: - Choix de forme dans l'éditeur (géométrique + composée + libre)

/// Réunit, pour l'UI, les formes géométriques simples, les formes composées (calculées)
/// et la table de jauge manuelle. Chaque choix se mappe vers (forme moteur, type composé).
private enum ShapeChoice: CaseIterable, Hashable {
    case box, vcyl, hcyl, sumpBox, slopedBox, custom

    var symbol: String {
        switch self {
        case .box:       ContainerShape.box.symbol
        case .vcyl:      ContainerShape.vcyl.symbol
        case .hcyl:      ContainerShape.hcyl.symbol
        case .sumpBox:   CompositeKind.sumpBox.symbol
        case .slopedBox: CompositeKind.slopedBox.symbol
        case .custom:    ContainerShape.custom.symbol
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .box:       ContainerShape.box.title
        case .vcyl:      ContainerShape.vcyl.title
        case .hcyl:      ContainerShape.hcyl.title
        case .sumpBox:   CompositeKind.sumpBox.title
        case .slopedBox: CompositeKind.slopedBox.title
        case .custom:    ContainerShape.custom.title
        }
    }

    var hint: LocalizedStringKey {
        switch self {
        case .box:       ContainerShape.box.hint
        case .vcyl:      ContainerShape.vcyl.hint
        case .hcyl:      ContainerShape.hcyl.hint
        case .sumpBox:   CompositeKind.sumpBox.hint
        case .slopedBox: CompositeKind.slopedBox.hint
        case .custom:    ContainerShape.custom.hint
        }
    }

    static func from(_ c: Container) -> ShapeChoice {
        if let kind = c.compositeKindValue {
            return kind == .sumpBox ? .sumpBox : .slopedBox
        }
        switch c.shape {
        case .box:    return .box
        case .vcyl:   return .vcyl
        case .hcyl:   return .hcyl
        case .custom: return .custom
        }
    }

    func apply(to c: Container) {
        switch self {
        case .box:       c.shape = .box;    c.compositeKind = ""
        case .vcyl:      c.shape = .vcyl;   c.compositeKind = ""
        case .hcyl:      c.shape = .hcyl;   c.compositeKind = ""
        case .custom:    c.shape = .custom; c.compositeKind = ""
        case .sumpBox:   c.shape = .custom; c.compositeKind = CompositeKind.sumpBox.rawValue
        case .slopedBox: c.shape = .custom; c.compositeKind = CompositeKind.slopedBox.rawValue
        }
    }
}

// MARK: - Ligne d'un point de jauge (édition)

private struct GaugePointRow: View {
    @Bindable var point: GaugePointModel

    var body: some View {
        HStack(spacing: 8) {
            TextField("Hauteur", value: $point.h_mm, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
            Text("mm").foregroundStyle(.secondary)
            Divider()
            TextField("Volume", value: $point.v_L, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
            Text("L").foregroundStyle(.secondary)
        }
        .font(.callout.monospacedDigit())
    }
}

#Preview {
    let c = Container(name: "Cuve test")
    c.shape = .hcyl; c.dD = 712; c.dLen = 879
    return NavigationStack { ContainerEditor(container: c) }
        .modelContainer(for: [Container.self, Liquid.self, PlanDocument.self, GaugePointModel.self],
                        inMemory: true)
}
