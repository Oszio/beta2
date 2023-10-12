//
//  FirebaseManager.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-25.
//

// FirebaseManager.swift

import FirebaseFirestore
import FirebaseStorage

struct CompletedChallenge: Codable {
    var challengeId: String
    var comment: String
    var imageUrl: String

}

class FirebaseManager {
    // Singleton instance
    static let shared = FirebaseManager()
    
    // Firebase services
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // MARK: - Evidence Upload
    
    func uploadEvidence(userId: String, image: UIImage, comment: String, challengeId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let storageRef = storage.reference().child("evidence/\(challengeId).jpg")
        
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
                        self.addCompletedChallengeToUser(userId: userId, challengeId: challengeId, comment: comment, imageUrl: downloadURL, completion: completion)
                    }
                }
            }
        }
    }
    
    func fetchEvidence(for userId: String, challengeId: String) async throws -> CompletedChallenge {
        let docRef = db.collection("users").document(userId).collection("CompletedChallenges").document(challengeId)
        let snapshot = try await docRef.getDocument()
        
        guard let data = snapshot.data() else {
            throw NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch evidence data"])
        }
        
        let challengeId = data["challengeId"] as? String ?? ""
        let comment = data["comment"] as? String ?? ""
        let imageUrl = data["imageUrl"] as? String ?? ""
        
        return CompletedChallenge(challengeId: challengeId, comment: comment, imageUrl: imageUrl)
    }
    
    func fetchCompletedChallenges(forUID uid: String) async throws -> [CompletedChallenge] {
        let challengesCollection = db.collection("users").document(uid).collection("CompletedChallenges")
        let snapshots = try await challengesCollection.getDocuments()
        return snapshots.documents.compactMap { try? $0.data(as: CompletedChallenge.self) }
    }



    
    private func addCompletedChallengeToUser(userId: String, challengeId: String, comment: String, imageUrl: String, completion: @escaping (Result<String, Error>) -> Void) {
        let challengeDocRef = db.collection("users").document(userId).collection("CompletedChallenges").document(challengeId)
        
        let completedChallengeData: [String: Any] = [
            "challengeId": challengeId,
            "comment": comment,
            "imageUrl": imageUrl
        ]
        
        challengeDocRef.setData(completedChallengeData) { error in
            if let error = error {
                print("Error adding completed challenge to user: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("Completed challenge added to user.")
            completion(.success(imageUrl))
        }
    }
}
