//
//  UserProfileView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-03.
//

import SwiftUI

// This SwiftUI view displays the profile of a user, including their personal info and completed challenges.
struct UserProfileView: View {
    
    // The unique identifier for the user
    let uid: String
    
    // Current user details fetched from the database
    @State private var user: DBUser?
    
    // List of completed challenges along with associated evidence for the user
    @State private var completedChallengeInfos: [CompletedChallengeInfo] = []
    
    // Initializer accepting the user ID
    init(uid: String) {
        self.uid = uid
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                
                // Display user's profile picture if available, otherwise show a placeholder
                if let photoUrl = user?.photoUrl, let url = URL(string: photoUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView() // Placeholder for image load
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
                
                // Display user's email and anonymity status
                Text(user?.email ?? "No Email")
                    .font(.title2)
                    .padding(.bottom)
                
                Text("Anonymous: \(user?.isAnonymous ?? false ? "Yes" : "No")")
                    .font(.subheadline)
                
                // List out all the challenges completed by the user
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
            }
            .padding()
            .navigationBarTitle("Profile", displayMode: .inline)
            .task {
                do {
                    user = try await UserManager.shared.fetchUser(byUID: uid)
                    print("Fetched user: \(String(describing: user))")  // Print here

                    let challenges = try await UserManager.shared.fetchCompletedChallenges(forUID: uid)
                    print("Fetched challenges: \(challenges)")  // And here

                    for challenge in challenges {
                        if let challengeDetail = try? await ChallengeManager.shared.fetchChallenge(byID: challenge.challengeID, inCategory: challenge.categoryId) {
                            let challengeInfo = CompletedChallengeInfo(challenge: challengeDetail, evidence: challenge)
                            completedChallengeInfos.append(challengeInfo)
                            print("Mapped challenge info: \(challengeInfo)")
                        } else {
                            print("Failed to fetch challenge detail for ID: \(challenge.challengeID)")
                        }
                    }

                       } catch {
                    print("Failed to fetch user or challenges: \(error)")
                }
            }

        }
    }
    
    // A card-style view to display individual challenges completed by the user
    struct ChallengeCard: View {
        
        // Challenge information
        var challenge: Challenge
        
        // Proof or evidence of challenge completion
        var evidence: CompletedChallenge
        
        var body: some View {
            VStack {
                HStack {
                    // Displaying an icon for the challenge (you can customize this part based on your app's design)
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
    
    // Structure to combine a challenge and its corresponding evidence
    struct CompletedChallengeInfo {
        var challenge: Challenge
        var evidence: CompletedChallenge
    }
}
