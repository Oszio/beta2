//
//  FriendComment.swift
//  beta2
//
//  Created by Oskar Almå on 2023-11-18.
//

import SwiftUI

import Firebase


struct FriendComment: Codable, Identifiable {
    var id: String
    var userId: String
    var username: String
    var text: String
    var timestamp: Date
}

struct FriendCommentSectionView: View {
    var challengeID: String
    @State private var friendComments: [FriendComment] = []
    @State private var commentText: String = ""

    var body: some View {
        VStack {
            // Section for posting a new comment
            HStack {
                TextField("Write a comment...", text: $commentText)
                Button("Post") {
                    Task {
                        let newComment = FriendComment(id: UUID().uuidString, userId: "UserID", username: "Username", text: commentText, timestamp: Date())
                        try await FirebaseManager.shared.postFriendComment(challengeID: challengeID, comment: newComment)
                        commentText = ""
                        loadComments() // Reload comments after posting
                    }
                }
            }
            .padding()

            // Section for displaying existing comments
            List(friendComments) { comment in
                VStack(alignment: .leading) {
                    Text(comment.username)
                        .font(.headline)
                    Text(comment.text)
                        .font(.subheadline)
                    Text("Posted on \(comment.timestamp.formatted())")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .onAppear(perform: loadComments)
        }
    }

    // Function to load comments
    func loadComments() {
        Task {
            do {
                friendComments = try await FirebaseManager.shared.fetchFriendComments(forChallenge: challengeID)
            } catch {
                print("Error fetching friend comments: \(error)")
            }
        }
    }
}
