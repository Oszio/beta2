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
                
                if let userId = userId {
                    FeedView(uid: userId)
                        .tabItem {
                            Image(systemName: "house")
                            Text("Feed")
                        }
                } else {
                    Text("Loading user profile...")
                        .tabItem {
                            Image(systemName: "person.circle")
                            Text("Profile")
                        }
                }

                FriendSearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Find Friends")
                    }
                
                ChallengeListView()
                    .tabItem {
                        Image(systemName: "checkmark.square")
                        Text("Challenges")
                    }
                
                if let userId = userId {
                    FriendListView(uid: userId)
                        .tabItem {
                            Image(systemName: "person.2.circle")
                            Text("Friends")
                        }
                } else {
                    Text("Loading user profile...")
                        .tabItem {
                            Image(systemName: "person.2.circle")
                            Text("Friends")
                        }
                }
              
                /*
                CreateChallengeView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Create")
                    }
                 */
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
