//
//  XmasView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-11-15.
//

import SwiftUI

struct XmasChallengesView: View {
    @State private var xmasChallenges: [Challenge] = []
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        List(xmasChallenges) { challenge in
            VStack(alignment: .leading) {
                Text(challenge.name)
                    .font(.headline)
                Text(challenge.description)
                    .font(.subheadline)
            }
        }
        .onAppear {
            loadXmasChallenges()
        }
        .navigationTitle("Xmas Challenges")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func loadXmasChallenges() {
        isLoading = true
        Task {
            do {
                xmasChallenges = try await ChallengeManager.shared.fetchChallenges(inCategory: ChallengeCategoryOption.XMAS.rawValue)
            } catch {
                alertMessage = "Failed to load challenges: \(error.localizedDescription)"
                showAlert = true
            }
            isLoading = false
        }
    }
}
