//
//  FirebaseManager.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-25.
//

// FirebaseManager.swift

import FirebaseFirestore
import FirebaseStorage

struct Evidence {
    var comment: String
    var imageUrl: String
    // Add other fields as needed
}


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
    func uploadEvidence(image: UIImage, comment: String, challengeId: Int, completion: @escaping (Result<String, Error>) -> Void) {
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
                
                // 2. Get download URL
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    
                    if let downloadURL = url?.absoluteString {
                        // 3. Once upload is successful and download URL is retrieved, update Firestore with evidence details
                        self.updateFirestoreWithEvidence(challengeId: challengeId, comment: comment, imageUrl: downloadURL) { result in
                            switch result {
                            case .success:
                                completion(.success(downloadURL))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func updateFirestoreWithEvidence(challengeId: Int, comment: String, imageUrl: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let evidenceDocRef = db.collection("evidence").document("\(challengeId)")
        
        let evidenceData: [String: Any] = [
            "comment": comment,
            "imageUrl": imageUrl
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
    
    func fetchEvidence(for challengeId: Int, completion: @escaping (Result<Evidence, Error>) -> Void) {
        let evidenceDocRef = db.collection("evidence").document("\(challengeId)")
        
        evidenceDocRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching evidence: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
                let comment = data["comment"] as? String ?? ""
                let imageUrl = data["imageUrl"] as? String ?? ""
                
                let evidence = Evidence(comment: comment, imageUrl: imageUrl)
                completion(.success(evidence))
            } else {
                print("Document does not exist")
                completion(.failure(NSError(domain: "com.yourapp", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
            }
        }
    }

}
