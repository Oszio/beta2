//
//  ContentView.swift
//  test2
//
//  Created by Petter Uvdal on 2023-08-27.
//

import SwiftUI

struct ContentView: View {
    @Binding var showSignInView: Bool
    @State private var userId: String? = nil
    @State private var showCreateChallengeView: Bool = false
    @State private var showChallengeListView: Bool = false
    @State private var showFriendSearchView: Bool = false


    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let userId = userId {
                    UserProfileView(uid: userId)
                } else {
                    Text("Loading user profile...")
                }
                
                Button("Create Challenge") {
                    showCreateChallengeView.toggle()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .sheet(isPresented: $showCreateChallengeView) {
                    CreateChallengeView()
                }
                
                Button("View Challenges") {
                    showChallengeListView.toggle()
                }
                
                Button("Search Friends") {
                    showFriendSearchView.toggle()
                }
                .padding()
                .background(Color.orange) // You can choose a different color
                .foregroundColor(.white)
                .cornerRadius(8)
                .sheet(isPresented: $showFriendSearchView) {
                    FriendSearchView()
                }

                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .sheet(isPresented: $showChallengeListView) {
                    ChallengeListView() // You might need to pass required parameters here
                }
            }
            .padding()
            .navigationBarItems(trailing: Button(action: signOut) {
                Text("Sign Out")
            })
        }
        .onAppear {
            if let authUser = try? AuthenticationManager.shared.getAuthenticatedUser() {
                self.userId = authUser.uid
            }
        }
    }
    
    func signOut() {
        // Call your authentication manager's sign-out function here
        // For now, I'll just set showSignInView to true to simulate a sign-out
        showSignInView = true
    }
}

