//
//  ContentView.swift
//  testCDman
//
//  Created by Nikolay Khort on 08.02.2024.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.timestamp, order: .reverse)]) var peer: FetchedResults<Peer>
    //all that's needed to retrieve the data from the database
    @State private var showConfirmationAlert = false
    @State private var selectedPeerIndex: IndexSet?
    @State private var creatingFirstPeer = false
    
    var body: some View {
        NavigationSplitView {
            List {
                let groupedPeers = Dictionary(grouping: peer) { $0.category ?? "" }
                ForEach(groupedPeers.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category)) {
                        // Iterate over the peers in the current category
                        ForEach(groupedPeers[category] ?? []) { peer in
                            NavigationLink(destination: PeerView(peer: peer)) {
                                Text(peer.name ?? "")
                            }
                        }
                    }
                }
//                        ForEach(peer) { peer in
//                            NavigationLink { PeerView(peer: peer) }
//                        label: { Text(peer.name!) }
//                }
                .onDelete { indexSet in
                    selectedPeerIndex = nil
// Navigate away from detail view - added with chatGPT, to review from here
                    selectedPeerIndex = indexSet
                    showConfirmationAlert = true
                }
                .alert(isPresented: $showConfirmationAlert) {
                    Alert(
                        title: Text("Delete Peer"),
                        message: Text("Are you sure you want to delete this peer?"),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text("Delete"))
                        { deletePeer(at: selectedPeerIndex!) }
                    )
                }
// Need to add state to return Home or to next item after delete (now it stays with earlier selected item)
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .primaryAction)
                { NavigationLink(destination: HomeView())
                    { Label("Home", systemImage: "house") }
                }
                ToolbarItem
                { NavigationLink(destination: AddPeerView())
                    { Label("Add peer", systemImage: "plus") }
                }
            }
            .overlay {
                if peer.isEmpty && !creatingFirstPeer {
                    Button(action: {creatingFirstPeer = true}, label: { ContentUnavailableView(label: {
                        Label("No peers", systemImage: "plus.app").foregroundColor(.black) }, description: { Text("Add one").foregroundColor(.blue) }, actions: { }
                    ) } )
                }
            }.navigationDestination(isPresented: $creatingFirstPeer) { AddPeerView() }
        } detail: { }
    }
    
    private func deletePeer(at offsets: IndexSet) {
        offsets.forEach { index in
            let peer = peer[index]
            managedObjectContext.delete(peer)
        }
        do { try managedObjectContext.save() }
        catch { print("Error deleting peer: \(error)") }
    }
}


#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}


struct HomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.timestamp, order: .reverse)]) var peer: FetchedResults<Peer>
    
    var body: some View {
        Text("Hi")
        Text("Peers count: \(peer.count)")
            .foregroundColor(.gray)
    }
}
