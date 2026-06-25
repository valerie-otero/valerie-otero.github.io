//
//  LibraryImporter.swift
//  Voluma
//
//  Import d'une bibliothèque JSON (format du prototype) :
//  { "containers":[ { "name", "type", "dims":{…}, "k", "points":[…] } ],
//    "liquids":[ { "name", "rho", "visc", "note" } ] }
//  Fusion dans SwiftData : mise à jour si le nom existe déjà, sinon création.
//
//  Les DTO sont `nonisolated` (le module est MainActor par défaut, ce qui
//  entrerait en conflit avec les exigences nonisolated de Codable).
//

import Foundation
import SwiftData

nonisolated struct LibraryDTO: Codable {
    var containers: [ContainerDTO]?
    var liquids: [LiquidDTO]?
}

nonisolated struct ContainerDTO: Codable {
    var name: String
    var type: String
    var dims: [String: Double]?
    var k: Double?
    var points: [PointDTO]?
    // Champs ajoutés pour un aller-retour fidèle (rétro-compatibles : tous optionnels).
    var gaugeStepL: Double?
    var compositeKind: String?
    var sumpL: Double?
    var sumpW: Double?
    var sumpH: Double?
    var shallowH: Double?
}

nonisolated struct LiquidDTO: Codable {
    var name: String
    var rho: Double?
    var visc: Double?
    var note: String?
}

nonisolated struct PointDTO: Codable {
    var h_mm: Double
    var v_L: Double

    enum CodingKeys: String, CodingKey { case h_mm, v_L, h, v }

    init(h_mm: Double, v_L: Double) { self.h_mm = h_mm; self.v_L = v_L }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        h_mm = try c.decodeIfPresent(Double.self, forKey: .h_mm)
            ?? c.decodeIfPresent(Double.self, forKey: .h) ?? 0
        v_L = try c.decodeIfPresent(Double.self, forKey: .v_L)
            ?? c.decodeIfPresent(Double.self, forKey: .v) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(h_mm, forKey: .h_mm)
        try c.encode(v_L, forKey: .v_L)
    }
}

enum LibraryImporter {

    struct Counts { let containers: Int; let liquids: Int }

    // MARK: - Import non destructif (aperçu + résolution de conflits)

    /// Choix appliqué aux récipients/liquides dont le nom existe déjà.
    enum Resolution { case replace, keepBoth, skip }

    /// Aperçu d'un fichier : ce qui est nouveau et ce qui entre en conflit (même nom).
    struct Plan {
        let dto: LibraryDTO
        let newContainers: [String]
        let conflictContainers: [String]
        let newLiquids: [String]
        let conflictLiquids: [String]
        var conflictCount: Int { conflictContainers.count + conflictLiquids.count }
        var hasConflicts: Bool { conflictCount > 0 }
    }

    /// Bilan d'un import.
    struct Report { let added: Int; let updated: Int; let skipped: Int }

    /// Décode le fichier et détecte les collisions de noms, sans rien modifier.
    @MainActor
    static func plan(from url: URL, into context: ModelContext) throws -> Plan {
        let needsAccess = url.startAccessingSecurityScopedResource()
        defer { if needsAccess { url.stopAccessingSecurityScopedResource() } }
        let data = try Data(contentsOf: url)
        let dto = try JSONDecoder().decode(LibraryDTO.self, from: data)

        let existingC = Set((try? context.fetch(FetchDescriptor<Container>()))?.map(\.name) ?? [])
        let existingL = Set((try? context.fetch(FetchDescriptor<Liquid>()))?.map(\.name) ?? [])
        let cNames = (dto.containers ?? []).map(\.name)
        let lNames = (dto.liquids ?? []).map(\.name)
        return Plan(
            dto: dto,
            newContainers: cNames.filter { !existingC.contains($0) },
            conflictContainers: cNames.filter { existingC.contains($0) },
            newLiquids: lNames.filter { !existingL.contains($0) },
            conflictLiquids: lNames.filter { existingL.contains($0) }
        )
    }

    /// Applique le plan selon la résolution choisie et renvoie le bilan.
    @MainActor
    @discardableResult
    static func apply(_ dto: LibraryDTO, resolution: Resolution, into context: ModelContext) throws -> Report {
        var added = 0, updated = 0, skipped = 0

        for cdto in dto.containers ?? [] {
            let exists = try existsContainer(named: cdto.name, in: context)
            if exists, resolution == .skip { skipped += 1; continue }
            if exists, resolution == .keepBoth {
                var copy = cdto
                copy.name = uniqueContainerName(from: cdto.name, in: context)
                try mergeContainer(copy, into: context, forceNew: true); added += 1
            } else {
                try mergeContainer(cdto, into: context)
                if exists { updated += 1 } else { added += 1 }
            }
        }
        for ldto in dto.liquids ?? [] {
            let exists = try existsLiquid(named: ldto.name, in: context)
            if exists, resolution == .skip { skipped += 1; continue }
            if exists, resolution == .keepBoth {
                var copy = ldto
                copy.name = uniqueLiquidName(from: ldto.name, in: context)
                try mergeLiquid(copy, into: context, forceNew: true); added += 1
            } else {
                try mergeLiquid(ldto, into: context)
                if exists { updated += 1 } else { added += 1 }
            }
        }
        try context.save()
        return Report(added: added, updated: updated, skipped: skipped)
    }

    @MainActor private static func existsContainer(named name: String, in context: ModelContext) throws -> Bool {
        try !context.fetch(FetchDescriptor<Container>(predicate: #Predicate { $0.name == name })).isEmpty
    }
    @MainActor private static func existsLiquid(named name: String, in context: ModelContext) throws -> Bool {
        try !context.fetch(FetchDescriptor<Liquid>(predicate: #Predicate { $0.name == name })).isEmpty
    }

    /// Nom libre du type « Nom (importé) », « Nom (importé 2) »…
    @MainActor private static func uniqueContainerName(from base: String, in context: ModelContext) -> String {
        var candidate = String(localized: "\(base) (importé)")
        var i = 2
        while (try? existsContainer(named: candidate, in: context)) == true {
            candidate = String(localized: "\(base) (importé \(i))"); i += 1
        }
        return candidate
    }
    @MainActor private static func uniqueLiquidName(from base: String, in context: ModelContext) -> String {
        var candidate = String(localized: "\(base) (importé)")
        var i = 2
        while (try? existsLiquid(named: candidate, in: context)) == true {
            candidate = String(localized: "\(base) (importé \(i))"); i += 1
        }
        return candidate
    }

    /// Garde uniquement les points finis et bornés (anti table géante / NaN), via `ModelGuard`.
    nonisolated static func sanitizedPoints(_ pts: [PointDTO]?) -> [PointDTO] {
        (pts ?? [])
            .filter { ModelGuard.isValidPoint(h_mm: $0.h_mm, v_L: $0.v_L) }
            .prefix(ModelGuard.maxPoints)
            .map { $0 }
    }

    @MainActor
    static func importJSON(from url: URL, into context: ModelContext) throws -> Counts {
        let needsAccess = url.startAccessingSecurityScopedResource()
        defer { if needsAccess { url.stopAccessingSecurityScopedResource() } }

        let data = try Data(contentsOf: url)
        let dto = try JSONDecoder().decode(LibraryDTO.self, from: data)

        var containerCount = 0, liquidCount = 0
        for cdto in dto.containers ?? [] {
            try mergeContainer(cdto, into: context)
            containerCount += 1
        }
        for ldto in dto.liquids ?? [] {
            try mergeLiquid(ldto, into: context)
            liquidCount += 1
        }
        try context.save()
        return Counts(containers: containerCount, liquids: liquidCount)
    }

    @MainActor
    private static func mergeContainer(_ dto: ContainerDTO, into context: ModelContext, forceNew: Bool = false) throws {
        let name = dto.name
        let existing = forceNew ? nil : try context.fetch(
            FetchDescriptor<Container>(predicate: #Predicate { $0.name == name })
        ).first
        let c = existing ?? Container(name: name)
        if existing == nil { context.insert(c) }

        c.shape = ContainerShape(rawValue: dto.type) ?? .box
        c.k = ModelGuard.k(dto.k)
        c.gaugeStepL = ModelGuard.step(dto.gaugeStepL)
        c.compositeKind = (dto.compositeKind?.isEmpty == false) ? dto.compositeKind! : ""
        let dims = dto.dims ?? [:]

        if c.compositeKindValue != nil {
            // Forme composée : on restaure les cotes ; les points sont REGÉNÉRÉS (pas stockés).
            c.dL = ModelGuard.dim(dims["L"]); c.dW = ModelGuard.dim(dims["W"]); c.dH = ModelGuard.dim(dims["H"])
            c.sumpL = ModelGuard.dim(dto.sumpL); c.sumpW = ModelGuard.dim(dto.sumpW)
            c.sumpH = ModelGuard.dim(dto.sumpH); c.shallowH = ModelGuard.dim(dto.shallowH)
            for p in (c.points ?? []) { context.delete(p) }
            c.points = []
        } else {
            switch c.shape {
            case .box:  c.dL = ModelGuard.dim(dims["L"]); c.dW = ModelGuard.dim(dims["W"]); c.dH = ModelGuard.dim(dims["H"])
            case .vcyl: c.dD = ModelGuard.dim(dims["D"]); c.dH = ModelGuard.dim(dims["H"])
            case .hcyl: c.dD = ModelGuard.dim(dims["D"]); c.dLen = ModelGuard.dim(dims["L"])
            case .custom: break
            }
            // Remplace les points de jauge existants (filtrés : finis et bornés).
            for p in (c.points ?? []) { context.delete(p) }
            let newPoints = sanitizedPoints(dto.points).map { GaugePointModel(h_mm: $0.h_mm, v_L: $0.v_L) }
            newPoints.forEach { context.insert($0) }
            c.points = newPoints
        }
    }

    /// Sérialise tous les récipients et liquides au format JSON ré-importable.
    @MainActor
    static func exportJSON(containers: [Container], liquids: [Liquid]) throws -> Data {
        let cdtos = containers.map { c -> ContainerDTO in
            let isComposite = !c.compositeKind.isEmpty
            // Composée : exporter les cotes brutes (le moteur renvoie [:] en .custom) et PAS
            // les points générés (ils seront recalculés à l'import).
            let dimsOut: [String: Double] = isComposite ? ["L": c.dL, "W": c.dW, "H": c.dH] : c.dims
            let pointsOut = isComposite ? [] : c.gaugePoints.map { PointDTO(h_mm: $0.h_mm, v_L: $0.v_L) }
            return ContainerDTO(
                name: c.name,
                type: c.shapeRaw,
                dims: dimsOut,
                k: c.k,
                points: pointsOut,
                gaugeStepL: c.gaugeStepL,
                compositeKind: isComposite ? c.compositeKind : nil,
                sumpL: isComposite ? c.sumpL : nil,
                sumpW: isComposite ? c.sumpW : nil,
                sumpH: isComposite ? c.sumpH : nil,
                shallowH: isComposite ? c.shallowH : nil
            )
        }
        let ldtos = liquids.map {
            LiquidDTO(name: $0.name, rho: $0.density, visc: $0.viscosity, note: $0.note)
        }
        let library = LibraryDTO(containers: cdtos, liquids: ldtos)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(library)
    }

    @MainActor
    private static func mergeLiquid(_ dto: LiquidDTO, into context: ModelContext, forceNew: Bool = false) throws {
        let name = dto.name
        let existing = forceNew ? nil : try context.fetch(
            FetchDescriptor<Liquid>(predicate: #Predicate { $0.name == name })
        ).first
        let l = existing ?? Liquid(name: name)
        if existing == nil { context.insert(l) }

        // Validation via ModelGuard : densité plausible, viscosité >= 0 (sinon on garde l'existant).
        if let rho = ModelGuard.density(dto.rho) { l.density = rho }
        if let visc = ModelGuard.viscosity(dto.visc) { l.viscosity = visc }
        if let note = dto.note { l.note = note }
    }
}
