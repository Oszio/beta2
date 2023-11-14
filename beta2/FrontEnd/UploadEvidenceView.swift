//
//  UploadEvidenceView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-03.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct UploadEvidenceView: View {
    @State private var selectedImage: UIImage?
    @State private var comment: String = ""
    @State private var isImagePickerPresented: Bool = false
    @State private var isLoading: Bool = false
    @State private var uploadSuccess: Bool = false
    @State private var errorMessage: String?
    @State private var userId: String?
    @State private var categoryId: String
    
    @State private var showImagePicker: Bool = false
    @State private var showImageSourceSelectionActionSheet: Bool = false
    @State private var showImageSourceSelection: Bool = true
    
    @Binding var uploadedImage: UIImage?

    
    var challenge: Challenge
    
    var body: some View {
        VStack(spacing: 20) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray)
            }
            
            Button("Select Image") {
                showImageSourceSelectionActionSheet = true
            }
            .actionSheet(isPresented: $showImageSourceSelectionActionSheet) {
                ActionSheet(
                    title: Text("Select Image Source"),
                    buttons: [
                        .default(Text("Camera")) {
                            showImagePicker = true
                            showImageSourceSelection = false
                        },
                        .default(Text("Photo Album")) {
                            showImagePicker = true
                            showImageSourceSelection = true
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage, showImageSourceSelection: $showImageSourceSelection)
            }
            
            TextField("Add a comment...", text: $comment)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            if isLoading {
                ProgressView("Uploading...")
            } else {
                Button("Upload Evidence") {
                    uploadEvidence()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            if uploadSuccess {
                Text("Evidence uploaded successfully!")
                    .foregroundColor(.green)
            }
            
        }
        .onAppear {
            fetchUserId()
            
        }
        .padding()
    }
    
    func uploadEvidence() {
        guard let image = selectedImage, let userId = userId else {
            errorMessage = "Please select an image or user is not authenticated."
            return
        }
        
        isLoading = true
        
        FirebaseManager.shared.uploadEvidence(userId: userId, image: image, comment: comment,  challengeID: "\(challenge.id)", categoryId:categoryId) { result in
            isLoading = false
            switch result {
            case .success:
                uploadSuccess = true
                uploadedImage = image // Update the evidence image
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
            
            
        }
    }
    
    func fetchUserId() {
        do {
            let user = try AuthenticationManager.shared.getAuthenticatedUser()
            userId = user.uid
        } catch {
            print("Error fetching authenticated user: \(error)")
        }
    }



}

