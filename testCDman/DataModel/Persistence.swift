//
//  Persistence.swift
//  testCDman
//
//  Created by Nikolay Khort on 09.02.2024.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PeerModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        // Add some example data for preview
        for index in 0..<3 {
            let peer = Peer(context: context)
            peer.id = UUID()
            peer.timestamp = Date()
            peer.createDate = Date()
            peer.name = "Peer \(index)"
//            peer.summary = "Example Summary \(index) - \(peer.id!)"
            peer.summary = "Example Summary \(index)"
            peer.category = "Wallets"
            peer.sourceContact = "Peer \(index+1)"
        }
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return controller
    }()
}
