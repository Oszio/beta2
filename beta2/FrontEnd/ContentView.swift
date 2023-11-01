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
    
    var body: some View {
        NavigationView {
            TabView {
                FeedView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Feed")
                    }
                FriendView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                ChallengeListView()
                    .tabItem {
                        Image(systemName: "plus")
                        Text("Challenges")
                    }
                CreateChallengeView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Create")
                    }
                if let userId = userId {
                    UserProfileView(uid: userId, showSignInView: $showSignInView)
                        .tabItem {
                            Image(systemName: "person.circle")
                            Text("Profile")
                        }
                } else {
                    Text("Loading user profile...")
                        .tabItem {
                            Image(systemName: "person.circle")
                            Text("Profile")
                        }
                }
            }
        }
        .onAppear {
            if let authUser = try? AuthenticationManager.shared.getAuthenticatedUser() {
                self.userId = authUser.uid
            }
        }
    }
}


/*
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
*/
