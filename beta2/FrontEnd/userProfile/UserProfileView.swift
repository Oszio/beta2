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
    @State private var completedChallenges: [Challenge] = []

    init(uid: String) {
        self.uid = uid
    }

    var body: some View {
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
            if !completedChallenges.isEmpty {
                List(completedChallenges, id: \.id) { challenge in
                    Text(challenge.name)
                }
                .frame(height: 200)
            }
        }
        .padding()
        .navigationBarTitle("Profile", displayMode: .inline)
        .task {
            print("WOHO")
            do {
                user = try await UserManager.shared.fetchUser(byUID: uid)
                if let evidence = user?.evidence {
                    print("User has \(evidence.count) evidence items")
                    for evidenceId in evidence {
                        if let challenge = try? await ChallengeManager.shared.fetchChallenge(byID: evidenceId) {
                            completedChallenges.append(challenge)
                            print("Added challenge: \(challenge.name)")
                        } else {
                            print("Failed to fetch challenge for ID: \(evidenceId)")
                        }
                    }

                }
            } catch {
                print("Failed to fetch user or challenges: \(error)")
            }
        }

    }

    #if DEBUG
    struct UserProfile_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                UserProfileView(uid: "sampleUID")
            }
        }
    }
    #endif
}
