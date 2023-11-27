//
//  FirebaseManager.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-25.
//

import FirebaseFirestore
import FirebaseStorage
import UIKit

struct CompletedChallenge: Codable, Identifiable {
    var id: String { challengeID }
    var categoryID: String
    var challengeID: String
    var comment: String
    var evidenceId: String
    var imageUrl: String
    var completionTime: Date // This will store the completion time
    var points: Int // Add this line
}

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func uploadEvidence(userId: String, image: UIImage, comment: String, challengeID: String, categoryId: String,  completion: @escaping (Result<(String, String), Error>) -> Void) {
        // Use a unique identifier for image naming
        let uniqueImageName = "\(userId)_\(challengeID).jpg"
        let storageRef = storage.reference().child("evidence/\(uniqueImageName)")
        
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            storageRef.putData(imageData, metadata: metadata) { (_, error) in
                if let error = error {
                    print("Error uploading evidence image: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    
                    if let downloadURL = url?.absoluteString {
                        self.addEvidenceToFirestore(userId: userId, challengeID: challengeID, comment: comment, imageUrl: downloadURL, categoryId: categoryId, completion: completion)
                    }
                }
            }
        }
    }
    
    private func addEvidenceToFirestore(userId: String, challengeID: String, comment: String, imageUrl: String, categoryId: String, completion: @escaping (Result<(String, String), Error>) -> Void) {
        // Save to the "CompletedChallenges" sub-collection for consistency
        let evidenceCollectionRef = db.collection("users").document(userId).collection("CompletedChallenges")

        let evidenceData: [String: Any] = [
            "userId": userId,
            "challengeID": challengeID,
            "comment": comment,
            "imageUrl": imageUrl,
            "categoryId": categoryId,
            "completionTime": Timestamp(date: Date()) // Use Timestamp to store the current time
        ]

        evidenceCollectionRef.document(challengeID).setData(evidenceData) { error in
            if let error = error {
                print("Error adding evidence to Firestore: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            completion(.success((challengeID, imageUrl)))
        }
    }
    
    func fetchEvidence(for userId: String, challengeID: String) async throws -> CompletedChallenge {
        let docRef = db.collection("users").document(userId).collection("CompletedChallenges").document(challengeID)
        let snapshot = try await docRef.getDocument()
        
        // Simplify data decoding using Firestore's .data(as:) method
        guard let completedChallenge = try? snapshot.data(as: CompletedChallenge.self) else {
            throw NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode evidence data"])
        }
        return completedChallenge
    }

    func fetchCompletedChallenges(forUID uid: String) async throws -> [CompletedChallenge] {
        let challengesCollection = db.collection("users").document(uid).collection("CompletedChallenges")
            .order(by: "completionTime", descending: true) // Corrected to `order(by:)`
        let snapshots = try await challengesCollection.getDocuments()

        for document in snapshots.documents {
            print("Raw data for challenge: \(document.data())")
        }

        return snapshots.documents.compactMap { try? $0.data(as: CompletedChallenge.self) }
    }

    
    func fetchSpecificChallenge(forUID uid: String) async {
        let specificChallengeDocRef = db.collection("users").document(uid).collection("CompletedChallenges").document("487F57A5-24CE-4E63-B798-C3BDECBEAF80")
        do {
            let snapshot = try await specificChallengeDocRef.getDocument()
            print("Specific challenge data: \(String(describing: snapshot.data()))")
        } catch {
            print("Error fetching specific challenge: \(error)")
        }
    }
    
    func fetchFriendComments(userId: String, completedChallengeID: String) async throws -> [FriendComment] {
        let commentsCollection = db.collection("users").document(userId)
                                   .collection("CompletedChallenges").document(completedChallengeID)
                                   .collection("FriendComments").order(by: "timestamp", descending: false)

        let snapshot = try await commentsCollection.getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: FriendComment.self)
        }
    }

    func postFriendComment(userId: String, completedChallengeID: String, comment: FriendComment) async throws {
        let commentRef = db.collection("users").document(userId)
                           .collection("CompletedChallenges").document(completedChallengeID)
                           .collection("FriendComments").document()
        try await commentRef.setData(from: comment)
    }



}
