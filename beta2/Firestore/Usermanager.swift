//
//  DBUser.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

struct DBUser: Codable, Hashable {
    var uid: String
    var email: String?
    var photoUrl: String?
    var isAnonymous: Bool
    var username: String?

    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case photoUrl
        case isAnonymous
        case username // This line is added to include username in Codable operations
    }

    init(uid: String, email: String?, photoUrl: String?, isAnonymous: Bool, username: String? = nil) {
        self.uid = uid
        self.email = email
        self.photoUrl = photoUrl
        self.isAnonymous = isAnonymous
        self.username = username
    }

    init(auth: AuthDataResultModel) {
        self.uid = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.isAnonymous = auth.isAnonymous
    }
}

final class UserManager {
    static let shared = UserManager()
    
    private let db = Firestore.firestore()
    private init() {}
    private let userCache = DataCache<String, DBUser>()
    
    // Create a new user in the database
    func createNewUser(user: DBUser) async throws {
        let documentRef = db.collection("users").document(user.uid)
        try  documentRef.setData(from: user)
        
        
    }
    
    func fetchCompletedChallenges(forUID uid: String) async throws -> [CompletedChallenge] {
        let challengesCollection = db.collection("users").document(uid).collection("CompletedChallenges")
        let snapshots = try await challengesCollection.getDocuments()
        return snapshots.documents.compactMap { try? $0.data(as: CompletedChallenge.self) }
    }
    
    
    
    
    
    
    
    
    // Update user's photo URL
    func updateUserPhotoURL(uid: String, photoUrl: String) async throws {
        let documentRef = db.collection("users").document(uid)
        try await documentRef.updateData([
            "photoUrl": photoUrl
        ])
    }
    
    func fetchUser(byUID uid: String) async throws -> DBUser {
            if let cachedUser = userCache.value(forKey: uid) {
                return cachedUser
            }
            let docRef = db.collection("users").document(uid)
            let snapshot = try await docRef.getDocument()
            guard let user = try? snapshot.data(as: DBUser.self) else {
                throw NSError(domain: "UserManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode user"])
            }
            userCache.insert(user, forKey: uid)
            return user
        }

}
    
extension UserManager {
    
    // Add a friend to the user's friend list and vice versa
    func addFriend(currentUserID: String, friendID: String) async throws {
        let timestamp = Timestamp(date: Date())
        
        // Add friendID to currentUser's friends list
        try await db.collection("users").document(currentUserID).collection("friends").document(friendID).setData([
            "friendID": friendID,
            "timestamp": timestamp
        ])
        
        // Add currentUserID to friend's friends list
        try await db.collection("users").document(friendID).collection("friends").document(currentUserID).setData([
            "friendID": currentUserID,
            "timestamp": timestamp
            
        ])
    }
    
    // Fetch all friends of a user
    func fetchFriends(for userID: String) async throws -> [DBUser] {
        var friends: [DBUser] = []
        
        let friendDocuments = try await db.collection("users").document(userID).collection("friends").getDocuments()
        
        for document in friendDocuments.documents {
            let friendID = document.documentID
            let friendDocument = try await db.collection("users").document(friendID).getDocument()
            if let friend = try? friendDocument.data(as: DBUser.self) {
                friends.append(friend)
            }
        }
        
        return friends
    }
    
    // Remove a friend from the user's friend list and vice versa
    func removeFriend(currentUserID: String, friendID: String) async throws {
        // Remove friendID from currentUser's friends list
        try await db.collection("users").document(currentUserID).collection("friends").document(friendID).delete()
        
        // Remove currentUserID from friend's friends list
        try await db.collection("users").document(friendID).collection("friends").document(currentUserID).delete()
    }
    
    
    
}
        extension UserManager {
            
            // Update user's username
            func updateUsername(uid: String, username: String) async throws {
                let documentRef = db.collection("users").document(uid)
                try await documentRef.updateData([
                    "username": username
                ])
            }
            
            // Upload profile picture to Firebase Storage
            func uploadProfilePicture(uid: String, imageData: Data) async throws -> URL {
                let storageRef = Storage.storage().reference().child("profile_pictures/\(uid).jpg")
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
                return try await storageRef.downloadURL()
            }
        }

// Extension of your UserManager to handle friend requests
extension UserManager {
    
    // Function to send a friend request
    func sendFriendRequest(from currentUserID: String, to friendID: String) async throws {
        let timestamp = Timestamp(date: Date())
        let friendRequestRef = db.collection("users").document(friendID).collection("friendRequests").document()
        
        try await friendRequestRef.setData([
            "fromUserId": currentUserID,
            "toUserId": friendID,
            "timestamp": timestamp,
            "status": "pending"
        ])
    }
    
    // Function to fetch friend requests
    func fetchFriendRequests(for userID: String) async throws -> [FriendRequest] {
        let querySnapshot = try await db.collection("users").document(userID).collection("friendRequests").whereField("toUserId", isEqualTo: userID).getDocuments()
        
        return querySnapshot.documents.compactMap { document in
            try? document.data(as: FriendRequest.self)
        }
    }
    
    // Function to accept a friend request
    func acceptFriendRequest(_ request: FriendRequest) async throws {
        guard let requestId = request.id else { throw NSError(domain: "", code: -1, userInfo: nil) }
        
        // Update the friend request status to 'accepted'
        let requestRef = db.collection("users").document(request.toUserId).collection("friendRequests").document(requestId)
        try await requestRef.updateData(["status": "accepted"])
        
        // Add each user to the other's friends collection
        try await addFriend(currentUserID: request.toUserId, friendID: request.fromUserId)
    }
    
    // Function to reject a friend request
    func rejectFriendRequest(_ request: FriendRequest) async throws {
        guard let requestId = request.id else { throw NSError(domain: "", code: -1, userInfo: nil) }
        
        // Delete the friend request document
        let requestRef = db.collection("users").document(request.toUserId).collection("friendRequests").document(requestId)
        try await requestRef.delete()
    }
}




    


