//
//  NSManagedObjectContext+Save.swift
//  Equipments
//
//  Created by AI on 2024/11/23.
//

import CoreData

extension NSManagedObjectContext {
    func saveIfNeeded(file: StaticString = #fileID, line: UInt = #line) {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            assertionFailure("Core Data save failed at \(file):\(line) with error: \(error.localizedDescription)")
        }
    }
}
