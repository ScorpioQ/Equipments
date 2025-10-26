//
//  EquipmentRowView.swift
//  Equipments
//
//  Created by AI on 2024/11/23.
//

import SwiftUI

struct EquipmentRowView: View {
    @ObservedObject var equipment: Equipment
    @Environment(\.locale) private var locale

    private var currencyCode: String {
        locale.currency?.identifier ?? Locale.autoupdatingCurrent.currency?.identifier ?? "CNY"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(equipment.wrappedName)
                    .font(.headline)
                Spacer()
                Text(equipment.dailyCost, format: .currency(code: currencyCode))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Label("equipment.row.purchase", systemImage: "tag")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.secondary)
                Text(equipment.purchasePrice, format: .currency(code: currencyCode))
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Label("equipment.row.days", systemImage: "clock")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.secondary)
                Text("equipment.row.held.days \(equipment.heldDays)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if equipment.isActive == false {
                    Label("equipment.row.inactive", systemImage: "pause.circle")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
            }

            if let notes = equipment.notes, notes.isEmpty == false {
                Text(notes)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let request = Equipment.fetchRequest()
    request.fetchLimit = 1
    let sample = (try? context.fetch(request).first) ?? Equipment(context: context)
    return EquipmentRowView(equipment: sample)
        .padding()
}
