import SwiftUI

struct EquipmentListView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Equipment.createdAt, ascending: false)],
        animation: .default
    ) private var equipments: FetchedResults<Equipment>

    @State private var presentingEditor = false
    @State private var selectedEquipment: Equipment?

    var body: some View {
        NavigationStack {
            Group {
                if equipments.isEmpty {
                    ContentUnavailableView(
                        "equipments.empty.title",
                        systemImage: "shippingbox",
                        description: Text("equipments.empty.description")
                    )
                } else {
                    List {
                        ForEach(equipments) { equipment in
                            NavigationLink(value: equipment.objectID) {
                                EquipmentRowView(equipment: equipment)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteEquipment(equipment)
                                } label: {
                                    Label("common.delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationDestination(for: NSManagedObjectID.self) { objectID in
                if let equipment = context.object(with: objectID) as? Equipment {
                    EquipmentDetailView(equipment: equipment)
                }
            }
            .navigationTitle("equipments.title")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedEquipment = nil
                        presentingEditor = true
                    } label: {
                        Label("common.add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $presentingEditor) {
                NavigationStack {
                    EquipmentEditorView(equipment: selectedEquipment)
                }
            }
        }
    }

    private func deleteEquipment(_ equipment: Equipment) {
        context.delete(equipment)
        PersistenceController.shared.save(context: context)
    }
}

private struct EquipmentRowView: View {
    let equipment: Equipment

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(equipment.name)
                    .font(.headline)
                if let sceneName = equipment.scene?.name {
                    Text(sceneName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                }
            }

            Text("equipments.dailyCost \(equipment.formattedDailyCost)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("equipments.price \(equipment.formattedPrice)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    EquipmentListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(SettingsStore(preview: true))
}
