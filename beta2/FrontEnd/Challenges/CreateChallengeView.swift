//
//  CreateChallengeView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-12.
//

import SwiftUI

enum ChallengeCategoryOption: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case exercise = "Exercise"
    case nature = "Nature"
    case social = "Social"
    case food = "Food"
    case culture = "Culture"
    case kindness = "Kindness"
    case mindfulness = "Mindfulness"
    
    var id: String { self.rawValue }
}

struct CreateChallengeView: View {
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var points: Int = 0
    @State private var evidenceRequired: Bool = false
    @State private var sequence: Int = 1
    @State private var selectedCategory: ChallengeCategoryOption = .daily
    @State private var isUploading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        Form {
            Section(header: Text("Challenge Details")) {
                TextField("Name", text: $name)
                TextField("Description", text: $description)
                Stepper(value: $points, in: 1...100) {
                    Text("Points: \(points)")
                }
                Toggle(isOn: $evidenceRequired) {
                    Text("Evidence Required")
                }
                Stepper(value: $sequence, in: 1...100) {
                    Text("Sequence: \(sequence)")
                }
            }

            Section(header: Text("Category")) {
                Picker("Select Category", selection: $selectedCategory) {
                    ForEach(ChallengeCategoryOption.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section {
                Button(action: uploadChallenge) {
                    Text("Create Challenge")
                }
                .disabled(isUploading)
            }
        }
        .navigationTitle("Create Challenge")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func uploadChallenge() {
        let challenge = Challenge(
            id: UUID().uuidString,
            name: name,
            description: description,
            points: points,
            evidenceRequired: evidenceRequired,
            sequence: sequence,
            categoryID: selectedCategory.rawValue  // Set the categoryID
        )

        isUploading = true
        Task {
            do {
                try await ChallengeManager.shared.uploadChallenge(challenge, toCategory: selectedCategory.rawValue)
                alertMessage = "Challenge uploaded successfully!"
                showAlert = true
            } catch {
                alertMessage = "Failed to upload challenge: \(error.localizedDescription)"
                showAlert = true
            }
            isUploading = false
        }
    }

}
