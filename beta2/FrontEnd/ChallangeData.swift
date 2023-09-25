//
//  ChallangeData.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-24.
//


 
 import SwiftUI
 import Combine
 import UIKit


 
 enum ChallengeCategory: String, CaseIterable {
 case daily = "Daily"
 case active = "Exercise"
 case nature = "Nature"
 case social = "Social"
 case food = "Food"
 case culture = "Culture"
 case kindness = "Kindness"
 case mindfulness = "Mindfulness"
 
 
 var displayName: String {
 return self.rawValue
 }
 }
 
 struct Challenge: Identifiable {
 let id: Int
 let title: String
 let description: String
 let category: ChallengeCategory
 var isCompleted: Bool = false
 var isUnlocked: Bool = false
 var evidence: UIImage? = nil
 var comment: String? = nil
 var points: Int = 10
 
 
 }
 
 
 
 class ChallengeData: ObservableObject {
 func getChallengeById(id: Int) -> Challenge? {
 for (_, challenges) in challengesByCategory {
 if let challenge = challenges.first(where: { $0.id == id }) {
 return challenge
 
 }
 }
 return nil // Return nil if no matching challenge is found
 }
 @Published var challengesByCategory: [ChallengeCategory: [Challenge]]
 @Published var totalPoints: Int = 0 {
 willSet {
 objectWillChange.send()
 }
 }
 
 init(challengesByCategory: [ChallengeCategory: [Challenge]] = [
 .active: [
 
 Challenge(id: 1, title: "Push up challenge: do as many push-ups as you can!", description: "exercise", category: .active, isUnlocked: true),
 Challenge(id: 2, title: "Go for a hike and take a picture of the nature/forest.", description: "exercise", category: .active),
 Challenge(id: 3, title: "Get moving, capture your workout, and inspire others to stay active.", description: "exercise", category: .active)
 ],
 .nature: [
 Challenge(id: 4, title: "Go for a walk in the woods and take a picture of the changing colors of the leaves.", description: "nature", category: .nature, isUnlocked: true),
 Challenge(id: 5, title: "Go for mushrooms or berries.", description: "nature Challenge", category: .nature),
 Challenge(id: 6, title: "Collect a bouquet of leaves of different colours.", description: "nature", category: .nature),
 ],
 .social: [
 Challenge(id: 7, title: "Enjoy a coffee outside with a friend.", description: "social", category: .social, isUnlocked: true),
 Challenge(id: 8, title: "Host a board game night.", description: "social", category: .social),
 Challenge(id: 9, title: "Organise an event with your friends (e.g. bowling, karaoke or ice skating", description: "social", category: .social),
 ],
 .food: [
 Challenge(id: 10, title: "Make your own homemade pasta.", description: "food", category: .food, isUnlocked: true),
 Challenge(id: 11, title: "Make homemade sushi.", description: "food", category: .food),
 Challenge(id: 12, title: "Cook Pad Thai for dinner", description: "food", category: .food)
 ],
 .culture: [
 Challenge(id: 13, title: "Find an outdoor art-piece (e.g. a statue) and take a selfie with it.", description: "culture", category: .culture, isUnlocked: true),
 Challenge(id: 14, title: "Read a few pages from a book or magazine/newspaper and post a picture of what you read.", description: "culture", category: .culture),
 Challenge(id: 15, title: "Go to a museum and find an art-piece that you like", description: "culture", category: .culture)
 ],
 .kindness: [
 Challenge(id: 16, title: "Pick up a piece of plastic from nature and recycle it.", description: "kindness", category: .kindness, isUnlocked: true),
 Challenge(id: 17, title: "Write a kind note to a stranger.", description: "kindness", category: .kindness),
 Challenge(id: 18, title: "Write to someone you haven't talked to in a while.", description: "kindness", category: .kindness)
 ],
 .mindfulness: [
 Challenge(id: 19, title: "Try meditation or yoga for at least 10 minutes and find your calm.", description: "mindfulness", category: .mindfulness, isUnlocked: true),
 Challenge(id: 20, title: "Write down five things you'd like to learn or achieve this year.", description: "mindfulness", category: .mindfulness),
 Challenge(id: 21, title: "Watch the sunset over the water.", description: "mindfulness", category: .mindfulness)
 ],
 .daily: [
 Challenge(id: 22, title: "Take a selfie while making a funny face.", description: "daily", category: .daily, isUnlocked: true),
 Challenge(id: 23, title: "Go for a walk wearing a piece of clothing you've neglected and post a picture of your outfit.", description: "daily", category: .daily),
 Challenge(id: 24, title: "Go for a walk outside and take a picture of a dog.", description: "daily", category: .daily),
 ]    ]) {
 self.challengesByCategory = challengesByCategory
 }
 
 func addComment(id: Int, comment: String) {
 for (category, challenges) in challengesByCategory {
 if let index = challenges.firstIndex(where: { $0.id == id }) {
 var updatedChallenges = challenges
 var challenge = updatedChallenges[index]
 challenge.comment = comment
 updatedChallenges[index] = challenge
 challengesByCategory[category] = updatedChallenges
 break
 }
 }
 }
 
 func completeChallenge(id: Int) {
 for (category, challenges) in challengesByCategory {
 if let index = challenges.firstIndex(where: { $0.id == id }) {
 var updatedChallenges = challenges
 var challenge = updatedChallenges[index]
 challenge.isCompleted = true
 updatedChallenges[index] = challenge
 
 if index + 1 < updatedChallenges.count {
 var nextChallenge = updatedChallenges[index + 1]
 nextChallenge.isUnlocked = true
 updatedChallenges[index + 1] = nextChallenge
 
 
 }
 
 challengesByCategory[category] = updatedChallenges
 break
 }
 
 }
 }
 
 func addEvidence(id: Int, image: UIImage) {
 for (category, challenges) in challengesByCategory {
 if let index = challenges.firstIndex(where: { $0.id == id }) {
 var updatedChallenges = challenges
 var challenge = updatedChallenges[index]
 challenge.evidence = image
 updatedChallenges[index] = challenge
 challengesByCategory[category] = updatedChallenges
 
 // Mark the challenge as completed
 challenge.isCompleted = true
 challengesByCategory[category]?[index] = challenge
 
 // Unlock the next challenge if available
 if index + 1 < updatedChallenges.count {
 var nextChallenge = updatedChallenges[index + 1]
 nextChallenge.isUnlocked = true
 updatedChallenges[index + 1] = nextChallenge
 challengesByCategory[category]?[index + 1] = nextChallenge
 }
 }
 }
 }
 func addPoints(points: Int) {
 totalPoints += points
 print("Points added: \(points), Total points now: \(totalPoints)")
 
 // After adding points, check for any newly unlocked achievements
 
 }
 
 }
 
 extension ChallengeData {
 func progressForCategory(_ category: ChallengeCategory) -> Double {
 guard let challenges = challengesByCategory[category] else { return 0 }
 let completedChallenges = challenges.filter { $0.isCompleted }.count
 return Double(completedChallenges) / Double(challenges.count)
 }
 }
 
  
