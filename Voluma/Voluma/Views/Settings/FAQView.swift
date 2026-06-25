//
//  FAQView.swift
//  Voluma
//
//  Foire aux questions, organisée par thèmes (sections avec icônes) et repliable.
//

import SwiftUI

struct FAQView: View {
    @Environment(\.locale) private var locale

    private struct Item: Identifiable {
        let id = UUID()
        let icon: String
        let question: LocalizedStringKey
        let answer: LocalizedStringKey
    }

    private struct Topic: Identifiable {
        let id = UUID()
        let title: LocalizedStringKey
        let icon: String
        let items: [Item]
    }

    private let topics: [Topic] = [
        Topic(title: "Lecture & mesure", icon: "gauge.with.dots.needle.bottom.50percent", items: [
            Item(icon: "ruler",
                 question: "Comment mesurer la hauteur à la pige ?",
                 answer: "Plongez une pige (jauge) verticale jusqu'au fond du récipient, retirez-la et lisez la hauteur mouillée. Saisissez cette hauteur dans Voluma : il en déduit le volume, le poids et le pourcentage de remplissage."),
            Item(icon: "arrow.left.arrow.right",
                 question: "Puis-je saisir un volume au lieu d'une hauteur ?",
                 answer: "Oui. Dans la lecture, le champ « Volume connu » est bidirectionnel : entrez un volume (par exemple un ticket de plein) et la hauteur correspondante se calcule — et inversement quand vous bougez la pige."),
            Item(icon: "plusminus",
                 question: "Que signifie « ± 1 mm = ± X » sous la lecture ?",
                 answer: "C'est la sensibilité au niveau courant : de combien le volume varie pour 1 mm d'erreur de mesure. Plus la valeur est grande, plus une mesure précise est importante."),
        ]),
        Topic(title: "Récipients & calibrage", icon: "cylinder.split.1x2", items: [
            Item(icon: "square.on.square.dashed",
                 question: "Quelles formes de récipients Voluma sait-il jauger ?",
                 answer: "Boîtes rectangulaires, cylindres verticaux et horizontaux, formes composées calculées (boîte avec puisard, boîte à fond incliné), et la forme libre définie par vos propres mesures hauteur → volume. On choisit la forme à la création et on saisit les cotes ; le volume, la masse et le % se calculent à partir de la hauteur lue à la pige."),
            Item(icon: "rectangle.split.1x2",
                 question: "Comment saisir une cuve à puisard ou à fond incliné ?",
                 answer: "Choisissez la forme composée voulue. Pour le puisard : les cotes de la cuve principale, puis celles du puisard (L × l × profondeur). Pour le fond incliné : la longueur, la largeur, puis les deux profondeurs (côté profond et côté faible) — l'ordre des deux côtés n'a aucune importance, Voluma prend le plus grand comme côté profond. Le barème est calculé automatiquement, sans mesure."),
            Item(icon: "slider.horizontal.3",
                 question: "Comment calibrer ma cuve avec un ticket de plein ?",
                 answer: "Dans l'éditeur du récipient (mode Modifier), section Calibrage : saisissez la hauteur mesurée et le volume connu (par exemple un plein facturé). Voluma calcule un facteur k (limité à 0,7–1,3) qui ajuste toutes les lectures de ce récipient."),
            Item(icon: "scribble.variable",
                 question: "À quoi sert la « forme libre » sans plan ?",
                 answer: "Pour un récipient de forme inconnue ou irrégulière, relevez quelques couples hauteur/volume (par remplissages successifs mesurés). Voluma interpole linéairement entre ces points de jauge pour estimer le volume à toute hauteur."),
            Item(icon: "lock",
                 question: "Pourquoi un récipient enregistré est-il verrouillé ?",
                 answer: "Pour éviter toute modification accidentelle (ou remise à zéro), un récipient enregistré s'ouvre en lecture seule. Touchez « Modifier » pour déverrouiller et changer ses dimensions, sa forme ou son calibrage."),
        ]),
        Topic(title: "Liquides", icon: "drop.fill", items: [
            Item(icon: "equal.circle",
                 question: "Pourquoi la table de graduation est-elle la même pour tous les liquides ?",
                 answer: "Le volume ne dépend que de la géométrie du récipient et de la hauteur — pas du liquide. Seul le poids change d'un liquide à l'autre, via sa densité."),
            Item(icon: "wind",
                 question: "La viscosité influence-t-elle le calcul ?",
                 answer: "Non. La viscosité est purement indicative ; elle n'entre pas dans le calcul du volume ni du poids. Seule la densité détermine le poids."),
            Item(icon: "paintpalette",
                 question: "Comment donner une couleur à un liquide ?",
                 answer: "Dans la fiche d'un liquide (mode Modifier), touchez « Couleur ». La teinte sert à repérer d'un coup d'œil le liquide dans la coupe et les listes (idéal pour distinguer les essences)."),
        ]),
        Topic(title: "Unités & impression", icon: "printer", items: [
            Item(icon: "ruler",
                 question: "Puis-je afficher en gallons ou en livres ?",
                 answer: "Oui, dans Réglages → Affichage : volume en litres ou en gallons (US / impérial), masse en kilogrammes ou en livres, hauteur en cm ou mm. C'est purement visuel : les calculs restent effectués en interne en litres et kilogrammes."),
            Item(icon: "tablecells",
                 question: "Comment générer et imprimer une pige (barème) ?",
                 answer: "Depuis la lecture, ouvrez « Table de graduation », choisissez le pas (repères tous les X), puis exportez en PDF (format A4, prêt à imprimer) ou en CSV via les boutons en bas. Le pas est enregistré avec le récipient."),
        ]),
        Topic(title: "Sauvegarde & partage", icon: "externaldrive", items: [
            Item(icon: "square.and.arrow.up",
                 question: "Que contient (et ne contient pas) l'export JSON ?",
                 answer: "L'export reprend vos récipients (nom, forme — y compris les formes composées puisard/fond incliné —, cotes, calibrage k et pas de jauge) et vos liquides (densité, viscosité, note). Les plans/documents attachés ne sont PAS inclus dans le fichier JSON ; ils restent sauvegardés via iCloud. Le fichier est entièrement ré-importable."),
            Item(icon: "exclamationmark.triangle",
                 question: "Que se passe-t-il si j'importe un récipient du même nom qu'un des miens ?",
                 answer: "L'import fusionne par nom : un récipient existant portant le même nom est mis à jour avec les valeurs du fichier. N'importez que des fichiers de confiance ; les valeurs aberrantes (densité absurde, points hors borne) sont automatiquement filtrées. Pour préserver un récipient calibré, renommez-le avant d'importer."),
        ]),
        Topic(title: "Synchronisation iCloud", icon: "icloud", items: [
            Item(icon: "checkmark.icloud",
                 question: "Mes données sont-elles synchronisées entre mes appareils ?",
                 answer: "Oui : si iCloud est activé, vos récipients, liquides et plans sont synchronisés automatiquement via votre compte iCloud privé, sur tous vos appareils connectés au même identifiant Apple."),
            Item(icon: "arrow.triangle.2.circlepath",
                 question: "J'ai des doublons après réinstallation, que faire ?",
                 answer: "Désinstaller l'app n'efface pas la copie iCloud, qui redescend ensuite. Les doublons exacts (mêmes nom, forme, cotes, calibrage) sont fusionnés automatiquement au lancement, sans toucher aux récipients réellement distincts. Pour repartir d'un jeu d'exemples propre, utilisez Réglages → « Réinitialiser l'app »."),
        ]),
    ]

    var body: some View {
        List {
            ForEach(topics) { topic in
                Section {
                    ForEach(topic.items) { item in
                        DisclosureGroup {
                            Text(item.answer)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 4)
                        } label: {
                            Label(item.question, systemImage: item.icon)
                                .font(.subheadline.weight(.medium))
                        }
                    }
                } header: {
                    Label(topic.title, systemImage: topic.icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.tint)
                }
            }
        }
        .navigationTitle("Foire aux questions".localized(in: locale))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { FAQView() }
}
