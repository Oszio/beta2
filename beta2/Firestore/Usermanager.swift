//
//  DBUser.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


struct DBUser {
    let uid: String
    let email: String?
    let photoUrl: String?
    let isAnonymous: Bool
    var evidence: [String]?

    init(uid: String, email: String?, photoUrl: String?, isAnonymous: Bool, evidence:  [String]?) {
        self.uid = uid
        self.email = email
        self.photoUrl = photoUrl
        self.isAnonymous = isAnonymous
        self.evidence = evidence
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

    private let db = Firestore.firestore()  // Assuming you're using Firestore
    private init() {}

    // Create a new user in the database
    func createNewUser(user: DBUser) async throws {
        let documentRef = db.collection("users").document(user.uid)
        try await documentRef.setData([
            "email": user.email,
            "photoUrl": user.photoUrl,
            "isAnonymous": user.isAnonymous,
            "evidence": user.evidence ?? []
       
        ])
    }
    
    // Fetch a user from the database
    func fetchUser(byUID uid: String) async throws -> DBUser? {
        let documentRef = db.collection("users").document(uid)
        let snapshot = try await documentRef.getDocument()
        guard let data = snapshot.data() else { return nil }
        
        return DBUser(
            uid: uid,
            email: data["email"] as? String,
            photoUrl: data["photoUrl"] as? String,
            isAnonymous: data["isAnonymous"] as? Bool ?? false,
            evidence: data["evidence"] as? [String]
        )
    }
    
    func updateUserPhotoURL(uid: String, photoUrl: String) async throws {
        let documentRef = db.collection("users").document(uid)
        try await documentRef.updateData([
            "photoUrl": photoUrl
        ])
        
    }
    
    func addUserEvidence(uid: String, imageUrl: String) async throws {
        let documentRef = db.collection("users").document(uid)
        try await documentRef.updateData([
            "evidence": FieldValue.arrayUnion([imageUrl])
        ])
    }

}
