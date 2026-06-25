//
//  SampleData.swift
//  Voluma
//
//  Données d'exemple : seedées quand la base est vide, et restaurables à la demande
//  (récipients/liquides manquants) sans doublon. Le seed est idempotent.
//

import Foundation
import SwiftData

enum SampleData {

    // MARK: - Récipients d'exemple

    struct ContainerSpec {
        let name: String
        let shape: ContainerShape
        let dL, dW, dH, dD, dLen: Double
        var compositeKind: String = ""
        var sumpL: Double = 0, sumpW: Double = 0, sumpH: Double = 0, shallowH: Double = 0
    }

    static let containerSpecs: [ContainerSpec] = [
        .init(name: "Cuve atelier / Workshop tank",      shape: .hcyl, dL: 0,    dW: 0,   dH: 0,   dD: 712, dLen: 879),
        .init(name: "Bac rectangulaire / Rectangular tub", shape: .box,  dL: 500,  dW: 400, dH: 300, dD: 0,   dLen: 0),
        .init(name: "Cuve à puisard / Sump tank",    shape: .custom, dL: 1200, dW: 800, dH: 500, dD: 0,  dLen: 0,
              compositeKind: CompositeKind.sumpBox.rawValue, sumpL: 300, sumpW: 300, sumpH: 150),
        .init(name: "Cuve fond incliné / Sloped-bottom tank", shape: .custom, dL: 1500, dW: 900, dH: 600, dD: 0,  dLen: 0,
              compositeKind: CompositeKind.slopedBox.rawValue, shallowH: 200),
    ]

    private static func makeContainer(_ spec: ContainerSpec) -> Container {
        let container = Container(name: spec.name)
        container.shape = spec.shape
        container.dL = spec.dL; container.dW = spec.dW; container.dH = spec.dH
        container.dD = spec.dD; container.dLen = spec.dLen
        container.compositeKind = spec.compositeKind
        container.sumpL = spec.sumpL; container.sumpW = spec.sumpW
        container.sumpH = spec.sumpH; container.shallowH = spec.shallowH
        return container
    }

    // MARK: - Liquides d'exemple

    struct LiquidSpec {
        let name: String
        let density: Double
        let viscosity: Double
        let note: String
        let colorHex: String
    }

    static let liquidSpecs: [LiquidSpec] = [
        .init(name: "SP98",         density: 0.750, viscosity: 0.6, note: "Essence · 15 °C",   colorHex: "#43A047"),
        .init(name: "100LL",        density: 0.718, viscosity: 0.5, note: "Avgas · 15 °C",     colorHex: "#1E88E5"),
        .init(name: "Gazole / Diesel",       density: 0.835, viscosity: 3.5, note: "15 °C",             colorHex: "#F9A825"),
        .init(name: "E85",          density: 0.781, viscosity: 1.2, note: "15 °C",             colorHex: "#FB8C00"),
        .init(name: "Eau / Water",          density: 0.998, viscosity: 1.0, note: "20 °C",             colorHex: "#29B6F6"),
        .init(name: "Huile moteur / Engine oil", density: 0.890, viscosity: 150, note: "SAE 30 · 40 °C",    colorHex: "#8D6E63"),
    ]

    private static func makeLiquid(_ spec: LiquidSpec) -> Liquid {
        let liquid = Liquid(name: spec.name, density: spec.density,
                            viscosity: spec.viscosity, note: spec.note)
        liquid.colorHex = spec.colorHex
        return liquid
    }

    // MARK: - Auto-seed seulement si aucun risque de doublon (pas de compte iCloud)

    /// Seede les exemples **uniquement si aucun compte iCloud n'est connecté** :
    /// dans ce cas l'appareil ne synchronise pas, donc aucun risque de doublon.
    /// Avec un compte iCloud, on n'auto-seede pas (les exemples arrivent par la synchro,
    /// ou se chargent à la demande via les boutons « … d'exemple ») — c'est ce qui évite
    /// l'accumulation de doublons quand plusieurs appareils partent d'une base vide.
    @MainActor
    static func seedIfSafe(_ context: ModelContext) {
        guard FileManager.default.ubiquityIdentityToken == nil else { return }
        seedIfEmpty(context)
    }

    /// Réinitialise l'app : efface toutes les données (récipients, liquides, points, plans)
    /// puis restaure un jeu d'exemples propre. Avec CloudKit, l'effacement se propage aux
    /// appareils synchronisés (contrairement à une simple désinstallation, qui ne touche
    /// pas la copie iCloud).
    @MainActor
    static func reset(_ context: ModelContext) {
        try? context.delete(model: GaugePointModel.self)
        try? context.delete(model: PlanDocument.self)
        try? context.delete(model: Container.self)
        try? context.delete(model: Liquid.self)
        try? context.save()
        seedIfEmpty(context)   // repeuple immédiatement un jeu d'exemples
    }

    // MARK: - Dé-duplication (auto-cicatrisation)

    /// Supprime les doublons **exacts** (même signature : nom + forme/dimensions, ou
    /// nom + densité/viscosité/couleur) en gardant le plus ancien. Sûr : ne touche jamais
    /// des modèles distincts (dimensions ou propriétés différentes → signatures différentes).
    /// Nettoie les doublons hérités d'anciens seeds répétés. Renvoie le nombre supprimé.
    /// Garde-fou : la dé-duplication ne doit s'exécuter qu'une fois par lancement
    /// (et non à chaque apparition de vue), pour ne pas courir avec l'import CloudKit.
    @MainActor private static var didDeduplicateThisLaunch = false

    @MainActor
    static func deduplicateOncePerLaunch(_ context: ModelContext) {
        guard !didDeduplicateThisLaunch else { return }
        didDeduplicateThisLaunch = true
        _ = deduplicate(context)
    }

    @MainActor
    @discardableResult
    static func deduplicate(_ context: ModelContext) -> Int {
        var removed = 0

        if let containers = try? context.fetch(
            FetchDescriptor<Container>(sortBy: [SortDescriptor(\.createdAt)])) {
            var seen = Set<String>()
            for c in containers {
                // Signature EXACTE : inclut le calibrage k, le pas de jauge, la présence d'un
                // plan et l'empreinte des points. Deux récipients qui diffèrent par l'un de ces
                // champs ne sont JAMAIS fusionnés → on ne peut pas supprimer un récipient calibré
                // au profit d'un doublon non calibré arrivé par la synchro iCloud.
                let pts = c.pointsList
                    .map { "\($0.h_mm):\($0.v_L)" }
                    .sorted()
                    .joined(separator: ",")
                let sig = "\(c.name)|\(c.shapeRaw)|\(c.compositeKind)|\(c.dL)|\(c.dW)|\(c.dH)|\(c.dD)|\(c.dLen)|\(c.sumpL)|\(c.sumpW)|\(c.sumpH)|\(c.shallowH)|\(c.k)|\(c.gaugeStepL)|\(c.plan != nil)|\(pts)"
                if seen.contains(sig) { context.delete(c); removed += 1 } else { seen.insert(sig) }
            }
        }

        if let liquids = try? context.fetch(
            FetchDescriptor<Liquid>(sortBy: [SortDescriptor(\.createdAt)])) {
            var seen = Set<String>()
            for l in liquids {
                let sig = "\(l.name)|\(l.density)|\(l.viscosity)|\(l.colorHex)"
                if seen.contains(sig) { context.delete(l); removed += 1 } else { seen.insert(sig) }
            }
        }

        if removed > 0 { try? context.save() }
        return removed
    }

    // MARK: - Seed brut (ne fait rien si la base contient déjà des données)

    @MainActor
    static func seedIfEmpty(_ context: ModelContext) {
        let containers = (try? context.fetchCount(FetchDescriptor<Container>())) ?? 0
        let liquids = (try? context.fetchCount(FetchDescriptor<Liquid>())) ?? 0
        guard containers == 0 && liquids == 0 else { return }

        containerSpecs.forEach { context.insert(makeContainer($0)) }
        liquidSpecs.forEach { context.insert(makeLiquid($0)) }
        try? context.save()
    }

    // MARK: - Restauration à la demande (fusion par nom, sans doublon)

    @MainActor
    @discardableResult
    static func addMissingContainers(_ context: ModelContext) -> Int {
        let existing = Set((try? context.fetch(FetchDescriptor<Container>()))?.map(\.name) ?? [])
        var added = 0
        for spec in containerSpecs where !existing.contains(spec.name) {
            context.insert(makeContainer(spec)); added += 1
        }
        if added > 0 { try? context.save() }
        return added
    }

    @MainActor
    @discardableResult
    static func addMissingLiquids(_ context: ModelContext) -> Int {
        let existing = Set((try? context.fetch(FetchDescriptor<Liquid>()))?.map(\.name) ?? [])
        var added = 0
        for spec in liquidSpecs where !existing.contains(spec.name) {
            context.insert(makeLiquid(spec)); added += 1
        }
        if added > 0 { try? context.save() }
        return added
    }
}
