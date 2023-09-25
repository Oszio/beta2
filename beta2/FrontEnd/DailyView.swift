//
//  DailyView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-25.
//

import SwiftUI

struct ChallengeTileView: View {
    let challenge: Challenge
    let category: ChallengeCategory
    @State private var isTextVisible = false

    var body: some View {
        if let evidence = challenge.evidence, challenge.isCompleted {
            VStack(spacing: 0) {
                Image(uiImage: evidence)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.primary, lineWidth: 2))
                    .onTapGesture {
                        withAnimation {
                            isTextVisible.toggle()
                            generateHapticFeedback()
                        }
                    }
                if isTextVisible {
                    Text(challenge.title)
                        .font(.custom("Avenir", size: 20))
                        .foregroundColor(Color.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: UIScreen.main.bounds.width)
                        .padding(.horizontal)
                }
                else {
                    Rectangle()
                        .fill(Color(red: (28+95)/255, green: (77+95)/255, blue: (42+95)/255))
                        .frame(width: 5, height: 20)
                }
            }
        } else {
            VStack(spacing: 0){
                ZStack {
                    Circle()
                        .fill(Color(red: (28+95)/255, green: (77+95)/255, blue: (42+95)/255))
                        .frame(width: 150, height: 150)
                    Text("NEW CHALLENGE!")
                        .font(.custom("Avenir", size: 20))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(width: 150)
                        .padding(.horizontal)
                }
                Rectangle()
                    .fill(Color(red: 240/255, green: 240/255, blue: 240/255))
                    .frame(width: 5, height: 20)
            }
        }
    }
}

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
                
                if let dailyChallenge = $challengeData.dailyChallenge {
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
