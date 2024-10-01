//
//  DataController.swift
//  testCDman
//
//  Created by Nikolay Khort on 08.02.2024.
//

//Load, change and save data (Delete data is in ContentView)

import Foundation
import CoreData

class DataController: ObservableObject {
    //create a container:
    let container = NSPersistentContainer(name: "PeerModel")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("failed to load the data \(error.localizedDescription)")
            }
        }
    }
    
    //save the data
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Data saved")
        } catch {
            print("Couldn't save the data \(error.localizedDescription)")
        }
    }
    
    //add items
    func addPeer(name: String, summary: String, category: String, sourceContact: String, context: NSManagedObjectContext) {
        let peer = Peer(context: context)
        peer.id = UUID()
        peer.timestamp = Date()
        peer.createDate = Date()
        peer.name = name
        peer.summary = summary
        peer.category = category
        peer.sourceContact = sourceContact
        
        //temp prints:
        /*print("Adding Peer:")
            print("Name: \(name)")
            print("Summary: \(summary)")
            if let id = peer.id {
                print("ID: \(id)")
            } else {
                print("ID: No ID")
            }
            if let timestamp = peer.timestamp {
                print("Timestamp: \(timestamp)")
            } else {
                print("Timestamp: No timestamp")
            }*/
        
        //calling save function
        save(context: context)
    }
    
    //edit items
    func editPeer(name: String, summary: String, category: String, sourceContact: String, context: NSManagedObjectContext) {
        let peer = Peer(context: context)
        peer.timestamp = Date()
        peer.name = name
        peer.summary = summary
        peer.category = category
        peer.sourceContact = sourceContact
        
        save(context: context)
    }
}


struct FishText {
    static let shortText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
    static let longText = "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"
}
