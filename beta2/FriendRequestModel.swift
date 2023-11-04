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
@MainActor
class FriendRequestViewModel: ObservableObject {
    @Published var incomingRequests: [DBUser] = []
    @Published var errorMessage: String?
    private let db = Firestore.firestore()
    
    // Fetch incoming friend requests
    func fetchFriendRequests(userId: String) {
        let friendRequestsRef = db.collection("users").document(userId).collection("friendRequests").whereField("toUserId", isEqualTo: userId).whereField("status", isEqualTo: "pending")

        friendRequestsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                self.errorMessage = "There was an error fetching friend requests: \(error.localizedDescription)"
                return
            }

            let group = DispatchGroup()
            var users: [DBUser] = []

            for document in querySnapshot?.documents ?? [] {
                group.enter()
                defer { group.leave() } // Ensure we always leave the group
                let friendRequest = try? document.data(as: FriendRequest.self)
                if let fromUserId = friendRequest?.fromUserId {
                    self.db.collection("users").document(fromUserId).getDocument { (userDoc, error) in
                        if let user = try? userDoc?.data(as: DBUser.self) {
                            users.append(user)
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                self.incomingRequests = users
            }
        }
    }

    // Accept a friend request
    // Accept a friend request
    func acceptFriendRequest(request: FriendRequest) async {
        guard let requestId = request.id else {
            self.errorMessage = "Invalid request ID."
            return
        }
        
        do {
            let requestRef = db.collection("users").document(request.toUserId).collection("friendRequests").document(requestId)
            
            // Update the friend request status to 'accepted'
            try await requestRef.updateData(["status": "accepted"])
            
            // Add each user to the other's friends collection
            try await UserManager.shared.addFriend(currentUserID: request.toUserId, friendID: request.fromUserId)
            
            // Refresh the list after accepting
            await fetchFriendRequests(userId: request.toUserId)
        } catch {
            self.errorMessage = "Error processing friend request: \(error.localizedDescription)"
        }
    }

    func rejectFriendRequest(request: FriendRequest) async {
        guard let requestId = request.id else {
            self.errorMessage = "Invalid request ID."
            return
        }

        do {
            let requestRef = db.collection("users").document(request.toUserId).collection("friendRequests").document(requestId)
            // Delete the friend request document
            try await requestRef.delete()
            // Refresh the list after rejecting
            await fetchFriendRequests(userId: request.toUserId)
        } catch {
            self.errorMessage = "Error processing friend request: \(error.localizedDescription)"
        }
    }

    
  
    
    // Lookup users by their IDs
    private func lookupUsersById(userIds: [String]) {
        // Similar to above, fetch each user by their ID and add to the incomingRequests
    }
}
