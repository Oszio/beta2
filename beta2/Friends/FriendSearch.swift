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
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.trailing, 10)
                    
                    Button(action: {
                        // Trigger the search
                        searchForUser()
                    }) {
                        Text("Search")
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding([.leading, .trailing, .top])
                
                Spacer().frame(height: 20) // Add some spacing
                
                if isLoading {
                    ProgressView()
                }
                
                // Display the message in a banner-like style
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemPink).opacity(0.1))
                        .cornerRadius(8)
                } else if let success = successMessage {
                    Text(success)
                        .foregroundColor(.green)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGreen).opacity(0.1))
                        .cornerRadius(8)
                }
                
                List {
                    ForEach(searchResults, id: \.uid) { user in
                        HStack {
                            Text(user.email ?? "No Email")
                            Spacer()
                            if addedFriends.contains(user.uid) {
                                Text("Added")
                                    .foregroundColor(.green)
                            } else {
                                Button("Add Friend") {
                                    sendFriendRequest(user)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                }
                
                NavigationLink(destination: PendingFriendRequestsView(viewModel: PendingFriendRequestsViewModel())) {
                    Text("View Friend Requests")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding([.leading, .trailing, .bottom])
            }
            .onAppear {
                getCurrentUser()
            }
            .navigationBarTitle("Friend Search", displayMode: .inline)
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
        successMessage = nil // Clear previous success message if any
        let db = Firestore.firestore()
        
        _ = searchText.lowercased()
        db.collection("users")
            .whereField("email", isEqualTo: searchText)
          .getDocuments { (snapshot, error) in
            isLoading = false
            if let error = error {
                errorMessage = "Error searching for user: \(error.localizedDescription)"
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                errorMessage = "No users found with the given search term."
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
                
                // Reset search results and search text
                searchResults = []
                searchText = ""
            } catch {
                errorMessage = "Failed to add friend: \(error.localizedDescription)"
            }
        }
    }
    func sendFriendRequest(_ user: DBUser) {
        guard let currentUserID = currentUserId else {
            errorMessage = "Failed to get current user ID."
            return
        }
        
        guard !addedFriends.contains(user.uid) else {
            errorMessage = "Friend request already sent."
            return
        }
        
        Task {
            do {
                // Send friend request by email
                try await UserManager.shared.sendFriendRequestByEmail(from: currentUserID, toEmail: user.email ?? "")
                
                successMessage = "Friend request sent successfully!"
                addedFriends.insert(user.uid)
                
                // Reset search results and search text
                searchResults = []
                searchText = ""
            } catch {
                errorMessage = "Failed to send friend request: \(error.localizedDescription)"
            }
        }
    }
}
