//
//  Persistence.swift
//  tracetime
//
//  Created by Nikita Pekin on 2021-07-30.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        var date = Date().addingTimeInterval(-3600)
        for i in 0..<100 {
            let newItem = Record(context: viewContext)
            newItem.id = UUID()
            newItem.activity = ["Eat", "Sleep", "Rave", "Repeat"].reversed()[i % 4];
            newItem.endTime = date
            date = date.addingTimeInterval(-Double.random(in: 0..<3600))
            newItem.startTime = date
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "tracetime")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            container.persistentStoreDescriptions.first!.url = AppGroup.facts.containerUrl.appendingPathComponent("tracetime.sqlite")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            print("Loaded \(storeDescription)")
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
