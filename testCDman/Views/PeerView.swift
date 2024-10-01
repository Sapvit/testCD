//
//  PeerView.swift
//  testCDman
//
//  Created by Nikolay Khort on 20.02.2024.
//


import Foundation
import SwiftUI


struct PeerView: View {
    @ObservedObject var peer: Peer
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedNoteIndex: IndexSet?
    @State private var showConfirmationAlert = false
    @State private var isShowingContactsPane = true
    @State private var isShowingRightPanel = false
    
    var sortedNotes: [Note] {
        if let notesSet = peer.notes as? Set<Note> {
            return Array(notesSet).sorted { $0.noteTimestamp ?? Date() > $1.noteTimestamp ?? Date() }
        } else { return [] }
    }
    
//    var sortedContacts: [Contact] {
//        if let contactsSet = peer.contacts as? Set<Contact> {
//            return Array(contactsSet).sorted { $0.timestamp ?? Date() > $1.timestamp ?? Date() }
//        } else { return [] }
//    }
    
    var body: some View {
        HStack {
            NavigationStack {
                VStack(alignment: .leading) {
// Old peer info:
/*
//                    HStack(alignment: .center) {
//                        Text("\(peer.category ?? "")")
//                            .italic()
//                        Spacer ()
//                        if ((peer.sourceContact?.isEmpty) == false) { Text("From \(peer.sourceContact ?? "")").italic() }
//                    }
//                    HStack(alignment: .top) {
//                        Text("\(peer.summary ?? "")")
//                        Spacer()
//                        Text("\(peer.timestamp!.formatted(date: .abbreviated, time: .shortened))").italic()
//                            .foregroundColor(.gray)
//                    }
*/
                    
// Old "add peer" and "show peer pane" buttons
/*
                    if isShowingContactsPane && !sortedContacts.isEmpty {
                        Divider()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(sortedContacts) { contact in
                                    NavigationLink(destination: EditContact(contact: contact)) { ContactCard(contact: contact) } } }
                        }
                    }
*/
                    Divider()
                    
                    if peer.notes?.count == 0 {
                        NavigationLink(destination: AddNote(peer: peer)) { ContentUnavailableView(label: {
                            Label("No notes", systemImage: "square.and.pencil").foregroundColor(.black)
                        }, description: { Text("Add one").foregroundColor(.blue) }, actions: { } ) }
                    }
                    else {
                        List {
                            ForEach(sortedNotes, id: \.self) { note in
                                NavigationLink(destination: EditNote(note: note) ) {
                                    VStack(alignment: .leading) {
                                        Text("\(note.noteName ?? "No Name")")
                                            .bold()
                                        Text("\(note.noteSummary ?? "")")
                                        Text("\(note.noteTimestamp!, formatter: DateUtils.dateFormatter)").italic()
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                selectedNoteIndex = indexSet
                                showConfirmationAlert = true
                            }
                            .alert(isPresented: $showConfirmationAlert) {
                                Alert(
                                    title: Text("Delete note"),
                                    message: Text("Are you sure you want to delete this note?"),
                                    primaryButton: .cancel(),
                                    secondaryButton: .destructive(Text("Delete"))
                                    { deleteNote(at: selectedNoteIndex!) }
                                )
                            }
                        }.listStyle(PlainListStyle())
                        .listRowBackground(Color.clear)
                    }
                }.padding(.horizontal)
//                .navigationBarTitle(isShowingRightPanel ? "" : peer.name ?? "", displayMode: .inline)
                .navigationBarTitle(peer.name ?? "", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: AddNote(peer: peer)) {
                        Label("Add note", systemImage: "square.and.pencil") } }
                    /*ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: AddContact(peer: peer)) {
                        Label("Add contact", systemImage: "person.crop.circle.badge.plus") } }
                    if !sortedContacts.isEmpty {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: {
                                isShowingContactsPane.toggle()
                            }) {
                                Image(systemName: isShowingContactsPane ? "person.crop.circle.fill" : "person.crop.circle")
                                    .padding(.trailing)
                            }
                        }
                    }*/
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            isShowingRightPanel.toggle()
                        }) {
                            Image(systemName: "sidebar.right")
                        }
                    }
// Old "edit peer" button
/*
//                        ToolbarItem(placement: .topBarTrailing) {
//                        NavigationLink(destination: EditPeerView(peer: peer)) {
//                        Label("Edit", systemImage: "") } }
     */
                }
            }
            Divider()
            if isShowingRightPanel {
                withAnimation(.easeInOut) {
                    SidebarView(peer: peer)
                        .frame(width: 250)
                        .transition(.move(edge: .trailing))
                }
            }
        }
    }
    
    private func deleteNote(at offsets: IndexSet)
    {
        offsets.forEach { index in
            if let notesSet = peer.notes as? Set<Note> {
                let note = Array(notesSet)[index]
                peer.removeFromNotes(note)
                managedObjectContext.delete(note)
            }
        }
        do { try managedObjectContext.save() }
        catch { print("Error deleting note: \(error)") }
    }
//    private var dateFormatter: DateFormatter {
//            let formatter = DateFormatter()
//            formatter.dateStyle = .medium
//            formatter.timeStyle = .medium
//            return formatter
//    }
    
}

struct SidebarView: View {
    @ObservedObject var peer: Peer
    
    var body: some View {
        VStack { Divider()
            TabView() {
                SidePanePeerInfoView(peer: peer)
                    .tabItem { Label("", systemImage: "info.circle") }
                    .tag(0)
                
                SidePaneContactsView(peer: peer)
                    .tabItem { Label("", systemImage: "person.circle") }
                    .tag(1)
                
                Text(" 🚧 \n Under Construction \n Reminders will be here").multilineTextAlignment(.center)
                    .tabItem { Label("", systemImage: "list.bullet.circle.fill") }
                    .tag(2)
                
                Text(" 🚧 \n Under Construction \n Files will be here").multilineTextAlignment(.center)
                    .tabItem { Label("", systemImage: "paperclip.circle") }
                    .tag(3)
            }
        }
    }
}

#Preview {
    do {
        let context = PersistenceController.preview.container.viewContext
        let peer = Peer(context: context)
        peer.id = UUID()
        peer.timestamp = Date()
        peer.createDate = Date()
        peer.name = "Test name"
        peer.summary = "Test summary"
        peer.category = "Wallet"
        peer.sourceContact = "Peer 34"
        return PeerView(peer: peer)
    }
}

