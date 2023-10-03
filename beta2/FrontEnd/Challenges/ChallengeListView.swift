//
//  ChallengeListView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-03.
//

import Foundation

struct ChallengeListView: View {
    var category: ChallengeCategory
    var challenges: [Challenge]
    
    var body: some View {
        List(challenges) { challenge in
            VStack(alignment: .leading) {
                Text(challenge.title).font(.headline)
                Text(challenge.description).font(.subheadline)
            }
        }
        .navigationTitle(category.displayName)
    }
}
