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
        sortDescriptors: [NSSortDescriptor(keyPath: \Scene.createdAt, ascending: true)],
        animation: .default
    )
    private var scenes: FetchedResults<Scene>

    @State private var isPresentingCreateSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if scenes.isEmpty {
                    ContentUnavailableView(
                        "还没有场景",
                        systemImage: "rectangle.on.rectangle.slash",
                        description: Text("创建第一个场景，开始记录你的装备组合")
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
            .navigationTitle("场景")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresentingCreateSheet = true }) {
                        Label("新增场景", systemImage: "plus")
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
                if let scene = try? viewContext.existingObject(with: objectID) as? Scene {
                    SceneDetailView(scene: scene)
                } else {
                    Text("无法找到场景")
                }
            }
        }
    }

    private func addScene(name: String, summary: String) {
        let newScene = Scene(context: viewContext)
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
            Section("场景信息") {
                TextField("场景名称", text: $name)
                TextField("简介", text: $summary, axis: .vertical)
            }
        }
        .navigationTitle("新建场景")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    onSave(trimmed, summary)
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}
