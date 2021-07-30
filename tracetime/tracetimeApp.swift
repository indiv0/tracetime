//
//  tracetimeApp.swift
//  tracetime
//
//  Created by Nikita Pekin on 2021-07-30.
//

import SwiftUI

@main
struct tracetimeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
