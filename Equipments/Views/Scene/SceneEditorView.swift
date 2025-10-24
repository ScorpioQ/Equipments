import SwiftUI

struct SceneEditorView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    let scene: Scene?

    @State private var name: String
    @State private var color: Color
    @State private var showingValidationAlert = false

    init(scene: Scene?) {
        self.scene = scene
        _name = State(initialValue: scene?.name ?? "")
        if let hex = scene?.colorHex, let color = Color(hex: hex) {
            _color = State(initialValue: color)
        } else {
            _color = State(initialValue: .accentColor)
        }
    }

    private var isEditing: Bool { scene != nil }

    var body: some View {
        Form {
            Section("scenes.form.basic") {
                TextField("scenes.form.name", text: $name)
                ColorPicker("scenes.form.color", selection: $color)
            }
        }
        .navigationTitle(isEditing ? "scenes.form.editTitle" : "scenes.form.createTitle")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("common.cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("common.save") { save() }
            }
        }
        .alert("scenes.form.validation", isPresented: $showingValidationAlert) {
            Button("common.ok", role: .cancel) { }
        }
    }

    private func save() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            showingValidationAlert = true
            return
        }

        let target: Scene
        if let scene {
            target = scene
        } else {
            target = Scene(context: context)
            target.id = UUID()
            target.createdAt = Date()
        }

        target.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        target.colorHex = color.hexString()

        PersistenceController.shared.save(context: context)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        SceneEditorView(scene: nil)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
