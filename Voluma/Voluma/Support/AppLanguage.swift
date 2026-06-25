//
//  AppLanguage.swift
//  Voluma
//
//  Choix de langue dans l'app (français ou anglais), au choix de l'utilisateur,
//  indépendant du réglage iOS par-app. Stocké dans @AppStorage("appLanguage")
//  et appliqué via .environment(\.locale, …) à la racine.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case fr
    case en

    var id: String { rawValue }

    /// Locale appliquée à l'environnement.
    var resolvedLocale: Locale {
        switch self {
        case .fr: Locale(identifier: "fr")
        case .en: Locale(identifier: "en")
        }
    }

    /// Nom affiché dans le sélecteur (chaque langue dans sa propre langue).
    var displayName: String {
        switch self {
        case .fr: "Français"
        case .en: "English"
        }
    }

    /// Langue initiale au premier lancement, déduite de l'appareil
    /// (français si l'appareil est en français, anglais sinon).
    static var deviceDefault: AppLanguage {
        let preferred = Locale.preferredLanguages.first?.lowercased() ?? "fr"
        return preferred.hasPrefix("fr") ? .fr : .en
    }
}

extension String {
    /// Résout cette clé (le texte source de l'app est en français) dans la langue
    /// `locale`, en lisant directement le bundle de cette langue.
    ///
    /// Indispensable pour les titres de barre de navigation : `navigationTitle`, ponté
    /// vers UIKit, n'hérite pas de `\.environment(\.locale)` appliqué à la racine, et
    /// resterait donc figé sur la langue système. Cette résolution explicite suit le
    /// choix de langue fait dans l'app et se recalcule à chaque changement de `locale`.
    func localized(in locale: Locale) -> String {
        let code = locale.language.languageCode?.identifier ?? "fr"
        // Le français est la langue source (`sourceLanguage = fr`) : la clé EST le texte.
        guard code != "fr",
              let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else { return self }
        return bundle.localizedString(forKey: self, value: self, table: nil)
    }
}
