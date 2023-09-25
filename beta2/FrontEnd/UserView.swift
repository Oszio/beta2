//
//  UserView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-24.
//

import SwiftUI

struct UserView: View {
    @ObservedObject var achievementData: AchievementData
    @ObservedObject var challengeData: ChallengeData
    @Binding var activeView: ActiveView
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Your Profile")
                        .font(.custom("Avenir", size: 44))
                        .bold()
                        .italic()
                        .padding(.top, 50)
                    
                    // Total Points
                    HStack {
                        Text("Total Points:")
                            .font(.custom("Avenir", size: 20))
                           
                        Text("\(challengeData.totalPoints)")
                            .font(.custom("Avenir", size: 20))
                            .foregroundColor(Color(red: (28+95)/255, green: (77+95)/255, blue: (42+95)/255))
                    }
                    Divider()
                    
                    Text("Achivements")
                        .font(.custom("Avenir", size: 20))
                        .foregroundColor(.primary) // Set the text color
                   
                    ForEach(achievementData.achievements) { achievement in
                       
                        ZStack {
                            
                            // Green Gradient Background for the card
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: achievement.isUnlocked ? [Color(red: (28+95)/255, green: (77+95)/255, blue: (42+95)/255)] : [Color.gray.opacity(0.3), Color.gray.opacity(0.5)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: UIScreen.main.bounds.width - 20, height: 80) // Adjust the width and height as desired
                                .onTapGesture {
                                    generateHapticFeedback()
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 2)
                                        
                                )
                            
                            HStack {
                                // Foreground Content
                                if achievement.isUnlocked {
                                    Image(systemName: "trophy.fill")
                                        .resizable()
                                        .frame(width: 30, height: 25)  // Adjust the icon size
                                        .foregroundColor(.yellow)
                                        .overlay(
                                            Image(systemName: "trophy.fill")
                                                .resizable()
                                                .frame(width: 30, height: 25)
                                                .foregroundColor(.yellow)
                                                .offset(x: 1, y: 1)
                                                .mask(LinearGradient(colors: [Color.black, Color.clear], startPoint: .leading, endPoint: .trailing))
                                        ) // Adds shimmer to the right side
                                } else {
                                  
                                }
                                
                                
                                Text(achievement.title)
                                    .font(.custom("Avenir", size: 16))
                                    .bold()
                                    .foregroundColor(Color.white)
                                    .padding(.top, 5)
                                
                                Text(achievement.description)
                                    .font(.custom("Avenir", size: 14))
                                    .foregroundColor(Color.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 5)
                                    .padding(.horizontal, 10)
                            }
                        }
                        .padding(.vertical, -10)
                        .frame(width: 200)  // This ensures the card is centered
                       
                    }


                    Divider()

                    
               
                    VStack(spacing: 20) {
                        Text("Current Progress")
                            .font(.custom("Avenir", size: 20))
                            .foregroundColor(.primary) // Set the text color
                       

                        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(ChallengeCategory.allCases, id: \.self) { category in
                                let progress = challengeData.progressForCategory(category)
                                VStack(alignment: .center) {
                                    Text(category.displayName)
                                        .font(.custom("Avenir", size: 16))
                                        .bold()
                                        .padding(.bottom, 5)
                                    
                                    GradientCircularProgressBar(progress: .constant(progress))
                                        .frame(width: 100, height: 100) // Adjust as needed
                                }
                            }
                        }
                    }

                        
                }
            }
        }
    }
}
