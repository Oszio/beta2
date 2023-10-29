
//
//  UserProfileVIew.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-17.
//

import SwiftUI

struct UserProfileView: View {
    let uid: String
    @Binding var showSignInView: Bool
    @State private var user: DBUser?
    @State private var completedChallengeInfos: [CompletedChallengeInfo] = []
    
   
    init(uid: String, showSignInView: Binding<Bool>) {
        self.uid = uid
        self._showSignInView = showSignInView
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
          
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
            // Clear the array before loading new data
            completedChallengeInfos = []
            
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
        }
    }

    
    // A card-style view to display individual challenges completed by the user
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
    
    // Structure to combine a challenge and its corresponding evidence
    struct CompletedChallengeInfo {
        var challenge: Challenge
        var evidence: CompletedChallenge
    }
    
    

