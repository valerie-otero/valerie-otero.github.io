//
//  ScreenshotTests.swift
//  VolumaUITests
//
//  Capture marketing de chaque écran. Navigation indépendante de la langue :
//  onglets par index, noms de données ("Cuve à puisard", "Gazole"), prédicats.
//  À lancer avec -testLanguage fr|en pour obtenir les deux jeux, en mode clair
//  (réglé via `xcrun simctl ui <device> appearance light`).
//

import XCTest

final class ScreenshotTests: XCTestCase {

    override func setUpWithError() throws { continueAfterFailure = false }

    @MainActor
    func testCaptureAll() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-defaultContainerName", "Cuve à puisard / Sump tank", "-defaultLiquidName", "Gazole / Diesel"]
        app.launch()

        let tabs = app.tabBars.buttons
        XCTAssertTrue(tabs.firstMatch.waitForExistence(timeout: 15))

        // 1 — Lecture (coupe 2D)
        sleep(1)
        snap("1-lecture-2d")

        // 2 — Lecture (coupe 3D : segment « 3D » verbatim, non localisé)
        let btn3D = app.buttons["3D"]
        var t = 0
        while !btn3D.isHittable && t < 5 { app.swipeUp(); t += 1 }
        if btn3D.waitForExistence(timeout: 5) {
            btn3D.tap()
            _ = app.images.firstMatch.waitForExistence(timeout: 3)
            sleep(2)   // rendu SceneKit
        }
        snap("2-lecture-3d")

        // 3 — Récipients (onglet 1)
        tabs.element(boundBy: 1).tap()
        sleep(1)
        snap("3-recipients")

        // 4 — Fiche récipient composé (puisard)
        let cell = app.cells.containing(.staticText, identifier: "Cuve à puisard / Sump tank").firstMatch
        if cell.waitForExistence(timeout: 5) {
            cell.tap()
            sleep(1)
            snap("4-editeur-puisard")
            if app.navigationBars.buttons.firstMatch.exists {
                app.navigationBars.buttons.firstMatch.tap()   // retour
            }
        }

        // 5 — Liquides (onglet 2)
        tabs.element(boundBy: 2).tap()
        sleep(1)
        snap("5-liquides")

        // 6 — Réglages (onglet 3)
        tabs.element(boundBy: 3).tap()
        sleep(1)
        snap("6-reglages")

        // 7 — Table de graduation (depuis Lecture ; « graduation » présent FR & EN)
        tabs.element(boundBy: 0).tap()
        let table = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'graduation'")).firstMatch
        var k = 0
        while !table.exists && k < 6 { app.swipeUp(); k += 1 }
        if table.waitForExistence(timeout: 5) {
            table.tap()
            sleep(1)
            snap("7-table-graduation")
            if app.navigationBars.buttons.firstMatch.exists {
                app.navigationBars.buttons.firstMatch.tap()
            }
        }

        // 8 — FAQ (« questions » FR / « FAQ » EN)
        tabs.element(boundBy: 3).tap()
        let faq = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'questions' OR label CONTAINS[c] 'FAQ'")).firstMatch
        var j = 0
        while !faq.isHittable && j < 6 { app.swipeUp(); j += 1 }
        if faq.waitForExistence(timeout: 5) {
            faq.tap()
            sleep(1)
            snap("8-faq")
        }
    }

    private func snap(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let att = XCTAttachment(screenshot: shot)
        att.name = name
        att.lifetime = .keepAlways
        add(att)
    }
}
