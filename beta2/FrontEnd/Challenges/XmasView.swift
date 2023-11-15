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
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2) // Adjust count for desired column number
    
    var body: some View {
           NavigationView {
               ZStack {
                   // Festive background image
                   Image("xmasImage")
                       .resizable()
                       .scaledToFill()
                       .edgesIgnoringSafeArea(.all)

                   if isLoading {
                                   ProgressView() // Standard progress view
                                       .scaleEffect(1.5) // Optional: Scale up for visibility
                                       .progressViewStyle(CircularProgressViewStyle(tint: .white)) // Optional: White tint for better visibility
                               } else {
                                   challengesGrid
                               }
                           }
                           .onAppear(perform: loadXmasChallenges)
                           .navigationTitle("Xmas Challenges")
                           .alert(isPresented: $showAlert) { // Standard alert view
                               Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                           }
                       }
                   }

       private var challengesGrid: some View {
           ScrollView {
               LazyVGrid(columns: columns, spacing: 20) {
                   ForEach(xmasChallenges) { challenge in
                       NavigationLink(destination: ChallengeDetailView(challenge: challenge)) {
                           ChallengeGridCell(challenge: challenge)
                       }
                       .buttonStyle(PlainButtonStyle())
                   }
               }
               .padding()
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



struct ChallengeGridCell: View {
    let challenge: Challenge

    var body: some View {
        VStack {
            Image(systemName: "gift.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .foregroundColor(.red) // Festive icon color

            Text(challenge.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(challenge.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7)) // Slightly transparent background for readability
        )
        .shadow(radius: 5)
    }
}
