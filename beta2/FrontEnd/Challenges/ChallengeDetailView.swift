//
//  ChallengeDetailView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-03.
//

import SwiftUI

struct ChallengeDetailView: View {
    let challenge: Challenge
    
    @State private var selectedImage: UIImage?
    @State private var comment: String = ""
    @State private var isUploading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = "Info"
    @State private var alertMessage: String = ""
    @State private var currentUser: DBUser?
    @State private var isImagePickerPresented: Bool = false
    
    @State private var showImagePicker: Bool = false
    @State private var showImageSourceSelectionActionSheet: Bool = false
    @State private var showImageSourceSelection: Bool = true
    
    var body: some View {
        VStack(spacing: 20) {
            // Display challenge details
            Text(challenge.name)
                .font(.title)
                .padding()
            
            Text(challenge.description)
                .padding()
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
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
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            TextField("Comment", text: $comment)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            Button("Upload Evidence") {
                uploadEvidence()
            }
            .disabled(isUploading || selectedImage == nil)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if isUploading {
                ProgressView("Uploading...")
            }
        }
        .onAppear {
            fetchCurrentUserDetails()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func uploadEvidence() {
        guard let image = selectedImage, let userId = currentUser?.uid else { return }
        isUploading = true
        
        FirebaseManager.shared.uploadEvidence(userId: userId, image: image, comment: comment, challengeID: challenge.id, categoryId: challenge.categoryId) { result in
            isUploading = false
            switch result {
            case .success(let (evidenceId, downloadURL)):
                Task {
                    do {
                        try await ChallengeManager.shared.completeChallenge(challenge.id, for: userId, inCategory: challenge.categoryId, evidenceId: evidenceId, imageUrl: downloadURL, comment: comment)
                        alertTitle = "Success"
                        alertMessage = "Evidence uploaded and challenge marked as completed!"
                    } catch {
                        alertTitle = "Error"
                        alertMessage = "Evidence uploaded, but failed to mark challenge as completed: \(error.localizedDescription)"
                    }
                    showAlert = true
                }
            case .failure(let error):
                alertTitle = "Error"
                alertMessage = "Failed to upload evidence: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
    
    func fetchCurrentUserDetails() {
        Task {
            do {
                if let authUser = try? AuthenticationManager.shared.getAuthenticatedUser() {
                    currentUser = try await UserManager.shared.fetchUser(byUID: authUser.uid)
                }
            } catch {
                print("Failed to fetch user details: \(error.localizedDescription)")
            }
        }
    }
}
