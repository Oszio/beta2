//
//  FriendProfileView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-19.
//

import SwiftUI

struct FriendProfileView: View {
    var friend: Friend
    
    @State private var completedChallenges: [CompletedChallenge] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 20) {
            if let url = friend.photoUrl, let imageUrl = URL(string: url) {
                AsyncImage(url: imageUrl) { image in
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
            
            Text(friend.email ?? "No Email")
                .font(.title)
            
            if isLoading {
                ProgressView()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                List(completedChallenges) { challenge in
                    VStack(alignment: .leading) {
                        Text(challenge.comment)
                        if let url = URL(string: challenge.imageUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 100)
                        }
                    }
                }
            }
            
            Button("Remove Friend") {
                // Prompt the user to confirm before removing
                // If confirmed, implement the remove friend functionality here
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .onAppear(perform: loadCompletedChallenges)
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
