//
//  PlanDocument.swift
//  Voluma
//
//  Plan attaché à un récipient (PDF / DOCX / image), embarqué et synchronisé iCloud.
//  `.externalStorage` : les gros fichiers sont stockés hors de la base (CKAsset en sync).
//

import Foundation
import SwiftData

@Model final class PlanDocument {
    var fileName: String = ""

    @Attribute(.externalStorage)
    var data: Data = Data()

    var utiIdentifier: String = ""   // ex. com.adobe.pdf

    /// Inverse de `Container.plan` (requis par CloudKit).
    var container: Container?

    init(fileName: String = "", data: Data = Data(), utiIdentifier: String = "") {
        self.fileName = fileName
        self.data = data
        self.utiIdentifier = utiIdentifier
    }
}
