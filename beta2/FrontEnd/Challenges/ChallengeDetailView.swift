//
//  ChallengeDetailView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-03.
//

import SwiftUI

struct ChallengeDetailView: View {
    var challenge: Challenge
    @State private var selectedImage: UIImage?
    @State private var comment: String = ""
    @State private var isUploading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var currentUser: DBUser?
    @State private var isImagePickerPresented: Bool = false

    
    
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
                isImagePickerPresented.toggle()
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
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
            .disabled(isUploading)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        
        .onAppear {
            fetchCurrentUserDetails()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
        
    func uploadEvidence() {
        guard let image = selectedImage, let userId = currentUser?.uid else { return }
        isUploading = true

        FirebaseManager.shared.uploadEvidence(userId: userId, image: image, comment: comment, challengeId: challenge.id) { result in
            switch result {
            case .success(let url):
                // After successfully uploading the evidence, mark the challenge as completed
                Task {
                    do {
                        try await ChallengeManager.shared.completeChallenge(challenge.id, for: userId, inCategory: challenge.categoryID)
                        self.alertMessage = "Evidence uploaded and challenge marked as completed!"
                    } catch {
                        self.alertMessage = "Evidence uploaded, but failed to mark challenge as completed: \(error.localizedDescription)"
                    }
                }
            case .failure(let error):
                self.alertMessage = "Failed to upload evidence: \(error.localizedDescription)"
            }
            self.showAlert = true
            self.isUploading = false
        }
    }


           
        func fetchCurrentUserDetails() {
            Task {
                do {
                    if let authUser = try? AuthenticationManager.shared.getAuthenticatedUser() {
                        let user = try await UserManager.shared.fetchUser(byUID: authUser.uid)
                        self.currentUser = user
                    }
                } catch {
                    print("Failed to fetch user details: \(error.localizedDescription)")
                }
            }
        }
    }
    

