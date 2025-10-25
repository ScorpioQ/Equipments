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
            Section(header: Text("场景概览")) {
                SceneSummaryView(scene: scene)
            }

            Section(header: Text("装备")) {
                if scene.equipmentsArray.isEmpty {
                    ContentUnavailableView(
                        "暂无装备",
                        systemImage: "shippingbox",
                        description: Text("添加装备以开始计算日均投入")
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
                    Label("新增装备", systemImage: "plus")
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("总投入", systemImage: "creditcard.fill")
                Spacer()
                Text(scene.totalInvestment, format: .currency(code: Locale.current.currency?.identifier ?? "CNY"))
            }

            HStack {
                Label("平均日均成本", systemImage: "calendar")
                Spacer()
                Text(scene.averageDailyCost, format: .currency(code: Locale.current.currency?.identifier ?? "CNY"))
            }

            HStack {
                Label("在用装备", systemImage: "checkmark.circle")
                Spacer()
                Text("\(scene.activeEquipmentCount) 件")
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
        return formatter
    }()

    var body: some View {
        Form {
            Section("基本信息") {
                TextField("装备名称", text: $name)
                TextField("购买价格", value: $price, formatter: formatter)
                    .keyboardType(.decimalPad)
                DatePicker("购买日期", selection: $purchaseDate, displayedComponents: .date)
                Toggle("仍在使用", isOn: $isActive)
            }

            Section("备注") {
                TextField("补充信息", text: $notes, axis: .vertical)
            }
        }
        .navigationTitle("新增装备")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
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
