//
//  testCDmanApp.swift
//  testCDman
//
//  Created by Nikolay Khort on 08.02.2024.
//

import SwiftUI

@main
struct testCDmanApp: App {
    //inject database 1/2
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
            //inject database 2/2
        }
    }
}
