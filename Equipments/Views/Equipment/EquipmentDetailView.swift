import SwiftUI

struct EquipmentDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var equipment: Equipment

    @State private var presentingEditor = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        List {
            Section("equipments.section.summary") {
                LabeledContent("equipments.field.price") {
                    Text(equipment.formattedPrice)
                }

                LabeledContent("equipments.field.dailyCost") {
                    Text(equipment.formattedDailyCost)
                        .fontWeight(.semibold)
                }

                LabeledContent("equipments.field.purchaseDate") {
                    Text(dateFormatter.string(from: equipment.purchaseDate))
                }

                if let sceneName = equipment.scene?.name {
                    LabeledContent("equipments.field.scene") {
                        Text(sceneName)
                    }
                }
            }

            if let notes = equipment.notes, !notes.isEmpty {
                Section("equipments.field.notes") {
                    Text(notes)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .navigationTitle(equipment.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    presentingEditor = true
                } label: {
                    Label("common.edit", systemImage: "pencil")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    deleteEquipment()
                } label: {
                    Label("common.delete", systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $presentingEditor) {
            NavigationStack {
                EquipmentEditorView(equipment: equipment)
            }
        }
    }

    private func deleteEquipment() {
        context.delete(equipment)
        PersistenceController.shared.save(context: context)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        if let sample = try? PersistenceController.preview.container.viewContext.fetch(Equipment.fetchRequest()).first {
            EquipmentDetailView(equipment: sample)
        }
    }
}
