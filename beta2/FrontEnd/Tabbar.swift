//
//  Tabbar.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-24.
//

import SwiftUI

struct TabbarView: View {
    @Binding var showSignInView: Bool
    
    var body: some View {
        TabView {
            // Daily Challenge Tab (Default View)
            NavigationView {
                DailyChallengeView()
                    .navigationBarTitle("Daily Challenge", displayMode: .inline)
            }
            .tabItem {
                TabBarItemView(iconName: "calendar.circle.fill", title: "Daily Challenge")
            }
            
            // Second Tab (e.g., Profile)
            NavigationView {
                Text("Second Tab Content")
                    .navigationBarTitle("Profile", displayMode: .inline)
            }
            .tabItem {
                TabBarItemView(iconName: "person.fill", title: "Profile")
            }
        }
        .accentColor(Color(red: (28+95)/255, green: (77+95)/255, blue: (42+95)/255)) // Customize the tab bar's active color
    }
}

// ...

struct TabbarView_Previews: PreviewProvider {
    static var previews: some View {
        TabbarView(showSignInView: .constant(false))
    }
}


struct TabBarItemView: View {
    let iconName: String
    let title: String
    
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .font(.system(size: 24))
            Text(title)
                .font(.custom("Avenir", size: 12)) // Customize the text font and size
        }
    }
}

struct TabbarView_Previews: PreviewProvider {
    static var previews: some View {
        TabbarView(showSignInView: .constant(false))
    }
}
