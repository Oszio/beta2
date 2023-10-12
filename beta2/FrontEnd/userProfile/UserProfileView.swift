//
//  UserProfileView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-03.
//

import SwiftUI

struct UserProfileView: View {
    let uid: String
    @State private var user: DBUser?
    @State private var completedChallengeInfos: [CompletedChallengeInfo] = []  // Updated to use the combined structure
    
    init(uid: String) {
        self.uid = uid
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                // Profile Picture
                if let photoUrl = user?.photoUrl, let url = URL(string: photoUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
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
                
                // User Information
                Text(user?.email ?? "No Email")
                    .font(.title2)
                    .padding(.bottom)
                
                Text("Anonymous: \(user?.isAnonymous ?? false ? "Yes" : "No")")
                    .font(.subheadline)
                
                // Completed Challenges
                if !completedChallengeInfos.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Completed Challenges")
                            .font(.headline)
                            .padding(.leading)
                        
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
                    print("hello")
                    
                    // Fetching user
                    user = try await UserManager.shared.fetchUser(byUID: uid)
                    print("User fetched successfully")
                    
                    // Fetching completed challenges
                    let challenges = try await UserManager.shared.fetchCompletedChallenges(forUID: uid)
                    print("Fetched \(challenges.count) completed challenges for user")
                    
                    for challenge in challenges {
                        print("Processing challenge with ID: \(challenge.challengeId)")
                        
                        if let challengeDetail = try? await ChallengeManager.shared.fetchChallenge(byID: challenge.challengeId) {
                            let challengeInfo = CompletedChallengeInfo(challenge: challengeDetail, evidence: challenge)
                            completedChallengeInfos.append(challengeInfo)
                            print("Added challenge: \(challengeDetail.name)")
                        } else {
                            print("Failed to fetch challenge detail for ID: \(challenge.challengeId)")
                        }
                    }
                } catch {
                    print("Failed to fetch user or challenges: \(error)")
                }
            }


        }
    }
    
    struct ChallengeCard: View {
        var challenge: Challenge
        var evidence: CompletedChallenge  // Add this line
        
        var body: some View {
            VStack {
                HStack {
                    // If you have icons for challenges, you can use them here
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(challenge.name)
                            .font(.headline)
                        // If challenges have descriptions, display them
                        Text(challenge.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                // Display evidence image
                if let imageUrl = URL(string: evidence.imageUrl) {
                    AsyncImage(url: imageUrl) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 300, height: 200)
                    .cornerRadius(10)
                }
                
                // Display evidence comment
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
    
    struct CompletedChallengeInfo {
        var challenge: Challenge
        var evidence: CompletedChallenge
        
    }
}
