//
//  AddContactView.swift
//  testCDman
//
//  Created by Nikolay Khort on 26.02.2024.
//

import Foundation
import SwiftUI

struct AddContact: View {
    @ObservedObject var peer: Peer
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showConfirmationAlert = false
    
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var telegram: String = ""
    @State private var email: String = ""
    @State private var note: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Form {
                    TextField("Add name", text: $name)
                    TextField("Add telegram", text: $telegram)
                    TextField("Add e-mail", text: $email)
                    TextField("Add phone", text: $phone)
                    TextField("Add note", text: $note)
                }
            }
            .navigationBarTitle("New contact", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if hasChanges() {
                            showConfirmationAlert = true
                        } else { dismiss() }
                } }
                ToolbarItem() {
                    Button("Save") {
                        if name.isEmpty {
                            name = "No contact name"
                        }
                        let contact = Contact(context: managedObjectContext)
                        contact.id = UUID()
                        contact.name = name
                        contact.phone = phone
                        contact.email = email
                        contact.telegram = telegram
                        contact.note = note
                        contact.timestamp = Date()
                        contact.createDate = Date()
                        peer.addToContacts(contact)
                        peer.timestamp = Date()
                        dismiss()
                    }
                }
            }
        }
        .alert(isPresented: $showConfirmationAlert) {
            Alert(
                title: Text("Discard Changes"),
                message: Text("Are you sure you want to discard the changes?"),
                primaryButton: .cancel(),
                secondaryButton: .destructive(Text("Discard")) {
                    dismiss()
                }
            )
        }
    }
    private func hasChanges() -> Bool {
        return !name.isEmpty || !phone.isEmpty || !telegram.isEmpty || !email.isEmpty || !note.isEmpty
    }
}


struct EditContact: View {
    @ObservedObject var contact: Contact
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showConfirmationAlert = false
    @State private var showDeleteAlert = false
    
    enum AlertType {
            case discardChanges, deleteContact
        }
    @State private var alertType: AlertType?
    
    @State private var name: String
    @State private var phone: String
    @State private var telegram: String
    @State private var email: String
    @State private var note: String
    
    init(contact: Contact) {
        self.contact = contact
        _name = State(initialValue: contact.name ?? "")
        _phone = State(initialValue: contact.phone ?? "")
        _telegram = State(initialValue: contact.telegram ?? "")
        _email = State(initialValue: contact.email ?? "")
        _note = State(initialValue: contact.note ?? "")
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Form {
                    TextField("Add name", text: $name)
                    TextField("Add telegram", text: $telegram)
                    TextField("Add e-mail", text: $email)
                    TextField("Add phone", text: $phone)
                    TextField("Add note", text: $note)
                    
                    Section {
                        Button("Delete Contact") { showDeleteAlert = true }
                        .foregroundColor(.red)
                        .alert(isPresented: $showDeleteAlert) {
                            Alert(
                                title: Text("Delete Contact"),
                                message: Text("Are you sure you want to delete this contact?"),
                                primaryButton: .cancel(),
                                secondaryButton: .destructive(Text("Delete")) {
                                    deleteContact()
                                }
                            )
                        }
                    }
                }
                
            }
            .navigationBarTitle("Edit contact", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if hasChanges() {
                            showConfirmationAlert = true
                        } else { dismiss() }
                }.alert(isPresented: $showConfirmationAlert) {
                    Alert(
                        title: Text("Discard Changes"),
                        message: Text("Are you sure you want to discard the changes?"),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text("Discard")) {
                            dismiss()
                        }
                    )
                } }
                ToolbarItem() {
                    Button("Save") {
                        contact.name = name
                        contact.phone = phone
                        contact.email = email
                        contact.telegram = telegram
                        contact.note = note
                        contact.timestamp = Date()
                        dismiss()
                    }
                }
            }
        }
        
        
    }
    private func hasChanges() -> Bool {
        return name != (contact.name ?? "") || telegram != (contact.telegram ?? "") || email != (contact.email ?? "") || phone != (contact.phone ?? "") || note != (contact.note ?? "")
    }
    private func deleteContact() {
        managedObjectContext.delete(contact)
        dismiss()
    }
}




struct AddContact_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let peer = Peer(context: context)
        peer.id = UUID()
        peer.timestamp = Date()
        peer.name = "Test Peer"
        peer.summary = "Test Summary"
        
        return AddContact(peer: peer)
            .environment(\.managedObjectContext, context)
    }
}


struct EditContact_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let contact = Contact(context: context)
        contact.id = UUID()
        contact.name = "John Doe"
        contact.phone = "+1234567890"
        contact.telegram = "@johndoe"
        contact.email = "john@exampler.com"
        contact.note = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        
        return EditContact(contact: contact)
            .environment(\.managedObjectContext, context)
    }
}


