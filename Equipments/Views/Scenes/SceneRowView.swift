//
//  SceneRowView.swift
//  Equipments
//
//  Created by AI on 2024/11/23.
//

import SwiftUI
import CoreData

struct SceneRowView: View {
    @ObservedObject var scene: Scene

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(scene.wrappedName)
                    .font(.headline)
                Spacer()
                Text("共 \(scene.equipmentsArray.count) 件装备")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Label {
                    Text(scene.totalInvestment, format: .currency(code: Locale.current.currency?.identifier ?? "CNY"))
                } icon: {
                    Image(systemName: "creditcard")
                }
                .font(.footnote)

                Label {
                    Text(scene.averageDailyCost, format: .currency(code: Locale.current.currency?.identifier ?? "CNY"))
                } icon: {
                    Image(systemName: "calendar")
                }
                .font(.footnote)
            }
            .foregroundStyle(.secondary)

            if let summary = scene.summary, summary.isEmpty == false {
                Text(summary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let request = Scene.fetchRequest()
    request.fetchLimit = 1
    let sampleScene = (try? context.fetch(request).first) ?? Scene(context: context)
    return SceneRowView(scene: sampleScene)
        .padding()
}
