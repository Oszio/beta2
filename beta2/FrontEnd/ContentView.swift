//
//  ContentView.swift
//  test2
//
//  Created by Petter Uvdal on 2023-08-27.
//

import SwiftUI

struct ContentView: View {
    @State private var activeView: ActiveView = .category
    @ObservedObject var achievementData: AchievementData = AchievementData()
    @ObservedObject var challengeData: ChallengeData = ChallengeData() // Create an instance here

    @Binding var showSignInView: Bool
    
    var body: some View {
        NavigationView {
            TabView {
                CategoryView(challengeData: challengeData, achievementData: achievementData, activeView: $activeView, showSignInView: $showSignInView)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Challenges")
                    }
                InfoView(activeView: $activeView, challengeData: challengeData, achievementData: achievementData)
                    .tabItem {
                        Image(systemName: "info.circle")
                        Text("FAQ")
                    }
                UserView(achievementData: achievementData, challengeData: challengeData, activeView: $activeView)
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
            }
                
                //Divider() // Optional divider line
        }
    }
}
