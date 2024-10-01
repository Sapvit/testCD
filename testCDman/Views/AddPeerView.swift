//
//  AddPeerView.swift
//  testCDman
//
//  Created by Nikolay Khort on 08.02.2024.
//

import Foundation
import SwiftUI

struct AddPeerView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var summary: String = ""
    @State private var category: String = ""
    @State private var sourceContact: String = ""
    @State private var showConfirmationAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Peer")) {
                    TextField("Peer name", text: $name)
                    TextField("Peer category", text: $category)
                    TextField("Source contact", text: $sourceContact)
                    TextField("Peer summary", text: $summary)
                }
            }.navigationBarTitle("New peer", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if !name.isEmpty || !summary.isEmpty {
                            showConfirmationAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .alert(isPresented: $showConfirmationAlert) {
                        Alert(
                            title: Text("Are you sure you want to discard the changes?"),
                            primaryButton: .default(Text("Keep editing")),
                            secondaryButton: .destructive(Text("Discard")) {
                                dismiss()
                            }
                        )
                    }
                }
                ToolbarItem() {
                    Button("Save") {
                        let peerName = name.isEmpty ? "No peer name" : name
                        DataController().addPeer(name: peerName, summary: summary, category: category, sourceContact: sourceContact, context: managedObjectContext)
                        dismiss()
                    }
                }
            }
        }
    }
}



struct EditPeerView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var peer: Peer
    
    @State private var name: String
    @State private var summary: String
    @State private var category: String
    @State private var sourceContact: String
    @State private var showConfirmationAlert = false
    
    init(peer: Peer) {
            self.peer = peer
            _name = State(initialValue: peer.name ?? "")
            _summary = State(initialValue: peer.summary ?? "")
            _category = State(initialValue: peer.category ?? "")
            _sourceContact = State(initialValue: peer.sourceContact ?? "")
        }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Peer name", text: $name)
                    TextField("Peer category", text: $category)
                    TextField("Source contact", text: $sourceContact)
                    TextField("Peer summary", text: $summary)
                }
            }.navigationBarTitle("Edit \(name)", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { if hasChanges() {
                        showConfirmationAlert = true
                        } else { dismiss() }
                    }
                    .alert(isPresented: $showConfirmationAlert) {
                        Alert(
                            title: Text("Are you sure you want to discard the changes?"),
                            primaryButton: .default(Text("Keep editing")),
                            secondaryButton: .destructive(Text("Discard")) {
                                dismiss()
                            }
                        )
                    }
                }
                ToolbarItem() {
                    Button("Save") {
                        savePeer()
                    }
                }
            }
        }
    }
    
    private func hasChanges() -> Bool {
            // Check if there are any changes compared to the initial values
            return name != (peer.name ?? "") || summary != (peer.summary ?? "")
        }
    
    private func savePeer() {
        peer.name = name.isEmpty ? "No peer name" : name
        peer.summary = summary
        peer.category = category
        peer.sourceContact = sourceContact
        peer.timestamp = Date()
        do {
            try managedObjectContext.save()
            dismiss()
        }
        catch { }
    }
    
}



struct AddPeerView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return AddPeerView()
            .environment(\.managedObjectContext, context)
    }
}

struct EditPeerView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let peer = Peer(context: context)
        peer.name = "Test Peer"
        peer.summary = "Test Summary"
        
        return EditPeerView(peer: peer)
            .environment(\.managedObjectContext, context)
    }
}
