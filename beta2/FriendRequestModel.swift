//
//  FriendRequestModel.swift
//  beta2
//
//  Created by Oskar Almå on 2023-11-02.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct FriendRequest: Codable, Identifiable {
    @DocumentID var id: String?
    var fromUserId: String
    var toUserId: String
    var timestamp: Timestamp
    var status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fromUserId
        case toUserId
        case timestamp
        case status
    }
}

class FriendRequestViewModel: ObservableObject {
    @Published var incomingRequests: [DBUser] = []
    @Published var errorMessage: String?

    func fetchFriendRequests(userId: String) {
        let db = Firestore.firestore()
        let friendRequestsRef = db.collection("friendRequests").document(userId)

        friendRequestsRef.getDocument { (document, error) in
            if let error = error {
                self.errorMessage = "There was an error fetching friend requests: \(error.localizedDescription)"
                return
            }

            if let document = document, document.exists, let requestData = document.data() {
                let userIds = requestData["incomingRequests"] as? [String] ?? []
                self.lookupUsersById(userIds: userIds)
            } else {
                self.errorMessage = "No friend requests found."
            }
        }
    }

    private func lookupUsersById(userIds: [String]) {
        // Lookup each user by ID and append to incomingRequests
        // This might involve fetching each user document from your users collection
    }
}

