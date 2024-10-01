//
//  AddNoteView.swift
//  testCDman
//
//  Created by Nikolay Khort on 23.02.2024.
//

import Foundation
import SwiftUI

struct AddNote: View {
    @ObservedObject var peer: Peer
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showConfirmationAlert = false
    
    @State private var name: String = ""
    @State private var summary: String = ""
    @State private var text: String = ""
    
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Add name", text: $name)
                    .padding(.bottom)
                TextField("Add summary", text: $summary)
                    .padding(.bottom)
                Divider()
                TextEditor(text: $text)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .frame(maxHeight: .infinity)
            }
            .padding()
            .navigationBarTitle("New note", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if hasChanges() {
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
                        if name.isEmpty {
                            name = "No note name"
                        }
                        let note = Note(context: managedObjectContext)
                        note.noteID = UUID()
                        note.noteName = name
                        note.noteSummary = summary
                        note.noteText = text
                        note.noteCreateDate = Date()
                        note.noteTimestamp = Date()
                        peer.addToNotes(note)
                        peer.timestamp = Date()
                        dismiss()
                    }
                }
            }
        }
        
    }
    private func hasChanges() -> Bool {
        return !name.isEmpty || !summary.isEmpty || !text.isEmpty
    }
}


struct EditNote: View {
    @ObservedObject var note: Note
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var summary: String
    @State private var text: String
    @State private var showConfirmationAlert = false
    
    init(note: Note) {
        self.note = note
        _name = State(initialValue: note.noteName ?? "")
        _summary = State(initialValue: note.noteSummary ?? "")
        _text = State(initialValue: note.noteText ?? "")
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Edit name", text: $name)
                    .padding(.bottom)
                TextField("Edit summary", text: $summary)
                    .padding(.bottom)
                Divider()
                TextEditor(text: $text)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .frame(maxHeight: .infinity)
            }
            .padding()
            .navigationBarTitle("Edit note", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if hasChanges() {
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
                        note.noteName = name.isEmpty ? "No note name" : name
                        note.noteSummary = summary
                        note.noteText = text
                        note.noteTimestamp = Date()
                        do {
                            try managedObjectContext.save()
                            if let peer = note.peer {
                                peer.timestamp = Date()
                            }
                            dismiss()
                        } catch { print("Error saving note: \(error)") }
                    }
                }
            }
        }
        
    }
    
    private func hasChanges() -> Bool {
        return name != (note.noteName ?? "") || summary != (note.noteSummary ?? "") || text != (note.noteText ?? "")
    }
}



struct AddNote_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let peer = Peer(context: context)
        peer.id = UUID()
        peer.timestamp = Date()
        peer.name = "Test Peer"
        peer.summary = "Test Summary"
        
        return AddNote(peer: peer)
            .environment(\.managedObjectContext, context)
    }
}


struct EditNote_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let note = Note(context: context)
        note.noteID = UUID()
        note.noteName = "Test Note"
        note.noteSummary = "Test Summary"
        note.noteText = longLoremIpsum
        return EditNote(note: note)
            .environment(\.managedObjectContext, context)
    }
}


//#Preview {
//    let context = PersistenceController.preview.container.viewContext
//    let peer = Peer(context: context)
//    return AddNote(peer: peer)
//}
