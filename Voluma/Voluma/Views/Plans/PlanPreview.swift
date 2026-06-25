//
//  PlanPreview.swift
//  Voluma
//
//  Aperçu universel d'un plan (PDF, DOCX, image) via QuickLook.
//  PlanPreviewSheet écrit le contenu embarqué dans un fichier temporaire,
//  puis le présente plein écran.
//

import SwiftUI
import QuickLook

struct PlanPreview: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(url: url) }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        init(url: URL) { self.url = url }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}

/// Présente un PlanDocument embarqué : écrit un fichier temporaire puis l'aperçoit.
struct PlanPreviewSheet: View {
    let plan: PlanDocument
    @Environment(\.dismiss) private var dismiss
    @State private var url: URL?

    var body: some View {
        NavigationStack {
            Group {
                if let url {
                    PlanPreview(url: url)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    ContentUnavailableView("Plan indisponible",
                                           systemImage: "doc",
                                           description: Text("Le fichier n'a pas pu être ouvert."))
                }
            }
            .navigationTitle(plan.fileName.isEmpty ? "Plan" : plan.fileName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
        .onAppear { url = writeTempFile() }
    }

    private func writeTempFile() -> URL? {
        let name = plan.fileName.isEmpty ? "plan.dat" : plan.fileName
        let dest = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        do {
            try plan.data.write(to: dest, options: .atomic)
            return dest
        } catch {
            return nil
        }
    }
}
