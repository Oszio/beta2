
//
//  UserProfileVIew.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-17.
//

import SwiftUI
import FirebaseStorage

struct UserProfileView: View {
    let uid: String
    @Binding var showSignInView: Bool
    @State private var user: DBUser?
    @State private var username: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var completedChallengeInfos: [CompletedChallengeInfo] = []
    
    init(uid: String, showSignInView: Binding<Bool>) {
        self.uid = uid
        self._showSignInView = showSignInView
    }
    
    struct CompletedChallengeInfo {
        var challenge: Challenge
        var evidence: CompletedChallenge
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                // User Profile UI
                Group {
                    if let user = user {
                        Text(user.email ?? "No email")
                            .font(.headline)
                        
                        if let photoUrl = user.photoUrl, let url = URL(string: photoUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        
                        Text(user.username ?? "No username")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text("Loading user profile...")
                    }
                }
                .padding()
                
                Divider()
                
                // Update Username TextField
                TextField("Update Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Profile Picture Selection
                Button("Select Profile Picture") {
                    showingImagePicker = true
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(selectedImage: $selectedImage)
                }
                
                
                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .cornerRadius(50)
                }
                
                // Update Profile Button
                Button("Update Profile") {
                    Task {
                        await updateProfile()
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // Completed Challenges
                if !completedChallengeInfos.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Completed Challenges")
                            .font(.headline)
                            .padding(.leading)
                        
                        // Displaying each challenge in a card
                        ForEach(completedChallengeInfos, id: \.challenge.id) { challengeInfo in
                            ChallengeCard(challenge: challengeInfo.challenge, evidence: challengeInfo.evidence)
                        }
                    }
                }
                
                // Sign Out Button
                Button("Sign Out") {
                    signOut()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            .navigationBarTitle("Profile", displayMode: .inline)
        }
        .task {
            await loadUserProfile()
        }
    }
    
    func signOut() {
        do {
            try AuthenticationManager.shared.signOut()
            showSignInView = true
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    func loadUserProfile() async {
        completedChallengeInfos.removeAll()  // Clear the array to prevent duplicates
        
        do {
            user = try await UserManager.shared.fetchUser(byUID: uid)
            username = user?.username ?? ""
            let challenges = try await UserManager.shared.fetchCompletedChallenges(forUID: uid)
            
            do {
                user = try await UserManager.shared.fetchUser(byUID: uid)
                let challenges = try await UserManager.shared.fetchCompletedChallenges(forUID: uid)
                
                for challenge in challenges {
                    if let challengeDetail = try? await ChallengeManager.shared.fetchChallenge(byID: challenge.challengeID, inCategory: challenge.categoryID) {
                        let challengeInfo = CompletedChallengeInfo(challenge: challengeDetail, evidence: challenge)
                        completedChallengeInfos.append(challengeInfo)
                    } else {
                        print("Failed to fetch challenge detail for ID: \(challenge.challengeID)")
                    }
                }
            } catch {
                print("Failed to fetch user or challenges: \(error)")
            }
        } catch {
            print("Failed to fetch user or challenges: \(error)")
        }
    }
    
    
    func updateProfile() async {
        do {
            // Update Username
            if !username.isEmpty && username != user?.username {
                try await UserManager.shared.updateUsername(uid: uid, username: username)
                // Reload user to reflect the change
                user = try await UserManager.shared.fetchUser(byUID: uid)
            }
            
            // Update Profile Picture
            if let selectedImage = selectedImage,
               let imageData = selectedImage.jpegData(compressionQuality: 0.5) {
                let photoUrl = try await UserManager.shared.uploadProfilePicture(uid: uid, imageData: imageData)
                try await UserManager.shared.updateUserPhotoURL(uid: uid, photoUrl: photoUrl.absoluteString)
                // Reload user to reflect the change
                user = try await UserManager.shared.fetchUser(byUID: uid)
            }
        } catch {
            print("Failed to update profile: \(error)")
        }
    }
}

struct ChallengeCard: View {
    var challenge: Challenge
    var evidence: CompletedChallenge

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.green)
                
                // Challenge title and description
                VStack(alignment: .leading, spacing: 5) {
                    Text(challenge.name)
                        .font(.headline)
                    Text(challenge.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Show the evidence image if available
            if let imageUrl = URL(string: evidence.imageUrl) {
                AsyncImage(url: imageUrl) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 300, height: 200)
                .cornerRadius(10)
            }
            
            // Show the user's comment on the challenge
            Text(evidence.comment)
                .font(.caption)
                .padding(.top, 5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .padding(.horizontal)
    }
}



// A preview for your UserProfileView
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(uid: "exampleUID", showSignInView: .constant(true))
    }
}
