//
//  DailyView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-25.
//

import SwiftUI

import SwiftUI

struct DailyChallengeView: View {
    @ObservedObject var challengeData: ChallengeData
    @ObservedObject var achievementData: AchievementData

    var body: some View {
        ScrollView {
            VStack {
                Text("Daily Challenge")
                    .font(.custom("Avenir", size: 44))
                    .bold()
                    .italic()
                    .foregroundColor(Color.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                
                if let dailyChallenge = challengeData.dailyChallenge {
                    ChallengeTileView(challenge: dailyChallenge, category: .daily)
                } else {
                    Text("No daily challenge available.")
                        .font(.custom("Avenir", size: 20))
                        .foregroundColor(Color.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}

struct DailyChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        // You can create a ChallengeData instance and pass it here for preview
        let challengeData = ChallengeData()
        return DailyChallengeView(challengeData: challengeData, achievementData: AchievementData())
    }
}
