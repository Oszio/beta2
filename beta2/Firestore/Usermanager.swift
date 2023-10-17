//
//  DBUser.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser: Codable {
    var uid: String
    var email: String?
    var photoUrl: String?
    var isAnonymous: Bool

    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case photoUrl = "photoUrl"
        case isAnonymous
    }

    init(uid: String, email: String?, photoUrl: String?, isAnonymous: Bool) {
        self.uid = uid
        self.email = email
        self.photoUrl = photoUrl
        self.isAnonymous = isAnonymous
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

    // Create a new user in the database
    func createNewUser(user: DBUser) async throws {
        let documentRef = db.collection("users").document(user.uid)
        try await documentRef.setData(from: user)
        
        
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

    // Fetch a user from the database
    func fetchUser(byUID uid: String) async throws -> DBUser? {
        let documentRef = db.collection("users").document(uid)
        let snapshot = try await documentRef.getDocument()

        // Debugging: Print the raw data
        print("Raw data from Firestore: \(String(describing: snapshot.data()))")

        let user = try snapshot.data(as: DBUser.self)

        // Debugging: Print the decoded user
        print("Decoded user: \(String(describing: user))")

        return user
    }
    
    
}

