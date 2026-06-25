//
//  PrivacyView.swift
//  Voluma
//
//  Politique de confidentialité (localisée) + contact.
//

import SwiftUI

struct PrivacyView: View {
    @Environment(\.locale) private var locale
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Voluma ne collecte aucune donnée personnelle et n'utilise aucun traceur ni aucun outil d'analyse d'usage.")

                paragraph("Vos données",
                          "Les récipients, liquides et plans que vous créez sont stockés sur votre appareil. Si iCloud est activé, ils sont synchronisés via votre compte iCloud privé (CloudKit). Ces données restent les vôtres : le développeur n'y a pas accès et elles ne transitent par aucun serveur tiers.")

                paragraph("Maîtrise de vos données",
                          "Vous pouvez à tout moment consulter, modifier, exporter (au format JSON) ou supprimer vos données depuis l'application. La suppression d'un récipient ou d'un liquide est répercutée sur vos appareils synchronisés.")

                paragraph("Plans importés",
                          "Les plans (PDF, image, document) que vous joignez à un récipient sont embarqués dans votre base privée et synchronisés via iCloud, comme le reste de vos données.")

                paragraph("Avertissement",
                          "Voluma est un outil d'aide à la lecture, sans valeur réglementaire ni métrologique. La fiabilité du résultat dépend entièrement de la mesure : une hauteur mal relevée donne un volume faux. Mesurez avec soin et vérifiez vos relevés ; l'utilisateur est seul responsable de l'exactitude des mesures et des décisions qui en découlent.")

                VStack(alignment: .leading, spacing: 6) {
                    Text("Contact").font(.headline)
                    Link("Nous contacter par e-mail",
                         destination: URL(string: "mailto:valerie.otero@free.fr")!)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Confidentialité".localized(in: locale))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func paragraph(_ title: LocalizedStringKey, _ body: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(body).foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack { PrivacyView() }
}
