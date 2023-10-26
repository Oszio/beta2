//
//  FriendSearch.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-17.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FriendSearchView: View {
    @State private var searchText: String = ""
    @State private var searchResults: [DBUser] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    @State private var currentUserId: String?
    @State private var addedFriends: Set<String> = []

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter email or username", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Button(action: {
                        // Trigger the search
                        searchForUser()
                    }) {
                        Text("Search")
                    }
                }
                .padding()
                
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else if let success = successMessage {
                    Text(success)
                        .foregroundColor(.green)
                } else {
                    List(searchResults, id: \.uid) { user in
                        HStack {
                            Text(user.email ?? "No Email")
                            Spacer()
                            if addedFriends.contains(user.uid) {
                                Text("Added")
                            } else {
                                Button("Add Friend") {
                                    addFriend(user)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Friend Search", displayMode: .inline)
            .onAppear {
                getCurrentUser()
            }
        }
    }
    
    func getCurrentUser() {
        do {
            let currentUser = try AuthenticationManager.shared.getAuthenticatedUser()
            currentUserId = currentUser.uid
        } catch {
            errorMessage = "Failed to fetch current user: \(error.localizedDescription)"
        }
    }
    
    func searchForUser() {
        guard searchText.count > 2 else {
            errorMessage = "Please enter at least 3 characters for search."
            return
        }
        
        isLoading = true
        errorMessage = nil
        let db = Firestore.firestore()
        
        db.collection("users")
          .whereField("email", isEqualTo: searchText)
          .getDocuments { (snapshot, error) in
            // Further logic can be added here to also search by username.
            isLoading = false
            if let error = error {
                errorMessage = "Error searching for user: \(error.localizedDescription)"
                return
            }
            
            guard let documents = snapshot?.documents else {
                errorMessage = "No users found with the given email or username."
                return
            }
            
            searchResults = documents.compactMap { try? $0.data(as: DBUser.self) }
        }
    }
    
    func addFriend(_ user: DBUser) {
        guard let currentUserID = currentUserId else {
            errorMessage = "Failed to get current user ID."
            return
        }
        
        guard !addedFriends.contains(user.uid) else {
            errorMessage = "User already added as a friend!"
            return
        }
        
        Task {
            do {
                try await UserManager.shared.addFriend(currentUserID: currentUserID, friendID: user.uid)
                successMessage = "Friend added successfully!"
                addedFriends.insert(user.uid)
            } catch {
                errorMessage = "Failed to add friend: \(error.localizedDescription)"
            }
        }
    }
}
