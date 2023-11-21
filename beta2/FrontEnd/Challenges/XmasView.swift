//
//  XmasView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-11-15.
//

import SwiftUI

struct XmasChallengesView: View {
    @State private var todaysChallenge: Challenge?
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedBackgroundView() // Animated background
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if let challenge = todaysChallenge {
                    ChallengeDetailView(challenge: challenge)
                } else {
                    Text("No Challenge for Today")
                        .foregroundColor(.gray)
                }
            }
            .onAppear(perform: loadTodaysChallenge)
            .navigationTitle("Today's Xmas Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .accentColor(.red) // Festive accent color
    }
    
    func loadTodaysChallenge() {
        isLoading = true
        Task {
            do {
                let xmasChallenges = try await ChallengeManager.shared.fetchChallenges(inCategory: ChallengeCategoryOption.XMAS.rawValue)
                let sortedChallenges = xmasChallenges.sorted(by: { $1.sequence < $1.sequence })
                todaysChallenge = selectChallengeForToday(from: sortedChallenges)
            } catch {
                alertMessage = "Failed to load challenges: \(error.localizedDescription)"
                showAlert = true
            }
            isLoading = false
        }
    }
    
    func selectChallengeForToday(from challenges: [Challenge]) -> Challenge? {
        let calendar = Calendar.current
        let today = calendar.component(.day, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        
        // Ensure it's December
        guard currentMonth == 11 else {
            return nil
        }
        
        // Find the challenge whose sequence matches today's date in December
        return challenges.first(where: { $0.sequence == today })
    }
}
