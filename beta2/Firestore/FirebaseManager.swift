//
//  FirebaseManager.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-25.
//

// FirebaseManager.swift

import FirebaseFirestore
import FirebaseStorage
import UIKit

struct CompletedChallenge: Codable {
    var challengeID: String
    var evidenceId: String
    var imageUrl: String
    var comment: String
    var categoryId: String
    
    
    
    enum CodingKeys: String, CodingKey {
        case challengeID = "challengeID"
        case evidenceId
        case imageUrl
        case comment
        case categoryId
        
    }
}

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func uploadEvidence(userId: String, image: UIImage, comment: String, challengeID: String, categoryId: String,  completion: @escaping (Result<(String, String), Error>) -> Void) {
        let storageRef = storage.reference().child("evidence/\(challengeID).jpg")
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
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
        let evidenceCollectionRef = db.collection("evidence")

        let evidenceData: [String: Any] = [
            "userId": userId,
            "challengeID": challengeID,
            "comment": comment,
            "imageUrl": imageUrl,
            "categoryId": categoryId
        ]

        evidenceCollectionRef.addDocument(data: evidenceData) { error in
            if let error = error {
                print("Error adding evidence to Firestore: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            // Return both the evidenceId and the imageUrl
            completion(.success((challengeID, imageUrl)))
        }
    }
    
    
    func fetchEvidence(for userId: String, challengeID: String) async throws -> CompletedChallenge {
        let docRef = db.collection("users").document(userId).collection("CompletedChallenges").document(challengeID)
        let snapshot = try await docRef.getDocument()
        
        guard let data = snapshot.data() else {
            throw NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch evidence data"])
        }
        
        guard
            let fetchedChallengeID = data["challengeID"] as? String,
            let evidenceId = data["evidenceId"] as? String,
            let imageUrl = data["imageUrl"] as? String,
            let comment = data["comment"] as? String,
            let categoryId = data["categoryId"] as? String // Add this line
        else {
            throw NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Incomplete evidence data"])
        }
        
        return CompletedChallenge(challengeID: fetchedChallengeID, evidenceId: evidenceId, imageUrl: imageUrl, comment: comment, categoryId: categoryId)
    }

    
    func fetchCompletedChallenges(forUID uid: String) async throws -> [CompletedChallenge] {
        let challengesCollection = db.collection("users").document(uid).collection("CompletedChallenges")
        let snapshots = try await challengesCollection.getDocuments()
        return snapshots.documents.compactMap { try? $0.data(as: CompletedChallenge.self) }
    }
}

