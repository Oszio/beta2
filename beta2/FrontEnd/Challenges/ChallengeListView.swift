//
//  ChallengeListView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-03.
//
import SwiftUI

struct ChallengeListView: View {
    @State private var selectedCategory: ChallengeCategoryOption?
    
    var body: some View {
        NavigationView {
            List(ChallengeCategoryOption.allCases, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                }) {
                    Text(category.rawValue)
                }
                .background(
                    NavigationLink(destination: CategoryChallengeListView(category: category), isActive: Binding<Bool>(
                        get: { selectedCategory == category },
                        set: { if !$0 { selectedCategory = nil } }
                    )) {
                        EmptyView()
                    }
                    .hidden()
                )
            }
            .navigationTitle("Categories")
        }
    }
}

struct CategoryChallengeListView: View {
    var category: ChallengeCategoryOption
    @State private var challenges: [Challenge] = []
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading challenges...")
            } else {
                List(challenges) { challenge in
                    NavigationLink(destination: ChallengeDetailView(challenge: challenge)) {
                        Text(challenge.name)
                    }
                }
                .navigationTitle(category.rawValue)
            }
        }
        .onAppear {
            fetchChallenges()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func fetchChallenges() {
        isLoading = true
        Task {
            do {
                // Fetch challenges from the ChallengeManager
                let allChallenges = try await ChallengeManager.shared.fetchChallenges(inCategory: category.rawValue)

                // Filter challenges based on category and sort them by sequence
                let filteredChallenges = allChallenges.filter { $0.categoryId == category.id }

                let sortedChallenges = filteredChallenges.sorted { $0.sequence < $1.sequence }
                
                // Select one challenge based on the current date
                if let challengeToShow = challengeForToday(from: sortedChallenges) {
                    challenges = [challengeToShow]
                } else {
                    // Handle the case where no challenge is available for today
                    challenges = []
                }
            } catch {
                alertMessage = "Failed to fetch challenges: \(error.localizedDescription)"
                showAlert = true
            }
            isLoading = false
        }
    }

    
    func challengeForToday(from challenges: [Challenge]) -> Challenge? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today)
        
        if let dayOfYear = dayOfYear, !challenges.isEmpty {
            let index = (dayOfYear - 1) % challenges.count
            return challenges[index]
        }
        return nil
    }
}
