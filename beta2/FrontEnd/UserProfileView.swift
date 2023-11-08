
//
//  UserProfileVIew.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-17.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import Kingfisher

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
                    if let photoUrl = user?.photoUrl, let url = URL(string: photoUrl) {
                        KFImage(url)
                            .resizable()
                            .loadDiskFileSynchronously() // This will load the image from the disk if available, synchronously.
                            .cacheMemoryOnly() // This will store the fetched image in memory cache only.
                            .fade(duration: 0.25) // Adds a fade animation when the image gets loaded.
                            .onProgress { receivedSize, totalSize in  // If you want to handle progress.
                              // Handle progress here
                            }
                            .onSuccess { result in  // If you want to handle success.
                              // Handle success here
                            }
                            .onFailure { error in  // If you want to handle failure.
                              // Handle error here
                            }
                            .placeholder { // Placeholder while loading or if there's an error
                                ProgressView()
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
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
                        
                        let date = Date()
                        
                        FriendRow(friend: user?.asFriend() ?? Friend(id: "", friendID: "", timestamp: Timestamp(date: Date()), email: "", photoUrl: "", username: ""), navigation: false)
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
        print("loadUserProfile is called")
        completedChallengeInfos.removeAll()  // Clear the array to prevent duplicates
        
        do {
            print("Attempting to fetch user for UID: \(uid)")
            user = try await UserManager.shared.fetchUser(byUID: uid)
            print("User fetched: \(String(describing: user))")
            username = user?.username ?? ""
            print("Loaded username: \(username)")
            
            print("Attempting to fetch completed challenges for UID: \(uid)")
            let challenges = try await UserManager.shared.fetchCompletedChallenges(forUID: uid)
            print("Challenges fetched: \(challenges)")
            
            for challenge in challenges {
                print("Fetching details for challenge ID: \(challenge.challengeID)")
                if let challengeDetail = try? await ChallengeManager.shared.fetchChallenge(byID: challenge.challengeID, inCategory: challenge.categoryID) {
                    let challengeInfo = CompletedChallengeInfo(challenge: challengeDetail, evidence: challenge)
                    completedChallengeInfos.append(challengeInfo)
                    print("Challenge details fetched and added: \(challengeInfo)")
                } else {
                    print("Failed to fetch challenge detail for ID: \(challenge.challengeID)")
                }
            }
        } catch {
            print("An error occurred while fetching user profile: \(error.localizedDescription)")
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
                KFImage(imageUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 200)
                    .cornerRadius(10)
                // Replace `placeholder` with actual implementation
           
               
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

extension DBUser {
    func asFriend() -> Friend {
        return Friend(
            id: self.uid,
            friendID: self.uid,
            timestamp: Timestamp(date: Date()), // Initialize timestamp with the current date
            email: self.email,
            photoUrl: self.photoUrl,
            username: self.username
        )
    }
}

// A preview for your UserProfileView
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(uid: "exampleUID", showSignInView: .constant(true))
    }
}
