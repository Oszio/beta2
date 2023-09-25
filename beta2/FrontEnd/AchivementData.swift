//
//  AchivementData.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-24.
//

import Foundation

struct Achievement: Identifiable {
    let id: Int
    let title: String
    let description: String
    let pointThreshold: Int // Achievements are unlocked when users reach certain points
    var isUnlocked: Bool = false
}

class AchievementData: ObservableObject {
    @Published var achievements: [Achievement] = [
        Achievement(id: 1, title: "Newbie", description: "Complete your first challenge!", pointThreshold: 10),
        Achievement(id: 2, title: "Adventurer", description: "Accumulate 100 points.", pointThreshold: 100),
        Achievement(id: 3, title: "Challenge Master", description: "Accumulate 500 points.", pointThreshold: 500)
        // Add more achievements as needed
    ]
    
    func checkForAchievements(totalPoints: Int) {
        for index in 0..<achievements.count {
            if !achievements[index].isUnlocked && totalPoints >= achievements[index].pointThreshold {
                achievements[index].isUnlocked = true
                
                
                print("Achievement unlocked: \(achievements[index].title)")
            }
            
        }
    }
}
