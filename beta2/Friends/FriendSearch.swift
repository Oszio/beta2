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
                            Button("Add Friend") {
                                addFriend(user)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Friend Search", displayMode: .inline)
            .onAppear {
                do {
                    let currentUser = try AuthenticationManager.shared.getAuthenticatedUser()
                    currentUserId = currentUser.uid
                } catch {
                    print("Failed to fetch current user: \(error)")
                }
            }
        }
    }
    
    func searchForUser() {
        isLoading = true
        errorMessage = nil
        let db = Firestore.firestore()
        
        db.collection("users").whereField("email", isEqualTo: searchText).getDocuments { (snapshot, error) in
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
        
        Task {
            do {
                try await UserManager.shared.addFriend(currentUserID: currentUserID, friendID: user.uid)
                successMessage = "Friend added successfully!"
            } catch {
                errorMessage = "Failed to add friend: \(error.localizedDescription)"
            }
        }
    }
}
