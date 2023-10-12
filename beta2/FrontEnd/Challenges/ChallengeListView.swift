//
//  ChallengeListView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-03.
//
import SwiftUI

struct ChallengeListView: View {
    @State private var selectedCategory: ChallengeCategoryOption?
    @State private var showChallengesForCategory: Bool = false
    
    var body: some View {
        List(ChallengeCategoryOption.allCases, id: \.self) { category in
            Button(action: {
                selectedCategory = category
                showChallengesForCategory.toggle()
            }) {
                Text(category.rawValue)
            }
            .sheet(isPresented: $showChallengesForCategory) {
                if let selectedCategory = selectedCategory {
                    NavigationView {
                        CategoryChallengeListView(category: selectedCategory)
                    }
                }
            }
            
            .navigationTitle("Categories")
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
                    challenges = try await ChallengeManager.shared.fetchChallenges(inCategory: category.rawValue, upToSequence: 100) // Assuming 100 is the max sequence number for now
                } catch {
                    alertMessage = "Failed to fetch challenges: \(error.localizedDescription)"
                    showAlert = true
                }
                isLoading = false
            }
        }
    }
}
