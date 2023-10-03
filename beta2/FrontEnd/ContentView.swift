//
//  ContentView.swift
//  test2
//
//  Created by Petter Uvdal on 2023-08-27.
//

import SwiftUI

struct ContentView: View {
    @Binding var showSignInView: Bool
    @ObservedObject var challengeData = ChallengeData()
    @State private var showUserProfile: Bool = false
    @State private var userId: String? = nil

    var body: some View {
        NavigationView {
            List(ChallengeCategory.allCases, id: \.self) { category in
                NavigationLink(destination: ChallengeListView(category: category, challengeData: challengeData)) {
                    Text(category.displayName)
                }
            }
            .navigationTitle("Challenges")
            .navigationBarItems(leading: Button(action: {
                showUserProfile.toggle()
            }) {
                Image(systemName: "person.circle")
            }, trailing: Button(action: signOut) {
                Text("Sign Out")
            })
            .sheet(isPresented: $showUserProfile) {
                if let userId = userId {
                    UserProfileView(userId: userId)
                }
            }
            .onAppear {
                if let authUser = try? AuthenticationManager.shared.getAuthenticatedUser() {
                    self.userId = authUser.uid
                }
            }
        }
    }
    
    func signOut() {
        // Call your authentication manager's sign-out function here
        // For now, I'll just set showSignInView to true to simulate a sign-out
        showSignInView = true
    }
}
