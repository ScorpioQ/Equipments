//
//  SceneDetailView.swift
//  Equipments
//
//  Created by AI on 2024/11/23.
//

import SwiftUI
import CoreData

struct SceneDetailView: View {
    @ObservedObject var scene: EquipmentScene
    @Environment(\.managedObjectContext) private var viewContext

    @State private var isPresentingEquipmentSheet = false

    var body: some View {
        List {
            Section(header: Text("scene.detail.section.overview")) {
                SceneSummaryView(scene: scene)
            }

            Section(header: Text("scene.detail.section.equipments")) {
                if scene.equipmentsArray.isEmpty {
                    ContentUnavailableView(
                        "scene.detail.empty.title",
                        systemImage: "shippingbox",
                        description: Text("scene.detail.empty.description")
                    )
                } else {
                    ForEach(scene.equipmentsArray) { equipment in
                        EquipmentRowView(equipment: equipment)
                    }
                    .onDelete(perform: deleteEquipment)
                }
            }
        }
        .navigationTitle(scene.wrappedName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isPresentingEquipmentSheet = true }) {
                    Label("scene.detail.add.equipment", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingEquipmentSheet) {
            NavigationStack {
                EquipmentFormView(scene: scene) { equipment in
                    scene.addToEquipments(equipment)
                    viewContext.saveIfNeeded()
                    isPresentingEquipmentSheet = false
                }
            }
        }
    }

    private func deleteEquipment(at offsets: IndexSet) {
        offsets.map { scene.equipmentsArray[$0] }.forEach(viewContext.delete)
        viewContext.saveIfNeeded()
    }
}

private struct SceneSummaryView: View {
    @ObservedObject var scene: EquipmentScene
    @Environment(\.locale) private var locale

    private var currencyCode: String {
        locale.currency?.identifier ?? Locale.autoupdatingCurrent.currency?.identifier ?? "CNY"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LabeledContent {
                Text(scene.totalInvestment, format: .currency(code: currencyCode))
            } label: {
                Label("scene.detail.total.investment", systemImage: "creditcard.fill")
            }

            LabeledContent {
                Text(scene.averageDailyCost, format: .currency(code: currencyCode))
            } label: {
                Label("scene.detail.average.daily.cost", systemImage: "calendar")
            }

            LabeledContent {
                Text(scene.activeEquipmentCount, format: .number)
            } label: {
                Label("scene.detail.active.count", systemImage: "checkmark.circle")
            }
        }
        .font(.subheadline)
    }
}

private struct EquipmentFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    var scene: EquipmentScene
    var onSave: (Equipment) -> Void

    @State private var name: String = ""
    @State private var price: Double = 0
    @State private var purchaseDate: Date = Date()
    @State private var isActive: Bool = true
    @State private var notes: String = ""

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()

    var body: some View {
        Form {
            Section(Text("equipment.form.section.basic")) {
                TextField("equipment.form.name", text: $name)
                TextField(
                    "equipment.form.price",
                    value: $price,
                    formatter: formatter,
                    prompt: Text("equipment.form.price.placeholder")
                )
                    .keyboardType(.decimalPad)
                DatePicker("equipment.form.date", selection: $purchaseDate, displayedComponents: .date)
                Toggle("equipment.form.active", isOn: $isActive)
            }

            Section(Text("equipment.form.section.notes")) {
                TextField(
                    "equipment.form.notes",
                    text: $notes,
                    axis: .vertical,
                    prompt: Text("equipment.form.notes.placeholder")
                )
            }
        }
        .navigationTitle("scene.detail.add.equipment")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("action.cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("action.save") {
                    let equipment = Equipment(context: viewContext)
                    equipment.id = UUID()
                    equipment.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    equipment.purchasePrice = price
                    equipment.purchaseDate = purchaseDate
                    equipment.isActive = isActive
                    equipment.notes = notes
                    equipment.createdAt = Date()
                    equipment.scene = scene
                    onSave(equipment)
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || price <= 0)
            }
        }
    }
}
