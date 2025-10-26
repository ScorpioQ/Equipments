//
//  SceneListView.swift
//  Equipments
//
//  Created by AI on 2024/11/23.
//

import SwiftUI
import CoreData

struct SceneListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \EquipmentScene.createdAt, ascending: true)],
        animation: .default
    )
    private var scenes: FetchedResults<EquipmentScene>

    @State private var isPresentingCreateSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if scenes.isEmpty {
                    ContentUnavailableView(
                        "scene.list.empty.title",
                        systemImage: "rectangle.on.rectangle.slash",
                        description: Text("scene.list.empty.description")
                    )
                } else {
                    List {
                        ForEach(scenes) { scene in
                            NavigationLink(value: scene.objectID) {
                                SceneRowView(scene: scene)
                            }
                            .accessibilityIdentifier("scene_\(scene.wrappedID.uuidString)")
                        }
                        .onDelete(perform: deleteScenes)
                    }
                }
            }
            .navigationTitle("scene.navigation.title")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresentingCreateSheet = true }) {
                        Label("scene.list.add", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $isPresentingCreateSheet) {
                NavigationStack {
                    SceneFormView { name, summary in
                        addScene(name: name, summary: summary)
                        isPresentingCreateSheet = false
                    }
                }
            }
            .navigationDestination(for: NSManagedObjectID.self) { objectID in
                if let scene = try? viewContext.existingObject(with: objectID) as? EquipmentScene {
                    SceneDetailView(scene: scene)
                } else {
                    Text("scene.navigation.fallback")
                }
            }
        }
    }

    private func addScene(name: String, summary: String) {
        let newScene = EquipmentScene(context: viewContext)
        newScene.id = UUID()
        newScene.name = name
        newScene.summary = summary
        newScene.createdAt = Date()

        viewContext.saveIfNeeded()
    }

    private func deleteScenes(offsets: IndexSet) {
        offsets
            .map { scenes[$0] }
            .forEach(viewContext.delete)
        viewContext.saveIfNeeded()
    }
}

private struct SceneFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var summary: String = ""

    var onSave: (_ name: String, _ summary: String) -> Void

    var body: some View {
        Form {
            Section(Text("scene.form.info")) {
                TextField("scene.form.name", text: $name)
                TextField(
                    "scene.form.summary",
                    text: $summary,
                    axis: .vertical,
                    prompt: Text("scene.form.summary.placeholder")
                )
            }
        }
        .navigationTitle("scene.form.title")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("action.cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("action.save") {
                    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    onSave(trimmed, summary)
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}
