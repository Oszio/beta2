//
//  FriendListView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-19.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Friend: Identifiable, Codable {
    var id: String
    var friendID: String
    var timestamp: Timestamp
    var email: String?
    var photoUrl: String?
}

struct FriendDocument: Codable {
    var friendID: String
    var timestamp: Timestamp
}

struct FriendListView: View {
    @State private var friends: [Friend] = []
    @State private var isLoading: Bool = true
    
    var body: some View {
           NavigationView {
               List(friends) { friend in
                   NavigationLink(destination: FriendProfileView(friend: friend)) {
                       HStack {
                           if let url = friend.photoUrl, let imageUrl = URL(string: url) {
                               AsyncImage(url: imageUrl) { image in
                                   image.resizable()
                               } placeholder: {
                                   ProgressView()
                               }
                               .frame(width: 50, height: 50)
                               .clipShape(Circle())
                           } else {
                               Image(systemName: "person.circle.fill")
                                   .resizable()
                                   .frame(width: 50, height: 50)
                                   .foregroundColor(.gray)
                           }
                           Text(friend.email ?? "No Email")
                       }
                   }
               }
               .navigationBarTitle("Friends", displayMode: .inline)
               .onAppear(perform: loadFriends)
           }
       }
    
    func loadFriends() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        Task {
            do {
                let dbUsers = try await UserManager.shared.fetchFriends(for: currentUserID)
                // Convert DBUser objects to Friend objects
                self.friends = dbUsers.map { Friend(from: $0, friendDocument: FriendDocument(friendID: $0.uid, timestamp: Timestamp(date: Date()))) }
            } catch {
                print("Error fetching friends: \(error.localizedDescription)")
            }
        }
    }
}

extension Friend {
    init(from dbUser: DBUser, friendDocument: FriendDocument) {
        self.id = friendDocument.friendID
        self.friendID = friendDocument.friendID
        self.timestamp = friendDocument.timestamp
        self.email = dbUser.email
        self.photoUrl = dbUser.photoUrl
    }
}
