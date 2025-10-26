//
//  EquipmentsApp.swift
//  Equipments
//
//  Created by 米樵 on 2024/11/22.
//

import SwiftUI

@main
struct EquipmentsApp: App {
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
