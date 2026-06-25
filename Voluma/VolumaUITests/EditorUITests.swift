//
//  EditorUITests.swift
//  VolumaUITests
//
//  Parcours : Récipients → Ajouter → choix de forme + dimensions. Capture des écrans clés.
//

import XCTest

final class EditorUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCreateContainerFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // Onglet « Récipients »
        let tab = app.tabBars.buttons["Récipients"]
        XCTAssertTrue(tab.waitForExistence(timeout: 10))
        tab.tap()
        attach(name: "01-liste-recipients")

        // Bouton « Ajouter »
        let add = app.navigationBars.buttons["Ajouter"]
        XCTAssertTrue(add.waitForExistence(timeout: 5))
        add.tap()

        // Éditeur ouvert : nouveau sélecteur de formes (liste claire).
        XCTAssertTrue(app.staticTexts["Cylindre horizontal"].waitForExistence(timeout: 5))
        app.buttons.containing(.staticText, identifier: "Cylindre horizontal").firstMatch.tap()

        // Saisie des dimensions de la cuve atelier
        enter(app, "Diamètre (D)", "712")
        enter(app, "Longueur (L)", "879")

        // Fermer le clavier via un tap coordonné (jamais bloquant) puis défiler.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.06)).tap()
        app.swipeUp()

        attach(name: "02-editeur-cuve-horizontale")
    }

    @MainActor
    func testGraduationTable() throws {
        let app = XCUIApplication()
        app.launch()

        // Onglet « Lecture » par défaut : faire défiler jusqu'au lien de la table.
        let link = app.buttons["Table de graduation"]
        var tries = 0
        while !link.exists && tries < 6 {
            app.swipeUp()
            tries += 1
        }
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.tap()

        XCTAssertTrue(app.staticTexts["H. exacte"].waitForExistence(timeout: 5))
        attach(name: "03-table-graduation")
    }

    @MainActor
    func testContainerLock() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Récipients"].tap()
        app.cells.firstMatch.tap()   // Cuve atelier (enregistré)

        // Verrouillé par défaut : bouton « Modifier » présent, pas de « Terminé ».
        XCTAssertTrue(app.buttons["Modifier"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Terminé"].exists)
        attach(name: "15-fiche-verrouillee")

        // Déverrouiller.
        app.buttons["Modifier"].tap()
        XCTAssertTrue(app.buttons["Terminé"].waitForExistence(timeout: 5))
        attach(name: "16-fiche-edition")
    }

    @MainActor
    func testPigeExport() throws {
        let app = XCUIApplication()
        app.launch()

        // Aller à la table de graduation.
        let link = app.buttons["Table de graduation"]
        var tries = 0
        while !link.exists && tries < 6 { app.swipeUp(); tries += 1 }
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.tap()

        XCTAssertTrue(app.staticTexts["Repères tous les"].waitForExistence(timeout: 5))
        app.swipeUp()
        attach(name: "13-table-pige")

        // Export PDF → feuille de partage système.
        let pdf = app.buttons["PDF"]
        if pdf.waitForExistence(timeout: 5) {
            pdf.tap()
            let saveBtn = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] 'Fichiers' OR label CONTAINS[c] 'Files'")
            ).firstMatch
            _ = saveBtn.waitForExistence(timeout: 8)
            attach(name: "14-export-pdf")
        }
    }

    @MainActor
    func testMeasureBidirectional() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Coupe"].waitForExistence(timeout: 10))
        app.swipeUp(); app.swipeUp()
        XCTAssertTrue(app.staticTexts["Volume connu"].waitForExistence(timeout: 5))
        attach(name: "11-mesure")

        // Sens ticket → hauteur : saisir 300 L doit ramener la hauteur à ~56,9 cm.
        let field = app.textFields["litres"]
        if field.waitForExistence(timeout: 5) {
            field.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
            field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 8))
            field.typeText("300")
            app.staticTexts["Mesure"].tap()   // ferme le clavier
            attach(name: "12-ticket-300L")
        }
    }

    @MainActor
    func testRestoreSampleContainers() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Récipients"].tap()

        // Bouton de restauration des récipients d'exemple présent.
        let restore = app.buttons["Récipients d'exemple"]
        XCTAssertTrue(restore.waitForExistence(timeout: 5))
        attach(name: "19-recipients-boutons")

        // Tap → alerte (« déjà présents » sur une bibliothèque complète).
        restore.tap()
        XCTAssertTrue(app.staticTexts["Récipients d'exemple"].waitForExistence(timeout: 3))
        attach(name: "20-recipients-alerte")
    }

    @MainActor
    func testSampleLiquids() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Liquides"].tap()

        let sampleButton = app.buttons["Liquides d'exemple"]
        XCTAssertTrue(sampleButton.waitForExistence(timeout: 5))
        attach(name: "17-liquides-bouton")

        // Supprimer E85 pour pouvoir le ré-ajouter via le bouton.
        let e85 = app.cells.containing(.staticText, identifier: "E85").firstMatch
        if e85.waitForExistence(timeout: 3) {
            e85.swipeLeft()
            let delete = app.buttons["Supprimer"].firstMatch
            if delete.waitForExistence(timeout: 2) { delete.tap() }
        }

        sampleButton.tap()
        XCTAssertTrue(app.staticTexts["Liquides d'exemple"].waitForExistence(timeout: 3))
        attach(name: "18-liquides-ajoutes")
    }

    @MainActor
    func testLiquidsList() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Liquides"].tap()
        XCTAssertTrue(app.staticTexts["SP98"].waitForExistence(timeout: 5))
        attach(name: "10-liquides")
    }

    @MainActor
    func testReading3D() throws {
        let app = XCUIApplication()
        app.launch()

        // Onglet Lecture par défaut : capture du bandeau (Liquid Glass).
        XCTAssertTrue(app.staticTexts["Coupe"].waitForExistence(timeout: 10))
        attach(name: "08-lecture-glass")

        // Basculer en 3D.
        let btn3D = app.buttons["3D"]
        var tries = 0
        while !btn3D.isHittable && tries < 4 { app.swipeUp(); tries += 1 }
        XCTAssertTrue(btn3D.waitForExistence(timeout: 5))
        btn3D.tap()
        _ = app.images.firstMatch.waitForExistence(timeout: 3)   // petit délai de rendu SceneKit
        attach(name: "09-vue-3d")
    }

    @MainActor
    func testCompositeShape() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Récipients"].tap()

        let cell = app.cells.containing(.staticText, identifier: "Cuve à puisard / Sump tank").firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        cell.tap()

        // Fiche verrouillée : forme composée + cotes en lecture seule.
        XCTAssertTrue(app.staticTexts["Boîte + puisard"].waitForExistence(timeout: 5))
        attach(name: "26-composite-fiche")

        // Édition : liste de formes (avec composées) + sections paramétriques.
        app.buttons["Modifier"].tap()
        XCTAssertTrue(app.staticTexts["Cuve principale (mm)"].waitForExistence(timeout: 5))
        app.swipeUp()   // révéler la section « Puisard (mm) »
        XCTAssertTrue(app.staticTexts["Puisard (mm)"].waitForExistence(timeout: 5))
        attach(name: "27-composite-edition")
    }

    @MainActor
    func testShapePicker() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Récipients"].tap()

        let add = app.navigationBars.buttons["Ajouter"]
        XCTAssertTrue(add.waitForExistence(timeout: 5))
        add.tap()

        // Nouveau sélecteur de formes (liste claire avec descriptions).
        XCTAssertTrue(app.staticTexts["Cylindre vertical"].waitForExistence(timeout: 5))
        attach(name: "24-formes")

        // Choisir « Forme libre » → section points de jauge clarifiée.
        let libre = app.buttons.containing(.staticText, identifier: "Forme libre").firstMatch
        XCTAssertTrue(libre.waitForExistence(timeout: 5))
        libre.tap()
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Points de jauge"].waitForExistence(timeout: 5))
        attach(name: "25-points-jauge")
    }

    @MainActor
    func testFAQ() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Réglages"].tap()
        let faq = app.buttons["Foire aux questions"]
        var tries = 0
        while !faq.isHittable && tries < 5 { app.swipeUp(); tries += 1 }
        XCTAssertTrue(faq.waitForExistence(timeout: 5))
        faq.tap()

        XCTAssertTrue(app.staticTexts["Lecture & mesure"].waitForExistence(timeout: 5))
        app.staticTexts["Comment mesurer la hauteur à la pige ?"].firstMatch.tap()   // déplier
        attach(name: "22-faq")
    }

    @MainActor
    func testPdfPreview() throws {
        let app = XCUIApplication()
        app.launch()
        let link = app.buttons["Table de graduation"]
        var tries = 0
        while !link.exists && tries < 6 { app.swipeUp(); tries += 1 }
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.tap()

        let pdf = app.buttons["PDF"]
        XCTAssertTrue(pdf.waitForExistence(timeout: 5))
        pdf.tap()

        let apercu = app.buttons["Aperçu"]
        if apercu.waitForExistence(timeout: 6) {
            apercu.tap()
            // Attendre que QuickLook ait affiché le PDF (bouton « Terminé »).
            _ = app.buttons["Terminé"].waitForExistence(timeout: 8)
            _ = app.staticTexts["Table de pige"].waitForExistence(timeout: 4)
        }
        attach(name: "23-pdf-apercu")
    }

    @MainActor
    func testResetApp() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Réglages"].tap()

        let reset = app.buttons["Réinitialiser l'app"]
        var tries = 0
        while !reset.isHittable && tries < 5 { app.swipeUp(); tries += 1 }
        XCTAssertTrue(reset.waitForExistence(timeout: 5))
        reset.tap()

        XCTAssertTrue(app.buttons["Tout effacer et restaurer les exemples"].waitForExistence(timeout: 3))
        attach(name: "21-reset-confirm")
    }

    @MainActor
    func testSettings() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Réglages"].tap()
        XCTAssertTrue(app.staticTexts["Langue"].waitForExistence(timeout: 5))
        attach(name: "06-reglages-haut")

        app.swipeUp(); app.swipeUp()
        attach(name: "07-reglages-bas")
    }

    @MainActor
    func testImportEntryPoints() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Récipients"].tap()
        XCTAssertTrue(app.buttons["Importer (JSON)"].waitForExistence(timeout: 5))
        attach(name: "04-import-json-bouton")

        // Ouvrir le premier récipient ; le Form est paresseux → défiler jusqu'à « Plan ».
        app.cells.firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Forme"].waitForExistence(timeout: 5))   // éditeur ouvert
        app.swipeUp(); app.swipeUp(); app.swipeUp()
        attach(name: "05-section-plan")
    }

    private func enter(_ app: XCUIApplication, _ label: String, _ text: String) {
        let field = app.textFields[label]
        guard field.waitForExistence(timeout: 3) else { return }
        // `tap()` défile d'abord jusqu'au champ (fiable avec un Form paresseux), puis le focus.
        field.tap()
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 10))
        field.typeText(text)
    }

    private func attach(name: String) {
        let shot = XCUIScreen.main.screenshot()
        let att = XCTAttachment(screenshot: shot)
        att.name = name
        att.lifetime = .keepAlways
        add(att)
    }
}
