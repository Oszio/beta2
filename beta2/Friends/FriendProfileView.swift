//
//  FriendProfileView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-19.
//

import SwiftUI
import Kingfisher

struct FriendProfileView: View {
    var friend: Friend
    
    @State private var completedChallenges: [CompletedChallenge] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let url = friend.photoUrl, let imageUrl = URL(string: url) {
                    KFImage(imageUrl)
                        .resizable()
                        .loadDiskFileSynchronously() // Loads the image from the disk cache synchronously
                        .cacheMemoryOnly() // Stores the image in memory cache only
                        .fade(duration: 0.25) // Adds a fade animation when the image gets loaded
                        .onProgress { receivedSize, totalSize in  // Handle progress
                            // Optionally handle progress here
                        }
                        .onSuccess { result in  // Handle success
                            // Optionally handle success here
                        }
                        .onFailure { error in  // Handle failure
                            // Optionally handle failure here
                        }
                        .placeholder {
                            ProgressView() // Placeholder while loading or if there's an error
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.gray)
                }
                Text(friend.username ?? "no username")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Button("Remove Friend") {
                    // Prompt the user to confirm before removing
                    // If confirmed, implement the remove friend functionality here
                }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                Divider()
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    FriendRow(friend: friend, navigation: false)
                }
            }
            .padding()
            .onAppear(perform: loadCompletedChallenges)
        }
        .navigationBarTitle(friend.username ?? "No Username", displayMode: .inline)
    }
    
    func loadCompletedChallenges() {
        Task {
            do {
                self.completedChallenges = try await FirebaseManager.shared.fetchCompletedChallenges(forUID: friend.id)
                self.isLoading = false
            } catch {
                self.isLoading = false
                errorMessage = "Error fetching completed challenges: \(error.localizedDescription)"
            }
        }
    }
}
