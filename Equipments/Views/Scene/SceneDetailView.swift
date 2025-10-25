import CoreData
import SwiftUI

struct SceneDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var scene: Scene

    @State private var presentingEditor = false
    @State private var presentingEquipmentEditor = false

    var body: some View {
        List {
            Section("scenes.section.overview") {
                LabeledContent("scenes.field.totalInvestment") {
                    Text(Formatters.currencyString(value: scene.totalInvestment))
                }

                LabeledContent("scenes.field.averageDailyCost") {
                    Text(Formatters.currencyString(value: scene.averageDailyCost))
                }

                LabeledContent("scenes.field.equipmentCount") {
                    Text("\(scene.equipmentCount)")
                }
            }

            Section("scenes.section.equipments") {
                if scene.equipmentsArray.isEmpty {
                    Text("scenes.empty.equipments")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(scene.equipmentsArray, id: \.objectID) { equipment in
                        NavigationLink(value: equipment.objectID) {
                            EquipmentRowView(equipment: equipment)
                        }
                    }
                }
            }
        }
        .navigationDestination(for: NSManagedObjectID.self) { objectID in
            if let equipment = context.object(with: objectID) as? Equipment {
                EquipmentDetailView(equipment: equipment)
            }
        }
        .navigationTitle(scene.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("scenes.actions.addEquipment") {
                        presentingEquipmentEditor = true
                    }

                    Button("common.edit") {
                        presentingEditor = true
                    }

                    Button("common.delete", role: .destructive) {
                        deleteScene()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $presentingEditor) {
            NavigationStack {
                SceneEditorView(scene: scene)
            }
        }
        .sheet(isPresented: $presentingEquipmentEditor) {
            NavigationStack {
                EquipmentEditorView(equipment: nil, preselectedScene: scene)
            }
        }
    }

    private func deleteScene() {
        context.delete(scene)
        PersistenceController.shared.save(context: context)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        if let sample = try? PersistenceController.preview.container.viewContext.fetch(Scene.fetchRequest()).first {
            SceneDetailView(scene: sample)
        }
    }
}
