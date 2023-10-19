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
    @State private var showUserProfileView: Bool = false
    @State private var showFriendListView: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let userId = userId {
                    Button(action: {
                        showUserProfileView.toggle()
                    }) {
                        Text("View Profile")
                    }
                    .sheet(isPresented: $showUserProfileView) {
                        UserProfileView(uid: userId)
                    }
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
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
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .sheet(isPresented: $showChallengeListView) {
                    ChallengeListView()
                }
                
                Button("Search Friends") {
                    showFriendSearchView.toggle()
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
                .sheet(isPresented: $showFriendSearchView) {
                    FriendSearchView()
                }
                
                Button("Friend List") {
                    showFriendListView.toggle()
                }
                .padding()
                .background(Color.yellow) // Choose a color that you like
                .foregroundColor(.white)
                .cornerRadius(8)
                .sheet(isPresented: $showFriendListView) {
                    FriendListView()
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
        showSignInView = true
    }
}
