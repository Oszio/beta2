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
    var completedChallengeID: String
}

struct FriendCommentSectionView: View {
    var completedChallengeID: String
    var userId: String
    @State private var friendComments: [FriendComment] = []
    @State private var commentText: String = ""

    var body: some View {
        VStack {
            // Section for posting a new comment
            HStack {
                TextField("Write a comment...", text: $commentText)
                Button("Post") {
                    Task {
                        let newComment = FriendComment(id: UUID().uuidString, userId: userId, username: "Username", text: commentText, timestamp: Date(), completedChallengeID: completedChallengeID)
                        try await FirebaseManager.shared.postFriendComment(userId: userId, completedChallengeID: completedChallengeID, comment: newComment)
                        commentText = ""
                        loadComments()
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
                friendComments = try await FirebaseManager.shared.fetchFriendComments(userId: userId, completedChallengeID: completedChallengeID)
            } catch {
                print("Error fetching friend comments: \(error)")
            }
        }
    }
}
