//
//  PathView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-24.
//

import SwiftUI



struct PathView: View {
    @ObservedObject var challengeData: ChallengeData
    @ObservedObject var achievementData: AchievementData
    @State private var currentImageIndex = 0

    
    var selectedCategory: ChallengeCategory
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text(" \(selectedCategory.displayName):")
                        .font(.custom("Avenir", size: 44))
                        .bold()
                        .italic()
                        .foregroundColor(Color.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.horizontal)
                
                ChallengeListView(challengeData: challengeData, achievementData: achievementData, selectedCategory: selectedCategory)
            }
            .padding(.vertical)
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}

struct ChallengeListView: View {
    @ObservedObject var challengeData: ChallengeData
    @ObservedObject var achievementData: AchievementData
    var selectedCategory: ChallengeCategory
    let imageNames = ["SideQuest-2", "SideQuest-3", "SideQuest-4"]
    @State private var showText = false
    @State private var currentImageIndex = 0
    
    var allChallengesAreCompleted: Bool {
        let challenges = challengeData.challengesByCategory[selectedCategory]?.dropFirst() ?? []
        return challenges.count > 0 && challenges.allSatisfy { challenge in
            challenge.isCompleted
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let firstChallenge = challengeData.challengesByCategory[selectedCategory]?.first {
                NavigationLink(
                    destination: UploadView(challengeData: challengeData, achievementData: achievementData, challenge: firstChallenge),
                    label: {
                        ChallengeTileView(challenge: firstChallenge, category: selectedCategory)
                    }
                )
            }
            ForEach(challengeData.challengesByCategory[selectedCategory]?.dropFirst() ?? [], id: \.id) { challenge in
                if challenge.isCompleted || challenge.isUnlocked {
                    NavigationLink(
                        destination: UploadView(challengeData: challengeData, achievementData: achievementData, challenge: challenge),
                        label: {
                            ChallengeTileView(challenge: challenge, category: selectedCategory)
                        }
                    )
                } else {
                    ZStack {
                        Circle()
                            .fill(Color(red: 240/255, green: 240/255, blue: 240/255))
                            .frame(width: 150, height: 150)
                            .onTapGesture {
                                generateHapticFeedback()
                            }
                        Image(systemName: "lock")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color.black)
                            .onTapGesture {
                                generateHapticFeedback()
                            }
                    }
                    Rectangle()
                        .fill(Color(red: 240/255, green: 240/255, blue: 240/255))
                        .frame(width: 5, height: 20)
                }
            }
            ZStack {
                Circle()
                    .fill(Color(red: 240/255, green: 240/255, blue: 240/255))
                    .frame(width: 150, height: 150)
                    .onTapGesture {
                        generateHapticFeedback()
                    }
                
                if !allChallengesAreCompleted {
                    Text("Next: Level 2") // Display the image based on the current index
                        .foregroundColor(.black)
                } else {
                    Image(imageNames[currentImageIndex])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 142, height: 142) // Match the size of the Circle
                        .clipShape(Circle()) // Clip the image to a Circle shape
                        .overlay(Circle().stroke(Color.primary, lineWidth: 2)) // Add a white border
                        .onTapGesture {  // Use onTapGesture to trigger the animation
                            if currentImageIndex < imageNames.count - 1 {
                                withAnimation(Animation.easeInOut(duration: 1.5)) {
                                    currentImageIndex += 1
                                    withAnimation(Animation.easeInOut(duration: 1.5)) {
                                        currentImageIndex += 1
                                        showText = true  // Show the text after animation
                                        generateHapticFeedback()
                                    }
                                }
                            } else {
                                // Do nothing or add any specific behavior when you reach the end
                            }
                        }
                    if !showText {
                        Text("Press to open")
                            .font(.custom("Avenir", size: 16))
                            .foregroundColor(Color.primary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            if showText {
                Text("Level 2 unlocked")
                    .font(.custom("Avenir", size: 16))
                    .foregroundColor(Color.primary)
                    .multilineTextAlignment(.center)
                    .onTapGesture {
                        generateHapticFeedback()
                    }
                    
            }
            Spacer()
        }
    }
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
}
func generateHapticFeedback() {
    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
    impactFeedbackgenerator.prepare()
    impactFeedbackgenerator.impactOccurred()
}
