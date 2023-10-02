//
//  UploadView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-24.
//

import SwiftUI

struct UploadView: View {
    @ObservedObject var challengeData: ChallengeData
    @ObservedObject var achievementData: AchievementData
    var challenge: Challenge
    
    @State private var showImagePicker: Bool = false
    @State private var showImageSourceSelectionActionSheet: Bool = false
    @State private var selectedImage: UIImage? = nil
    @State private var selectedImage2: UIImage? = nil
    @State private var comment: String = ""
    @State private var showImageSourceSelection: Bool = true
    @State private var authenticatedUserId: String? = nil
    
    
    var body: some View {
        ScrollView {
            VStack {
                // Current Challenge
                challengeContent(for: challenge)
            }
        }
    }
    
    func challengeContent(for challenge: Challenge) -> some View {
        VStack (alignment: .center, spacing: 20) {
            Text("New Challenge:")
                .font(.custom("Avenir", size: 44))
                .bold()
                .italic()
                .foregroundColor(Color.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            Text(challenge.title)
                .font(.custom("Avenir", size: 26))
                .foregroundColor(Color.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            Spacer()
            
            // Evidence Image or Upload Button
            if let evidence = challenge.evidence {
                Image(uiImage: evidence)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 250, height: 250)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                
                if let comment = challenge.comment {
                    HStack{
                        Text(" ")
                            .font(.custom("Avenir", size: 20))
                        Text(comment)
                            .font(.custom("Avenir", size: 20))
                            .foregroundColor(.gray)
                            .onAppear {
                                
                            }
                    }
                }
                
                // Comment TextField
                VStack {
                    ZStack(alignment: .trailing) {
                        TextField("Edit caption...", text: $comment)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        Button(action: saveComment) {
                            Text("Submit")
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .frame(height: 50) // Match the height of the text field
                                .background(Color.primary) // Set background color
                                .foregroundColor(Color.secondary) // Text color
                                .cornerRadius(8) // Apply corner radius
                        }
                        .disabled(comment.isEmpty) // Disable the button if comment is empty
                        .opacity(comment.isEmpty ? 0.5 : 1.0) // Adjust opacity when disabled
                    }
                }
                .padding(.horizontal)
                .onTapGesture {
                    // This will open the keyboard when the TextField is tapped
                    UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                    
                }
                .padding(.horizontal)
            } else {
                HStack {
                    Spacer()
                    evidenceButton
                    Spacer()
                }
                .padding(.vertical) // Adjust vertical padding as needed
            }
        }
        .padding(.horizontal) // Add horizontal padding here
    }
    var Addpicture: some View {
        Button(action: {
            showImageSourceSelectionActionSheet = true
        }) {
            ZStack {
                Circle()
                    .fill(Color(red: (28+95)/255, green: (77+95)/255, blue: (42+95)/255))
                    .frame(width: 250, height: 250)
                Image(systemName: "camera.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color.black)
            }
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
            ImagePickerView(selectedImage: $selectedImage2, showImageSourceSelection: $showImageSourceSelection)
        }
    }
    var evidenceButton: some View {
        Button(action: {
            showImageSourceSelectionActionSheet = true
        }) {
            ZStack {
                Circle()
                    .fill(Color(red: (28+95)/255, green: (77+95)/255, blue: (42+95)/255))
                    .frame(width: 250, height: 250)
                Image(systemName: "camera.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color.black)
            }
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
            ImagePickerView(selectedImage: $selectedImage, showImageSourceSelection: $showImageSourceSelection)
        }
        .onChange(of: selectedImage) { _ in
            saveChallengeDetails()
            
        }
    }
    func saveChallengeDetails() {
        let challengeId = challenge.id
        challengeData.addComment(id: challengeId, comment: comment)

        if let selectedImage = self.selectedImage {
            FirebaseManager.shared.uploadEvidence(image: selectedImage, comment: comment, challengeId: challengeId) { result in
                Task {
                    do {
                        let imageURL = try await withCheckedThrowingContinuation { continuation in
                            switch result {
                            case .success(let imageURL):
                                continuation.resume(returning: imageURL)
                            case .failure(let error):
                                continuation.resume(throwing: error)
                            }
                        }
                        
                        // Evidence details stored in Firestore
                        challengeData.addEvidence(id: challengeId, image: selectedImage)
                        
                        // Associate evidence with user
                        if let userId = authenticatedUserId {
                            try await UserManager.shared.addUserEvidence(uid: userId, imageUrl: imageURL)
                        }

                        // Award points once evidence is uploaded and challenge is completed
                        if let challenge = challengeData.getChallengeById(id: challengeId) {
                            challengeData.addPoints(points: challenge.points)
                            achievementData.checkForAchievements(totalPoints: challengeData.totalPoints)
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }

        
        
        
        
        func saveComment() {
            let challengeId = challenge.id
            challengeData.addComment(id: challengeId, comment: comment)
        }
        
        
        
    
}
