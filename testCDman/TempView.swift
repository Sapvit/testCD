//
//  TempView.swift
//  testCDman
//
//  Created by Nikolay Khort on 29.02.2024.
//

import SwiftUI


struct Bookmark: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    var items: [Bookmark]?

    // some example websites
    static let apple = Bookmark(name: "Apple", icon: "1.circle")
    static let bbc = Bookmark(name: "BBC", icon: "square.and.pencil")
    static let swift = Bookmark(name: "Swift", icon: "bolt.fill")
    static let twitter = Bookmark(name: "Twitter", icon: "mic")

    // some example groups
    static let example1 = Bookmark(name: "Favorites", icon: "star", items: [Bookmark.apple, Bookmark.bbc, Bookmark.swift, Bookmark.twitter])
    static let example2 = Bookmark(name: "Recent", icon: "timer", items: [Bookmark.apple, Bookmark.bbc, Bookmark.swift, Bookmark.twitter])
    static let example3 = Bookmark(name: "Recommended", icon: "hand.thumbsup", items: [Bookmark.apple, Bookmark.bbc, Bookmark.swift, Bookmark.twitter])
}

struct ContentView2: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.timestamp, order: .reverse)]) var peer: FetchedResults<Peer>
    @FetchRequest(sortDescriptors: []) var peerNK: FetchedResults<Peer>
    
    
    let items2: [Bookmark] = [.example1, .example2, .example3]

    var body: some View {
       
            List {
                let groupedPeers = Dictionary(grouping: peer) { $0.name ?? "" }
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
            }

        
            List(items2, children: \.items) { row in
                HStack {
                    Image(systemName: row.icon)
                    Text(row.name)
                }
            }
    }
}

//
//struct TempView: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//#Preview {
//    ContentView2()
//}



#Preview {
    let context = PersistenceController.preview.container.viewContext
    let peer1 = Peer(context: context)
    peer1.name = "Peer 1"
    peer1.category = "Category A"
    
    let peer2 = Peer(context: context)
    peer2.name = "Peer 2"
    peer2.category = "Category A"
    
    let peer3 = Peer(context: context)
    peer3.name = "Peer 3"
    peer3.category = "Category B"
    
    let peer4 = Peer(context: context)
    peer4.name = "Peer 4"
    peer4.category = "Category B"
    
    let peer5 = Peer(context: context)
    peer5.name = "Peer 5"
    peer5.category = "Category C"
    
    return ContentView2()
        .environment(\.managedObjectContext, context)
}
