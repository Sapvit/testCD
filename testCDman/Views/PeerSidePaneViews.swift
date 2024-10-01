//
//  PeerSidePaneViews.swift
//  testCDman
//
//  Created by Nikolay Khort on 28.02.2024.
//

import Foundation
import SwiftUI

struct SidePanePeerInfoView: View {
    @ObservedObject var peer: Peer
    
    var body: some View {
            VStack(alignment: .trailing, spacing: 12) {
                Text("\(peer.name ?? "")")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("\(peer.category ?? "")")
                    .font(.headline)
                
                Text(peer.sourceContact != nil && !peer.sourceContact!.isEmpty ? "From \(peer.sourceContact!)" : "\(peer.sourceContact ?? "")")

                Text("\(peer.summary ?? "")")
                    .italic()
                    .foregroundColor(.gray)
                
                Divider()
                
                Text("Created: \(peer.createDate!, formatter: DateUtils.dateFormatter)").italic()
                    .foregroundColor(.gray)
                
                Text("Edited: \(peer.timestamp!, formatter: DateUtils.dateFormatter)").italic()
                    .foregroundColor(.gray)
                
                Spacer()
                NavigationLink(destination: EditPeerView(peer: peer)) {
                    Text("Edit peer details")
                        .foregroundColor(.blue)
                }
                .padding(.bottom)
            }
            .padding(.trailing)
    }
}

struct SidePanePeerInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let peer = Peer(context: context)
        peer.id = UUID()
        peer.timestamp = Date()
        peer.createDate = Date()
        peer.name = "Test name"
        peer.summary = shortLoremIpsum
        peer.category = "Wallet"
        peer.sourceContact = "Test peer 2"
        return SidePanePeerInfoView(peer: peer)
    }
}


struct SidePaneContactsView: View {
    @ObservedObject var peer: Peer
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var sortedContacts: [Contact] {
        if let contactsSet = peer.contacts as? Set<Contact> {
            return Array(contactsSet).sorted { $0.timestamp ?? Date() > $1.timestamp ?? Date() }
        } else {
            return []
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(sortedContacts) { contact in
                    NavigationLink(destination: EditContact(contact: contact)) {
                        ContactCard(contact: contact)
                    }
                }
                .onDelete { indexSet in
                    deleteContact(at: indexSet)
                }
            }
            .listStyle(PlainListStyle())
            .overlay {
                if sortedContacts.isEmpty {
                    NavigationLink(destination: AddContact(peer: peer)) {
                        ContentUnavailableView(label: {
                            Label("No contacts", systemImage: "person.crop.circle.badge.plus").foregroundColor(.black)
                        }, description: {
                            Text("Add one").foregroundColor(.blue)
                        }, actions: {})
                    }
                }
            }
            if !sortedContacts.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: AddContact(peer: peer)) {
                        Text("Add Contact")
                            .foregroundColor(.blue)
                    }
                }.padding(.bottom)
            }
        }
        .padding(.trailing)
    }
    
    private func deleteContact(at offsets: IndexSet) {
            offsets.forEach { index in
                if let contactsSet = peer.contacts as? Set<Contact> {
                    let contact = Array(contactsSet)[index]
                    peer.removeFromContacts(contact)
                    managedObjectContext.delete(contact)
                }
            }
            do {
                try managedObjectContext.save()
            } catch {
                print("Error deleting contact: \(error)")
            }
        }
    
}

struct SidePaneContactsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let peer = Peer(context: context)
        peer.name = "John Doe"
        
        let contact1 = Contact(context: context)
        contact1.name = "Alice"
        contact1.telegram = "@alice"
        contact1.email = "alice@example.com"
        
        let contact2 = Contact(context: context)
        contact2.name = "Bob"
        contact2.telegram = "@bob"
        contact2.email = "bob@example.com"
        
        let contact3 = Contact(context: context)
        contact3.name = "Charlie"
        contact3.telegram = "@charlie"
        contact3.email = "charlie@example.com"
        
        peer.contacts = NSSet(array: [contact1, contact2, contact3])
        
        return SidePaneContactsView(peer: peer)
            .environment(\.managedObjectContext, context)
    }
}

struct ContactCard: View {
    @ObservedObject var contact: Contact
    
    var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text(contact.name ?? "No Name")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(contact.telegram ?? "")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                Text(contact.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
    }
}

struct ContactCard_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let contact = Contact(context: context)
        contact.name = "Jon Doe"
        contact.phone = "+1234567890"
        contact.telegram = "@johndoe"
        contact.email = "john@example.com"
        contact.note = longLoremIpsum
        return ContactCard(contact: contact)
            .environment(\.managedObjectContext, context)
    }
}
