//
//  ChallengeListView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-03.
//

import SwiftUI

struct ChallengeListView: View {
    var category: ChallengeCategory
    @ObservedObject var challengeData: ChallengeData
    
    var body: some View {
        List(challengeData.challengesByCategory[category] ?? []) { challenge in
            NavigationLink(destination: ChallengeDetailView(challenge: challenge)) {
                VStack(alignment: .leading) {
                    Text(challenge.title).font(.headline)
                    Text(challenge.description).font(.subheadline)
                }
            }
        }
        .navigationTitle(category.displayName)
    }
}
