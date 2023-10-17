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
                } else {
                    List(searchResults, id: \.uid) { user in
                        HStack {
                            Text(user.email ?? "No Email")
                            Spacer()
                            Button("Add") {
                                // Add friend functionality here
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Friend Search", displayMode: .inline)
        }
    }

    func searchForUser() {
        isLoading = true
        errorMessage = nil
        let db = Firestore.firestore()

        db.collection("Users").whereField("email", isEqualTo: searchText).getDocuments { (snapshot, error) in
            isLoading = false
            if let error = error {
                errorMessage = "Error searching for user: \(error.localizedDescription)"
                print(errorMessage!) // Log the error
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                errorMessage = "No users found with the given email or username."
                print(errorMessage!) // Log the empty result
                return
            }

            searchResults = documents.compactMap { try? $0.data(as: DBUser.self) }
            print("Found \(searchResults.count) users") // Log the number of users found
        }
    }

}
