import SwiftUI
import CoreData

struct EquipmentEditorView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Scene.name, ascending: true)],
        animation: .default
    ) private var scenes: FetchedResults<Scene>

    let equipment: Equipment?
    let preselectedScene: Scene?

    @State private var name: String
    @State private var price: Double
    @State private var currencyCode: String
    @State private var purchaseDate: Date
    @State private var notes: String
    @State private var selectedSceneID: NSManagedObjectID?
    @State private var showingValidationAlert = false

    init(equipment: Equipment?, preselectedScene: Scene? = nil) {
        self.equipment = equipment
        self.preselectedScene = preselectedScene
        _name = State(initialValue: equipment?.name ?? "")
        _price = State(initialValue: equipment?.price ?? 0)
        _currencyCode = State(initialValue: equipment?.currencyCode ?? Locale.current.currency?.identifier ?? "CNY")
        _purchaseDate = State(initialValue: equipment?.purchaseDate ?? Date())
        _notes = State(initialValue: equipment?.notes ?? "")
        _selectedSceneID = State(initialValue: equipment?.scene?.objectID ?? preselectedScene?.objectID)
    }

    private var isEditing: Bool { equipment != nil }

    var body: some View {
        Form {
            Section("equipments.form.basic") {
                TextField("equipments.form.name", text: $name)

                HStack {
                    Text("equipments.form.price")
                    Spacer()
                    TextField("", value: $price, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: 160)
                }

                TextField("equipments.form.currency", text: $currencyCode)
                    .textInputAutocapitalization(.characters)
            }

            Section("equipments.form.meta") {
                DatePicker("equipments.form.purchaseDate", selection: $purchaseDate, displayedComponents: .date)

                Picker("equipments.form.scene", selection: $selectedSceneID) {
                    Text("common.none").tag(nil as NSManagedObjectID?)
                    ForEach(scenes, id: \.objectID) { scene in
                        Text(scene.name).tag(scene.objectID as NSManagedObjectID?)
                    }
                }
            }

            Section("equipments.field.notes") {
                TextEditor(text: $notes)
                    .frame(minHeight: 120)
            }
        }
        .navigationTitle(isEditing ? "equipments.form.editTitle" : "equipments.form.createTitle")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("common.cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("common.save") { save() }
            }
        }
        .alert("equipments.form.validation", isPresented: $showingValidationAlert) {
            Button("common.ok", role: .cancel) { }
        }
    }

    private func save() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty, price > 0 else {
            showingValidationAlert = true
            return
        }

        let target: Equipment
        if let equipment {
            target = equipment
        } else {
            target = Equipment(context: context)
            target.id = UUID()
            target.createdAt = Date()
        }

        target.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        target.price = price
        target.currencyCode = currencyCode.isEmpty ? nil : currencyCode.uppercased()
        target.purchaseDate = purchaseDate
        target.updatedAt = Date()
        target.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if let selectedSceneID,
           let scene = context.object(with: selectedSceneID) as? Scene {
            target.scene = scene
        } else {
            target.scene = nil
        }

        PersistenceController.shared.save(context: context)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        EquipmentEditorView(equipment: nil)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
