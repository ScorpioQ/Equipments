import SwiftUI

struct SceneListView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Scene.createdAt, ascending: false)],
        animation: .default
    ) private var scenes: FetchedResults<Scene>

    @State private var presentingEditor = false

    var body: some View {
        NavigationStack {
            Group {
                if scenes.isEmpty {
                    ContentUnavailableView(
                        "scenes.empty.title",
                        systemImage: "square.grid.2x2",
                        description: Text("scenes.empty.description")
                    )
                } else {
                    List {
                        ForEach(scenes) { scene in
                            NavigationLink(value: scene.objectID) {
                                SceneRowView(scene: scene)
                            }
                        }
                        .onDelete(perform: deleteScenes)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationDestination(for: NSManagedObjectID.self) { objectID in
                if let scene = context.object(with: objectID) as? Scene {
                    SceneDetailView(scene: scene)
                }
            }
            .navigationTitle("scenes.title")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentingEditor = true
                    } label: {
                        Label("common.add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $presentingEditor) {
                NavigationStack {
                    SceneEditorView(scene: nil)
                }
            }
        }
    }

    private func deleteScenes(_ indexSet: IndexSet) {
        indexSet.compactMap { scenes[$0] }.forEach(context.delete)
        PersistenceController.shared.save(context: context)
    }
}

private struct SceneRowView: View {
    @ObservedObject var scene: Scene

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(scene.name)
                .font(.headline)

            HStack(alignment: .firstTextBaseline) {
                Label {
                    Text("scenes.totalInvestment \(Formatters.currencyString(value: scene.totalInvestment))")
                } icon: {
                    Image(systemName: "creditcard")
                }

                Spacer()

                Label {
                    Text("scenes.equipmentCount \(scene.equipmentCount)")
                } icon: {
                    Image(systemName: "cube")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SceneListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(SettingsStore(preview: true))
}
