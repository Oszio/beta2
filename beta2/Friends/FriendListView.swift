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
    var username: String?
}

struct FriendDocument: Codable {
    var friendID: String
    var timestamp: Timestamp
}

struct FriendListView: View {
    let uid: String
    @State private var friends: [Friend] = []
    @State private var isLoading: Bool = true
    
    @State private var userInfo: UserInfo?
    @State private var usernameFromInfo: String = ""
    
    var body: some View {
           NavigationView {
               List(friends) { friend in
                   NavigationLink(destination: FriendProfileView(uid: uid, friend: friend)) {
                       FriendProfileInfoRow (friend: friend)
                   }
               }

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
        self.username = dbUser.username
    }
}
