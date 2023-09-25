//
//  FirebaseManager.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-25.
//

// FirebaseManager.swift

import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {
    // Singleton instance
    static let shared = FirebaseManager()

    // Firebase services
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // MARK: - Evidence Upload

    /// Uploads evidence image to Firebase Storage and updates Firestore.
    /// - Parameters:
    ///   - imuage: The image to upload.
    ///   - comment: Comment associated with the evidence.
    ///   - challengeId: The ID of the challenge to associate the evidence with.
    func uploadEvidence(image: UIImage, comment: String, challengeId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        // 1. Upload image to Firebase Storage
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

                // 2. Once upload is successful, update Firestore with evidence details
                self.updateFirestoreWithEvidence(challengeId: challengeId, comment: comment) { result in
                    switch result {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }


    // MARK: - Firestore Interaction

    /// Updates Firestore with evidence details.
    /// - Parameters:
    ///   - challengeId: The ID of the challenge to associate the evidence with.
    ///   - comment: Comment associated with the evidence.
    private func updateFirestoreWithEvidence(challengeId: Int, comment: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let evidenceDocRef = db.collection("evidence").document("\(challengeId)")

        let evidenceData: [String: Any] = [
            "comment": comment,
            // Add other evidence-related fields as needed
        ]

        evidenceDocRef.setData(evidenceData, merge: true) { error in
            if let error = error {
                print("Error updating Firestore with evidence: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            print("Firestore updated with evidence details.")
            completion(.success(()))
        }
    }


    // Add more Firestore-related functions as needed (e.g., fetching data).

    // ...
}
