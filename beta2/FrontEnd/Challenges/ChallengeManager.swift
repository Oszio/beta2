//
//  ChallangeManager.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-12.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

final class ChallengeManager {
    static let shared = ChallengeManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Fetch all categories
    func fetchCategories() async throws -> [ChallengeCategory] {
        let querySnapshot = try await db.collection("categories").getDocuments()
        return querySnapshot.documents.compactMap { try? $0.data(as: ChallengeCategory.self) }
    }
    
    // Fetch challenges for a specific category up to a certain sequence
    func fetchChallenges(inCategory categoryID: String, upToSequence sequence: Int) async throws -> [Challenge] {
        let query = db.collection("categories").document(categoryID).collection("challenges")
            .whereField("sequence", isLessThanOrEqualTo: sequence)
            .order(by: "sequence")
        
        let querySnapshot = try await query.getDocuments()
        return querySnapshot.documents.compactMap { try? $0.data(as: Challenge.self) }
    }
    
    // Upload a new challenge to a specific category
    func uploadChallenge(_ challenge: Challenge, toCategory categoryID: String) async throws {
        let documentRef = db.collection("categories").document(categoryID).collection("challenges").document(challenge.id)
        try  documentRef.setData(from: challenge)
    }
    
    // Fetch completed challenges for a user
    func fetchCompletedChallenges(for userId: String) async throws -> [CompletedChallenge] {
        let challengesCollectionRef = db.collection("users").document(userId).collection("CompletedChallenges")
        let snapshots = try await challengesCollectionRef.getDocuments()
        return snapshots.documents.compactMap { try? $0.data(as: CompletedChallenge.self) }
    }
    
    // Mark a challenge as completed for a user with evidence details
    func completeChallenge(_ challengeID: String, for userID: String, inCategory categoryID: String, evidenceId: String, imageUrl: String, comment: String) async throws {
        let documentRef = db.collection("users").document(userID).collection("CompletedChallenges").document(challengeID)

        let completedChallengeData: [String: Any] = [
            "challengeID": challengeID,
            "categoryID": categoryID,
            "evidenceId": evidenceId,
            "imageUrl": imageUrl,
            "comment": comment
        ]
        
        try await documentRef.setData(completedChallengeData)
    }
    
    // Fetch a single challenge by its ID
    func fetchChallenge(byID challengeID: String, inCategory categoryID: String) async throws -> Challenge? {
        let documentRef = db.collection("categories").document(categoryID).collection("challenges").document(challengeID)
        let snapshot = try await documentRef.getDocument()
        return try? snapshot.data(as: Challenge.self)
    }

}
